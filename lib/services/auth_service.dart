import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/services/chatting_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ///유저 가입 (유저 콜렉션에 유저 데이터와 유저키-학교 콜렉션에 추가)<br>
  ///파이어베이스 등록 > 로그인 > 파이어스토어에 데이터 추가<br>
  ///[userData] : 회원가입 & 프로필 설정 후에 나온 유저 데이터
  Future<bool> registUser(UserData userData) async {
    try {
      //회원가입
      await auth.createUserWithEmailAndPassword(
          email: userData.email!, password: userData.password!);
      userData.registDate = Timestamp.now();

      //위에 가입한 정보로 로그인
      await auth.signInWithEmailAndPassword(
          email: userData.email!, password: userData.password!);

      userData.uid = auth.currentUser!.uid;

      //파이어스토어에 유저 데이터 추가
      await firestore
          .collection("schools/${userData.school}/users")
          .doc(userData.uid)
          .set(userData.toJson())
          .whenComplete(() {
        firestore
            .collection("userSchoolInfo")
            .doc(userData.uid)
            .set({"userSchoolData": userData.school});
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return true;
  }

  ///현재 로그인 된 유저의 UID 반환
  String getUID() {
    String uid = auth.currentUser?.uid ?? "";
    return uid;
  }

  ///중복 계정 체크<br>
  ///required [school] : 중복 체크할 이메일의 소속 학교<br>
  ///required [email] : 중복 체크할 이메일
  Future<bool> checkDuplicatedEmail(
      {required String school, required String email}) async {
    var data = await firestore
        .collection("schools/$school/users")
        .where("email", isEqualTo: email)
        .get();
    return data.docs.isEmpty;
  }

  ///가입 제한 이메일 체크<br>
  ///required [email] : 체크할 이메일
  Future<bool> checkBlockedEmail({required String email}) async {
    var data = await firestore
        .collection("blockEmailList")
        .where("email", isEqualTo: email)
        .get();
    return data.docs.isEmpty;
  }

  ///유저 데이터 수정(덮어쓰기)<br>
  ///[userData] : 설정할 유저 데이터
  Future setUserData(UserData userData) async {
    firestore
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .set(userData.toJson());
  }

  ///유저 UID 로 유저키-학교 콜렉션에서 유저의 학교 검색 학교(String) 반환<br>
  ///[uid] : 학교 정보를 검색할 유저의 UID
  Future<String> getUserSchoolInfo(String uid) async {
    String resultSchool = "";

    var data = await firestore.collection("userSchoolInfo").doc(uid).get();
    resultSchool =
        (data.data() as Map<String, dynamic>)["userSchoolData"].toString();

    return resultSchool;
  }

  ///유저 데이터 반환<br>
  ///[uid] : 대상 유저의 UID<br>
  ///[options] : 검색 옵션 (캐시, 서버, 서버와 캐시)<br>
  ///Source.cache / Source.server / Source.serverAndCache
  Future<UserData> getUserData(
      {String uid = "", Source options = Source.serverAndCache}) async {
    String school = await getUserSchoolInfo(uid);
    DocumentSnapshot doc = await firestore
        .collection("schools/$school/users")
        .doc(uid)
        .get(GetOptions(source: options));
    return UserData.fromJson(doc.data() as Map<String, dynamic>);
  }

  ///유저 도큐먼트 스냅샷 반환 (퓨처빌더 쓸때)<br>
  ///[uid] : 대상 유저의 UID<br>
  ///[options] : 검색 옵션 (캐시, 서버, 서버와 캐시)<br>
  ///Source.cache / Source.server / Source.serverAndCache
  Future<DocumentSnapshot> getUserDocumentSnapshot(
      {String uid = "", Source? options = Source.serverAndCache}) async {
    String school = await getUserSchoolInfo(uid);
    return firestore
        .collection('schools/$school/users')
        .doc(uid)
        .get(GetOptions(source: options!));
  }

  ///FCM 토큰 업데이트
  Future updateNotiToken(UserData userData) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    firestore
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .update({"notiToken": token});
  }

  ///비밀번호 변경
  Future changePassword(
      String uid, String email, String pw, String newPassword) async {
    String school = await getUserSchoolInfo(uid);
    await auth.signInWithEmailAndPassword(email: email, password: pw);
    await auth.currentUser?.updatePassword(newPassword);
    firestore
        .collection("schools/$school/users")
        .doc(uid)
        .update({"password": newPassword});
  }

  ///로그아웃
  Future signOut(BuildContext context) async {
    //기기 저장 데이터 삭제
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("containTags");
    pref.remove("containMBTI");
    pref.remove("containTSchedule");

    //파이어베이스 로그아웃 후 로그인 페이지로 이동
    await auth.signOut().whenComplete(() {
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const LoginScreen(),
      //     ),
      //     (route) => false);
      context.goNamed(Screen.login);
      context.read<UserDataProvider>().userData = UserData();
    });
  }

  ///유저 삭제 (영구 삭제) (테스트코드)
  Future deleteUser(String uid) async {
    String school = await getUserSchoolInfo(uid);
    await firestore.collection("schools/$school/users").doc(uid).delete();
    await firestore.collection("userSchoolInfo").doc(uid).delete();
  }

  ///계정 삭제
  Future deleteAccount(BuildContext context, UserData userData) async {
    //참여한 단체 채팅방에서 모두 나가기
    ChattingService chattingService = ChattingService();
    var querySanpshot = await chattingService
        .getChattingRoomListQuerySnapshot(userData, isGroup: true);
    var roomData = querySanpshot.docs;

    for (var element in roomData) {
      GroupChatRoomData room = GroupChatRoomData.fromJson(element.data());
      chattingService.leaveGroupChatRoom(
          userData: userData, roomId: room.roomId ?? "");
    }

    await firestore.collection("blockEmailList").doc(userData.email).set({
      "email": userData.email,
      "experatDate":
          Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)))
    });

    //유저 학교 콜렉션에서 데이터 삭제
    await firestore.collection("userSchoolInfo").doc(userData.uid).delete();

    //유저 콜렉션에서 데이터 삭제
    await firestore
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .delete();

    //파이어스토어에서 프로필 이미지 삭제
    await FirebaseStorage.instance
        .ref("schools/${userData.school}/profileImages/${userData.uid}.png")
        .delete()
        .onError((error, stackTrace) =>
            debugPrint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$error: $stackTrace"));

    //Authentication에서 삭제한 다음 로그아웃 후 로그인 페이지로 이동
    await auth.currentUser?.delete().whenComplete(() {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false);
    });
  }

  ///유저 Notification Token 값 반환
  Future<String> getUserNotiToken(String userUID) async {
    String token = "";

    UserData userData = await getUserData(uid: userUID);
    token = userData.notiToken ?? "";

    return token;
  }
}

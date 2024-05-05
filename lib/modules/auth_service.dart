import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firesotre = FirebaseFirestore.instance;

  //현재 로그인 된 유저의 UID 반환
  String getUID() {
    String uid = auth.currentUser?.uid ?? "";
    return uid;
  }

  //유저 가입 (유저 콜렉션에 유저 데이터와 유저키-학교 콜렉션에 추가)
  //파이어베이스 등록 > 로그인 > 파이어스토어에 데이터 추가
  Future registUser(UserData userData) async {
    await auth.createUserWithEmailAndPassword(
        email: userData.email!, password: userData.password!);
    userData.registDate = Timestamp.now();
    await auth.signInWithEmailAndPassword(
        email: userData.email!, password: userData.password!);
    userData.uid = auth.currentUser!.uid;
    firesotre
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .set(userData.toJson())
        .whenComplete(() {
      firesotre
          .collection("userSchoolInfo")
          .doc(userData.uid)
          .set({"userSchoolData": userData.school});
    });
  }

  //유저 데이터 수정(덮어쓰기)
  Future setUserData(UserData userData) async {
    firesotre
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .set(userData.toJson());
  }

  //유저 삭제 (영구 삭제)
  Future deleteUser(String uid) async {
    String school = await getUserSchoolInfo(uid);
    await firesotre.collection("schools/$school/users").doc(uid).delete();
    await firesotre.collection("userSchoolInfo").doc(uid).delete();
  }

  //유저 UID 로 유저키-학교 콜렉션에서 유저의 학교 검색 학교(String) 반환
  Future<String> getUserSchoolInfo(String uid) async {
    String resultSchool = "";

    var data = await firesotre.collection("userSchoolInfo").doc(uid).get();
    resultSchool =
        (data.data() as Map<String, dynamic>)["userSchoolData"].toString();

    return resultSchool;
  }

  //유저 데이터 반환
  Future<UserData> getUserData(
      {String uid = "", Source? options = Source.serverAndCache}) async {
    String school = await getUserSchoolInfo(uid);
    DocumentSnapshot doc = await firesotre
        .collection("schools/$school/users")
        .doc(uid)
        .get(GetOptions(source: options!));
    return UserData.fromJson(doc.data() as Map<String, dynamic>);
  }

  //유저 도큐먼트 스냅샷 반환 (퓨처빌더 쓸때)
  Future<DocumentSnapshot> getUserDocumentSnapshot(
      {String uid = "", Source? options = Source.serverAndCache}) async {
    String school = await getUserSchoolInfo(uid);
    return firesotre
        .collection('schools/$school/users')
        .doc(uid)
        .get(GetOptions(source: options!));
  }

  //비밀번호 변경
  Future changePassword(
      String uid, String email, String pw, String newPassword) async {
    String school = await getUserSchoolInfo(uid);
    await auth.signInWithEmailAndPassword(email: email, password: pw);
    await auth.currentUser?.updatePassword(newPassword);
    firesotre
        .collection("schools/$school/users")
        .doc(uid)
        .update({"password": newPassword});
  }

  //로그아웃
  Future signOut(BuildContext context) async {
    //기기 저장 데이터 삭제
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("containTags");
    pref.remove("containMBTI");
    pref.remove("containTSchedule");

    //파이어베이스 로그아웃 후 로그인 페이지로 이동
    await auth.signOut().whenComplete(() {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false);
      context.read<UserDataProvider>().userData = UserData();
    });
  }

  void unregister() {}
}

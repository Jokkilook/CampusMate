import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firestorage = FirebaseStorage.instance;

  ///유저 좋아요 평가
  Future userLike({required String targetUID, required String likerUID}) async {
    String school = await AuthService().getUserSchoolInfo(targetUID);
    var ref = firestore.collection("schools/$school/users").doc(targetUID);
    //이 전에 안좋아요 눌렀으면 거기서 삭제
    ref.update({
      "dislikers": FieldValue.arrayRemove([likerUID])
    });

    //타겟 상대의 좋아요 누른 사람 리스트에 추가
    ref.update({
      "likers": FieldValue.arrayUnion([likerUID])
    });
  }

  ///유저 싫어요 평가
  Future userDislike(
      {required String targetUID, required String likerUID}) async {
    String school = await AuthService().getUserSchoolInfo(targetUID);
    var ref = firestore.collection("schools/$school/users").doc(targetUID);
    //이 전에 좋아요 눌렀으면 거기서 삭제
    ref.update({
      "likers": FieldValue.arrayRemove([likerUID])
    });

    //타겟 상대의 좋아요 누른 사람 리스트에 추가
    ref.update({
      "dislikers": FieldValue.arrayUnion([likerUID])
    });
  }

  ///유저 UID로 닉네임 반환하기
  Future<List<UserData>> getUserDataByUIDList(List<String> uidList) async {
    List<UserData> retrunNameList = [];
    String school = await AuthService().getUserSchoolInfo(uidList[0]);
    for (var element in uidList) {
      var data = await firestore
          .collection("schools/$school/users")
          .doc(element)
          .get();
      var userData = UserData.fromJson(data.data() as Map<String, dynamic>);
      retrunNameList.add(userData);
    }

    return retrunNameList;
  }

  ///유저 밴
  Future banUser(
      {required String targetUID, required UserData currentUser}) async {
    var ref = firestore
        .collection("schools/${currentUser.school}/users")
        .doc(currentUser.uid);
    var targetRef = firestore
        .collection("schools/${currentUser.school}/users")
        .doc(targetUID);
    //밴 리스트에 있나 확인 후 없으면 밴리스트에 추가하고 상대의 "나를 차단한 사람 리스트"에 추가
    if (!(currentUser.banUsers?.contains(targetUID) ?? false)) {
      await ref.update({
        "banUsers": FieldValue.arrayUnion([targetUID])
      });

      await targetRef.update({
        "blockers": FieldValue.arrayUnion([currentUser.uid])
      });
    }
  }

  ///유저 밴 해제
  Future unbanUser(
      {required String targetUID, required UserData currentUser}) async {
    var ref = firestore
        .collection("schools/${currentUser.school}/users")
        .doc(currentUser.uid);
    var targetRef = firestore
        .collection("schools/${currentUser.school}/users")
        .doc(targetUID);
    //밴 리스트에 있나 확인 후 있으면 밴리스트에서 삭제하고 상대의 "나를 차단한 사람 리스트"에서 삭제
    if (currentUser.banUsers?.contains(targetUID) ?? false) {
      await ref.update({
        "banUsers": FieldValue.arrayRemove([targetUID])
      });

      await targetRef.update({
        "blockers": FieldValue.arrayRemove([currentUser.uid])
      });
    }
  }

  ///좋아요, 싫어요 수에 따라 매너학점 산출
  static double getCalculatedScore(UserData userData) {
    //기본 점수 85점 (B+)
    double result = 85;
    int likers = userData.likers?.length ?? 0;
    int dislikers = userData.dislikers?.length ?? 0;
    double likeRatio = likers / (likers + dislikers);
    double dislikeRatio = dislikers / (likers + dislikers);

    //평가자가 10명 미만이면 각 유저의 평가에 따라 +-
    if (likers + dislikers < 10) {
      result = 85 + ((likers * 2) + (dislikers * -2));
    }
    //평가자가 10명 이상이면 좋아요 싫어요 비율에 따라 +-
    else {
      result = 85 + ((likeRatio * 25) + (dislikeRatio * -25));
    }

    return result;
  }

  Future updateChattingProfile(UserData targetData) async {
    //1:1채팅방 프로필 url 업데이트
    //참여자에 유저가 포함된 1:1 채팅방 데이터 로딩
    await firestore
        .collection("schools/${targetData.school}/chats")
        .where("participantsUid", arrayContains: targetData.uid)
        .get()
        .then(
      (value) {
        //데이터가 존재하면
        if (value.docs.isNotEmpty) {
          var docs = value.docs;
          //불러온 채팅방 데이터 순회
          for (var doc in docs) {
            String id = doc.id;
            Map<String, dynamic> data = doc.data();
            //참여자 명단 가져오기
            Map<String, List<String>> userInfo =
                (data["participantsInfo"] as Map<String, dynamic>)
                    .map((key, value) {
              return MapEntry(key, (value as List<dynamic>).cast<String>());
            });

            //
            userInfo[targetData.uid!] = [
              targetData.name!,
              targetData.imageUrl!
            ];

            firestore
                .collection("schools/${targetData.school}/chats")
                .doc(id)
                .update({"participantsInfo": userInfo});
          }
        }
      },
    );

    //그룹 채팅방 프로필 url 업데이트
    await firestore
        .collection("schools/${targetData.school}/groupChats")
        .where("participantsUid", arrayContains: targetData.uid)
        .get()
        .then(
      (value) {
        if (value.docs.isNotEmpty) {
          var docs = value.docs;
          for (var doc in docs) {
            String id = doc.id;
            Map<String, dynamic> data = doc.data();
            Map<String, List<String>> userInfo =
                (data["participantsInfo"] as Map<String, dynamic>)
                    .map((key, value) {
              return MapEntry(key, (value as List<dynamic>).cast<String>());
            });

            userInfo[targetData.uid!] = [
              targetData.name!,
              targetData.imageUrl!
            ];

            firestore
                .collection("schools/${targetData.school}/groupChats")
                .doc(id)
                .update({"participantsInfo": userInfo});
          }
        }
      },
    );
  }

  ///프로필 수정 시 파이어스토어 업데이트
  Future updateCommunityProfile(UserData targetData) async {
    //게시판 유저 정보 수정
    String newName = targetData.name ?? "";
    String newUrl = targetData.imageUrl ?? "";

    //게시판 레퍼런스
    var postsRef =
        firestore.collection('schools/${targetData.school}/generalPosts');

    //게시판 전체 게시글 가져오기
    var postData = await postsRef.get();

    //반환 받은 전체 게시글 순회
    for (var post in postData.docs) {
      //작성자UID가 수정 유저의 UID와 같으면
      if (post["authorUid"] == targetData.uid) {
        //해당 게시글의 작성자 닉네임, 이미지Url 변경
        await post.reference.update({
          'authorName': newName,
          'profileImageUrl': newUrl,
        });
      }

      //해당 게시글 전체 댓글 가져오기
      var commentData = await post.reference.collection("comments").get();

      //해당 게시글 댓글 순회
      for (var comment in commentData.docs) {
        //댓글 작성자가 수정 유저의 UID와 같으면
        if (comment["authorUid"] == targetData.uid) {
          //해당 댓글의 작성자 닉네임, 이미지Url 변경
          await comment.reference.update({
            'authorName': newName,
            'profileImageUrl': newUrl,
          });
        }

        //해당 댓글의 전체 답글 가져오기
        var replyData = await comment.reference.collection("replies").get();

        //해당 댓글의 답글 순회
        for (var reply in replyData.docs) {
          //답글 작성자가 수정 유저의 UID와 같으면
          if (reply["authorUid"] == targetData.uid) {
            //해당 답글의 작성자 닉네임, 이미지Url 변경
            await reply.reference.update({
              'authorName': newName,
              'profileImageUrl': newUrl,
            });
          }
        }
      }
    }
  }
}

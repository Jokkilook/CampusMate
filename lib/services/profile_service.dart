import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firestorage = FirebaseStorage.instance;

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

  //유저 밴
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

  //유저 밴 해제
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

  //좋아요, 싫어요 수에 따라 매너학점 산출
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
}

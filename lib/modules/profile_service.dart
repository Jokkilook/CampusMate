import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
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

  static double getCalculatedScore(UserData userData) {
    double result = 85;
    int likers = userData.likers?.length ?? 0;
    int dislikers = userData.likers?.length ?? 0;

    return result;
  }
}

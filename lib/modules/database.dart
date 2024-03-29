import 'package:campusmate/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataBase {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  UserData getUser(String uid) {
    UserData userData = UserData();
    late final Map<String, dynamic> data;
    final ref = db.collection("users").doc(uid);

    ref.get().then((value) => data = value.data()!);

    // userData.data = data;
    // userData.uid = data["uid"];
    // userData.name = data["name"];
    // userData.school = data["school"];
    // userData.dept = data["dept"];
    // userData.email = data["email"];
    // userData.password = data["password"];
    // userData.enterYear = data["enterYear"];
    // userData.age = data["age"];
    // userData.gender = data["gender"];
    // userData.introduce = data["introduce"];
    // userData.mbti = data["mbti"];
    // userData.tags = data["tags"];
    // userData.schedule = data["schedule"];

    print(data["name"]);

    return userData;
  }

  void addUser(UserData userData) {
    //유저 추가 코드
    userData.setData();
    db
        .collection("users")
        .doc(userData.uid)
        .set(userData.data!)
        .onError((error, stackTrace) => debugPrint(error.toString()));
  }

  void deleteUser(UserData userData) {
    //유저 삭제 코드
    db.collection("users").doc(userData.uid).delete();
  }

  void updateUser(UserData userData) {}
}

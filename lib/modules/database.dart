import 'dart:async';

import 'package:campusmate/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataBase {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<UserData> getUser(String uid) async {
    final ref = db.collection("users").doc(uid);
    DocumentSnapshot doc = await ref.get();
    return UserData.fromJson(doc.data() as Map<String, dynamic>);
  }

  void addUser(UserData userData) async {
    //유저 추가 코드
    userData.setData();
    await db
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

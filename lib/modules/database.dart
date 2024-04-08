import 'dart:async';

import 'package:campusmate/models/post_data.dart';
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

  void deleteUser(String uid) {
    //유저 삭제 코드
    db.collection("users").doc(uid).delete();
  }

  void updateUser(UserData userData) {}

  void addPost(PostData postData) async {
    try {
      postData.setData();
      if (postData.boardType == 'General') {
        await FirebaseFirestore.instance
            .collection('generalPosts')
            .add(postData.data!);
      }
      if (postData.boardType == 'Anonymous') {
        await FirebaseFirestore.instance
            .collection('anonymousPosts')
            .add(postData.data!);
      }
    } catch (error) {
      debugPrint('안 올라감ㅋ: $error');
    }
  }
}

import 'dart:async';

import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataBase {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<UserData> getUser(String schoold, String uid) async {
    final ref = db.collection("shcools/$schoold/users").doc(uid);
    DocumentSnapshot doc = await ref.get();
    return UserData.fromJson(doc.data() as Map<String, dynamic>);
  }

  void addUser(UserData userData) async {
    //유저 추가 코드
    await db
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .set(userData.toJson())
        .onError((error, stackTrace) => debugPrint(error.toString()));
  }

  void deleteUser(String uid) {
    //유저 삭제 코드
    db.collection("schools/테스트대학교/users").doc(uid).delete();
  }

  void updateUser(UserData userData) {}

  void addPost(UserData userData, PostData postData) async {
    try {
      postData.setData();
      if (postData.boardType == 'General') {
        await FirebaseFirestore.instance
            .collection('schools/${userData.school}/generalPosts')
            .add(postData.data!);
      }
      if (postData.boardType == 'Anonymous') {
        await FirebaseFirestore.instance
            .collection('schools/${userData.school}/anonymousPosts')
            .add(postData.data!);
      }
    } catch (error) {
      debugPrint('안 올라감ㅋ: $error');
    }
  }
}

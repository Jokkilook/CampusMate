import 'package:campusmate/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  UserData userData;
  Stream<QuerySnapshot>? matchUserStream;

  UserDataProvider({required this.userData}) {
    matchUserStream = FirebaseFirestore.instance
        .collection('users')
        .where("school", isEqualTo: userData.school)
        .snapshots();
  }

  void setName(String name) {
    userData.name = name;
    notifyListeners();
  }
}

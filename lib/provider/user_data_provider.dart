import 'package:campusmate/models/user_data.dart';
import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  UserData userData;

  UserDataProvider({required this.userData});

  void setName(String name) {
    userData.name = name;
    notifyListeners();
  }
}

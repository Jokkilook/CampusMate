import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  static late SharedPreferences prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static setList(List<String> list) {
    return prefs.setStringList("ban", list);
  }

  static getList() {
    return prefs.getStringList("ban") ?? [];
  }
}

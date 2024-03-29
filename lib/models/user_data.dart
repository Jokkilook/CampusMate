import 'dart:convert';

import 'package:campusmate/models/schedule_data.dart';
import 'package:crypto/crypto.dart';

class UserData {
  String? uid;
  String? name;
  String? school;
  String? dept;
  String? email;
  String? password;
  int? enterYear;
  int? age;
  bool? gender;
  String? introduce;
  String? mbti;
  List<dynamic>? tags;
  ScheduleData schedule = ScheduleData();

  Map<String, dynamic>? data;

  UserData(
      {this.uid,
      this.name,
      this.school,
      this.dept,
      this.email,
      this.password,
      this.enterYear,
      this.age,
      this.gender,
      this.introduce,
      this.mbti,
      this.tags}) {
    data = {
      "uid": uid,
      "name": name,
      "school": school,
      "dept": dept,
      "email": email,
      "password": password,
      "enterYear": enterYear,
      "age": age,
      "gender": gender,
      "introduce": introduce,
      "mbti": mbti,
      "tags": tags,
      "schedule": schedule.schedule
    };
  }

  UserData.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    name = json["name"];
    school = json["school"];
    dept = json["dept"];
    email = json["email"];
    password = json["password"];
    enterYear = json["enterYear"];
    age = json["age"];
    gender = json["gender"];
    introduce = json["introduce"];
    mbti = json["mbti"];
    tags = json["tags"];
    final List<Map<String, bool>> list = json["schedule"];
    schedule = ScheduleData();
    schedule.schedule = list;

    data = {
      "uid": uid,
      "name": name,
      "school": school,
      "dept": dept,
      "email": email,
      "password": password,
      "enterYear": enterYear,
      "age": age,
      "gender": gender,
      "introduce": introduce,
      "mbti": mbti,
      "tags": tags,
      "schedule": schedule.schedule
    };
  }

  void setData() {
    data = {
      "uid": uid,
      "name": name,
      "school": school,
      "dept": dept,
      "email": email,
      "password": password,
      "enterYear": enterYear,
      "age": age,
      "gender": gender,
      "introduce": introduce,
      "mbti": mbti,
      "tags": tags,
      "schedule": schedule.schedule
    };
  }
}

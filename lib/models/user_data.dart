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
  List<String>? tags;
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

  void set() {
    uid = "test4";
    name = "jo";
    age = 24;
    dept = "테스트학과";
    email = "ppkw2001@gmail.com";
    password = sha256.convert(utf8.encode("qkrrhksdn")).toString();
    enterYear = 2020;
    gender = true;
    schedule = ScheduleData();
    print("done");
  }
}

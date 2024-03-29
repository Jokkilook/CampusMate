import 'dart:convert';
import 'dart:ffi';

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
  Double? score;
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
      this.score,
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
      "score": score,
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
    //DB에서 가져온 데이터는 List<dynamic>이 되어버려서 다시 List<Map<String, bool>> 타입으로 변환해주어야한다.
    schedule.schedule = (json["schedule"] as List)
        .map((e) => Map<String, bool>.from(e))
        .toList();

    //왠진 몰라도 요일속 시간 순서가 뒤죽박죽이 되어서 다시 정렬해줘야함..정렬하는 코드
    var num = 0;
    for (var map in schedule.schedule) {
      schedule.schedule[num] = Map.fromEntries(
          map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      num++;
    }

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

import 'package:campusmate/models/schedule_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String? uid;
  String? name;
  String? school;
  String? dept;
  String? email;
  String? password;
  int? enterYear;
  String? birthDate;
  bool? gender;
  String? introduce;
  double? score;
  String? mbti;
  String? imageUrl;
  String? notiToken;
  List<dynamic>? tags = [];
  ScheduleData schedule = ScheduleData();
  Timestamp? registDate;
  List<String>? likers = [];
  List<String>? dislikers = [];
  List<String>? banUsers = [];
  List<String>? blockers = [];
  String? link = "";

  UserData({
    this.uid,
    this.name,
    this.school,
    this.dept,
    this.email,
    this.password,
    this.enterYear,
    this.birthDate,
    this.gender,
    this.introduce,
    this.score = 80.00,
    this.mbti,
    this.imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/test.png?alt=media&token=43db937e-0bba-4c89-a9f6-dff0387c8d45",
    this.notiToken,
    this.tags,
    this.registDate,
    this.banUsers,
    this.blockers,
  }) {
    tags = tags ?? [];
    banUsers = banUsers ?? [];
    blockers = blockers ?? [];
  }

  UserData.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    name = json["name"];
    school = json["school"];
    dept = json["dept"];
    email = json["email"];
    password = json["password"];
    enterYear = json["enterYear"];
    birthDate = json["birthDate"];
    gender = json["gender"];
    introduce = json["introduce"];
    mbti = json["mbti"];
    imageUrl = json["imageUrl"];
    notiToken = json["notiToken"];
    tags = json["tags"];
    score = json["score"].toDouble();
    registDate = json["registDate"];

    likers = (json["likers"] as List).map((e) => e.toString()).toList();
    dislikers = (json["dislikers"] as List).map((e) => e.toString()).toList();
    banUsers = (json["banUsers"] as List).map((e) => e.toString()).toList();
    blockers = (json["blockers"] as List).map((e) => e.toString()).toList();

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
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "school": school,
      "dept": dept,
      "email": email,
      "password": password,
      "enterYear": enterYear,
      "birthDate": birthDate,
      "gender": gender,
      "introduce": introduce,
      "score": score,
      "mbti": mbti,
      "imageUrl": imageUrl,
      "notiToken": notiToken,
      "tags": tags,
      "schedule": schedule.schedule,
      "registDate": registDate,
      "likers": likers,
      "dislikers": dislikers,
      "banUsers": banUsers,
      "blockers": blockers
    };
  }
}

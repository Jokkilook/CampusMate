import 'package:campusmate/models/schedule_data.dart';

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
      this.birthDate,
      this.gender,
      this.introduce,
      this.score = 80.00,
      this.mbti,
      this.imageUrl =
          "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/images%2Ftest.png?alt=media&token=4a231bcd-04fa-4220-9914-1028783f5f35",
      this.tags}) {
    data = {
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
    birthDate = json["birthDate"];
    gender = json["gender"];
    introduce = json["introduce"];
    mbti = json["mbti"];
    imageUrl = json["imageUrl"];
    tags = json["tags"];
    score = json["score"];

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
      "birthDate": birthDate,
      "gender": gender,
      "introduce": introduce,
      "score": score,
      "mbti": mbti,
      "imageUrl": imageUrl,
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
      "birthDate": birthDate,
      "gender": gender,
      "introduce": introduce,
      "score": score,
      "mbti": mbti,
      "imageUrl": imageUrl,
      "tags": tags,
      "schedule": schedule.schedule
    };
  }
}

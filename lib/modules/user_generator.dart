import 'dart:math';

import 'package:campusmate/models/schedule_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:random_name_generator/random_name_generator.dart';

class UserGenerator {
  UserData userData = UserData();
  DataBase db = DataBase();
  int index = 0;
  final schools = ["테스트대학교"];
  final depts = ["테스트학과", "컴퓨터공학과", "철학과", "생명공학과", "무슨학과", "시각디자인과"];
  final tags = [
    "공부",
    "동네",
    "취미",
    "식사",
    "카풀",
    "술",
    "등하교",
    "시간 떼우기",
    "연애",
    "편입",
    "취업",
    "토익",
    "친분",
    "연상",
    "동갑",
    "연하",
    "선배",
    "동기",
    "후배"
  ];
  final mbtis = [
    "ENTP",
    "ENTJ",
    "ENFP",
    "ENFJ",
    "ESTP",
    "ESTJ",
    "ESFP",
    "ESFJ",
    "INTP",
    "INTJ",
    "INFP",
    "INFJ",
    "ISTP",
    "ISTJ",
    "ISFP",
    "ISFJ"
  ];

  void addDummyUser(int quantity) async {
    AggregateQuerySnapshot query =
        await db.db.collection("schools/테스트대학교/users").count().get();
    index = query.count ?? index;

    for (int i = 0; i < quantity; i++) {
      randomAsign();
      AuthService().registUser(userData);
      index++;
    }
  }

  void deleteDummyUser(int quantity) async {
    AggregateQuerySnapshot query =
        await db.db.collection("schools/테스트대학교/users").count().get();
    index = query.count ?? index;

    for (int i = index; i > index - quantity; i--) {
      AuthService().deleteUser(i.toString());
    }
  }

  void randomAsign() {
    userData = UserData();
    userData.uid = index.toString();
    userData.birthDate =
        "${Random().nextInt(20) + 1990}.${Random().nextInt(11) + 1}.${Random().nextInt(30) + 1}";
    userData.dept = depts[Random().nextInt(depts.length)];
    userData.enterYear = Random().nextInt(6) + 2018;
    userData.email = "dummy@dummy.com";
    userData.password = "dummypassword";
    userData.gender = Random().nextBool();
    userData.mbti = mbtis[Random().nextInt(mbtis.length)];
    userData.imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/images%2Ftest.png?alt=media&token=4a231bcd-04fa-4220-9914-1028783f5f35";
    userData.school = schools[Random().nextInt(schools.length)];
    userData.name = RandomNames(Zone.us).name();
    userData.introduce = lorem(
        paragraphs: Random().nextInt(2) + 1, words: Random().nextInt(50) + 5);
    userData.schedule = ScheduleData();
    for (var day in userData.schedule.schedule) {
      day.map((key, value) {
        day[key] = Random().nextBool();
        return MapEntry(key, value);
      });
    }
    userData.tags = [];
    for (int i = 0; i < 8; i++) {
      userData.tags!.add(tags[Random().nextInt(tags.length)]);
    }
    userData.tags = userData.tags!.toSet().toList();
    userData.score = 80 + Random().nextDouble() * 30;
    userData.registDate = Timestamp.fromDate(DateTime.now());
  }
}

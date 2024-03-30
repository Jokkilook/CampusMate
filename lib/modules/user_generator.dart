import 'dart:math';

import 'package:campusmate/models/schedule_data.dart';
import 'package:campusmate/models/user_data.dart';
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
    "놀기",
    "시간떼우기",
    "술",
    "친구",
    "연애",
    "공부",
    "편입",
    "토익",
    "취업",
    "면접",
    "카풀",
    "산책",
    "동네",
    "자취",
    "학식",
    "맛집",
    "게임",
    "취미"
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

  void addDummy(int quantity) async {
    AggregateQuerySnapshot query =
        await db.db.collection("users").count().get();
    index = query.count ?? index;

    for (int i = 0; i < quantity; i++) {
      randomAsign();
      userData.setData();
      db.addUser(userData);
      index++;
    }
  }

  void deleteDummy(int quantity) async {
    AggregateQuerySnapshot query =
        await db.db.collection("users").count().get();
    index = query.count ?? index;

    for (int i = index; i > index - quantity; i--) {
      db.deleteUser(i.toString());
    }
  }

  void randomAsign() {
    userData = UserData();
    userData.uid = index.toString();
    userData.age = Random().nextInt(10) + 20;
    userData.dept = depts[Random().nextInt(depts.length)];
    userData.enterYear = Random().nextInt(6) + 2018;
    userData.email = "dummy@dummy.com";
    userData.password = "dummypassword";
    userData.gender = Random().nextBool();
    userData.mbti = mbtis[Random().nextInt(mbtis.length)];
    userData.school = schools[Random().nextInt(schools.length)];
    userData.name = RandomNames(Zone.us).name();
    userData.introduce =
        lorem(paragraphs: Random().nextInt(2), words: Random().nextInt(50));
    userData.schedule = ScheduleData();
    for (var day in userData.schedule.schedule) {
      day.map((key, value) {
        day[key] = Random().nextBool();
        return MapEntry(key, value);
      });
    }
    userData.tags = [];
    for (int i = 0; i < tags.length; i++) {
      userData.tags!.add(tags[Random().nextInt(tags.length)]);
    }
    userData.tags = userData.tags!.toSet().toList();
    userData.score = Random().nextDouble() * 100;
  }
}

import 'dart:ffi';

import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/schedule_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  ProfilScreen({super.key});

  late List<Map<String, bool>> totalSchedule;

  final db = DataBase();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('프로필'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            throw Error();
          } else {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            return wholeProfile(UserData.fromJson(data));
          }
        },
      ),
      bottomNavigationBar: const SizedBox(
        height: 70,
      ),
    );
  }

  SingleChildScrollView wholeProfile(UserData userData) {
    late final String score;

    if (userData.score! >= 95) {
      score = "A+";
    } else if (userData.score! >= 90) {
      score = "A";
    } else if (userData.score! >= 85) {
      score = "B+";
    } else if (userData.score! >= 80) {
      score = "B";
    } else if (userData.score! >= 75) {
      score = "C+";
    } else if (userData.score! >= 70) {
      score = "C";
    } else if (userData.score! >= 65) {
      score = "D+";
    } else if (userData.score! >= 60) {
      score = "D";
    } else {
      score = "F";
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const AdArea(),
            const SizedBox(height: 12),
            // 프로필 카드
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 2)
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "${userData.name}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  // 자기소개
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '자기소개',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${userData.introduce}',
                        ),
                      ],
                    ),
                  ),
                  // 정보, 매너학점
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    height: 105,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '정보',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('나이  ${userData.age}'),
                              Text('성별  ${userData.gender! ? "남" : "여"}'),
                              Text('학과  ${userData.dept}'),
                            ],
                          ),
                        ),
                        VerticalDivider(
                          width: 30,
                          color: Colors.grey[400],
                          thickness: 1.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    '매너학점 ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      //매너학점이 뭔지 알려주는 안내 카드 출력
                                      print("test");
                                    },
                                    child: const Icon(Icons.help_outline,
                                        size: 16, color: Colors.black45),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    score,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //성향, 태그
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '성향',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('MBTI  ${userData.mbti}'),
                          const Text(
                            '태그',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (var tag in userData.tags!)
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(15)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: Text(tag.toString()),
                                )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  //시간표
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              '시간표',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: ScheduleTable(
                                scheduleData: userData.schedule,
                                readOnly: true),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

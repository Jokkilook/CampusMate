import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/schedule_table.dart';
import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  ProfilScreen({super.key, required this.userData});

  final UserData userData;

  late List<Map<String, bool>> totalSchedule;

  Map<String, bool> monSchedule = {
    "MON08": true,
    "MON09": true,
    "MON10": true,
    "MON11": true,
    "MON12": true,
    "MON13": true,
    "MON14": true,
    "MON15": true,
    "MON16": true,
    "MON17": true,
    "MON18": true,
    "MON19": true,
  };
  Map<String, bool> tueSchedule = {
    "TUE08": true,
    "TUE09": true,
    "TUE10": true,
    "TUE11": true,
    "TUE12": true,
    "TUE13": true,
    "TUE14": true,
    "TUE15": true,
    "TUE16": true,
    "TUE17": true,
    "TUE18": true,
    "TUE19": true,
  };
  Map<String, bool> wedSchedule = {
    "WED08": true,
    "WED09": true,
    "WED10": true,
    "WED11": true,
    "WED12": true,
    "WED13": true,
    "WED14": true,
    "WED15": true,
    "WED16": true,
    "WED17": true,
    "WED18": true,
    "WED19": true,
  };
  Map<String, bool> thuSchedule = {
    "THU08": true,
    "THU09": true,
    "THU10": true,
    "THU11": true,
    "THU12": true,
    "THU13": true,
    "THU14": true,
    "THU15": true,
    "THU16": true,
    "THU17": true,
    "THU18": true,
    "THU19": true,
  };
  Map<String, bool> friSchedule = {
    "FRI08": true,
    "FRI09": true,
    "FRI10": true,
    "FRI11": true,
    "FRI12": true,
    "FRI13": true,
    "FRI14": true,
    "FRI15": true,
    "FRI16": true,
    "FRI17": true,
    "FRI18": true,
    "FRI19": true,
  };

  @override
  Widget build(BuildContext context) {
    totalSchedule = [
      userData.schedule.mon,
      userData.schedule.tue,
      userData.schedule.wed,
      userData.schedule.thu,
      userData.schedule.fri,
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('프로필'),
      ),
      body: SingleChildScrollView(
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
                    const Text(
                      '닉네임',
                      style: TextStyle(
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '자기소개',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '자기소개 내용',
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
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '정보',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('나이  24'),
                                Text('성별  남'),
                                Text('학과  컴퓨터공학과'),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'B+',
                                      style: TextStyle(
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
                      child: const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '성향',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('MBTI  INTP'),
                            Text(
                              '태그',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            Text('태그'),
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
      ),
    );
  }
}

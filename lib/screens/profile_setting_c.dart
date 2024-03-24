import 'package:campusmate/widgets/schedule_table.dart';
import 'package:flutter/material.dart';

class ProfileSettingC extends StatefulWidget {
  const ProfileSettingC({super.key});

  @override
  State<ProfileSettingC> createState() => _ProfileSettingCState();
}

class _ProfileSettingCState extends State<ProfileSettingC> {
  bool isCompleted = false;

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
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    totalSchedule = [
      monSchedule,
      tueSchedule,
      wedSchedule,
      thuSchedule,
      friSchedule
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "프로필 설정",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C5C5C)),
        ),
        shadowColor: Colors.black,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Row(
            //상태 진행바
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 10,
                  color: const Color(0xff2CB66B),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("   시간표",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                            child: Text(
                              "수업이 있는 시간을 체크하세요!",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black45),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ScheduleTable(
                        scheduleData: totalSchedule,
                      )
                    ]),
              ],
            ),
          ),
        ]),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(40),
        child: ElevatedButton(
          onPressed: true ? () {/* 태그 리스트 데이터베이스에 삽입 */} : null,
          child: const Text(
            "완료",
            style: TextStyle(
                color: true ? Color(0xFF0A351E) : Colors.black45,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2BB56B),
            minimumSize: const Size(10000, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}

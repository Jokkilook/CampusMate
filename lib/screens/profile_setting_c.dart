import 'package:campusmate/widgets/schedule_table.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ProfileSettingC extends StatefulWidget {
  const ProfileSettingC({super.key});

  @override
  State<ProfileSettingC> createState() => _ProfileSettingCState();
}

class _ProfileSettingCState extends State<ProfileSettingC> {
  bool isCompleted = false;

  late List<Map<String, bool>> totalSchedule;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
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
                      SizedBox(height: 5),
                      ScheduleTable()
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

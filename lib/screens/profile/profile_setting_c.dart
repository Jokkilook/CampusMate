import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/profile_setting_result.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/screens/profile/widgets/schedule_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileSettingC extends StatefulWidget {
  const ProfileSettingC({super.key, required this.userData});
  final UserData userData;

  @override
  State<ProfileSettingC> createState() => _ProfileSettingCState();
}

class _ProfileSettingCState extends State<ProfileSettingC> {
  bool isCompleted = false;

  late List<Map<String, bool>> totalSchedule;
  final db = DataBase();

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    totalSchedule = [
      widget.userData.schedule.mon,
      widget.userData.schedule.tue,
      widget.userData.schedule.wed,
      widget.userData.schedule.thu,
      widget.userData.schedule.fri,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                        scheduleData: widget.userData.schedule,
                      )
                    ]),
              ],
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomButton(
        text: "다음",
        isCompleted: true,
        onPressed: () {
          /* 태그 리스트 데이터베이스에 삽입 */
          widget.userData.schedule.schedule = totalSchedule;
          AuthService().setUserData(widget.userData);
          //db.addUser(widget.userData);
          context.read<UserDataProvider>().userData = widget.userData;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileResult(userData: widget.userData),
              ),
              (route) => false);
        },
      ),
    );
  }
}

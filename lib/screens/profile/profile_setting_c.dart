import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/profile_setting_result.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/screens/profile/widgets/schedule_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileSettingC extends StatefulWidget {
  const ProfileSettingC({super.key});

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
    final UserData userData = context.read<UserDataProvider>().userData;
    totalSchedule = [
      userData.schedule.mon,
      userData.schedule.tue,
      userData.schedule.wed,
      userData.schedule.thu,
      userData.schedule.fri,
    ];
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "프로필 설정",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
        ),
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
                  color: Colors.green,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("   시간표",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkHeadText
                                    : AppColors.lightHeadText,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                            child: Text(
                              "수업이 있는 시간을 체크하세요!",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ScheduleTable(
                        scheduleData: userData.schedule,
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
          userData.schedule.schedule = totalSchedule;
          AuthService().setUserData(userData);
          context.read<UserDataProvider>().userData = userData;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileSettingResult(),
              ),
              (route) => false);
        },
      ),
    );
  }
}

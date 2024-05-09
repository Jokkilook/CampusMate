import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/more/ban_user_management_screen.dart';
import 'package:campusmate/screens/more/delete_account_screen.dart';
import 'package:campusmate/screens/more/password_update_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  String timeStampToYYYYMMDD({Timestamp? time, String? stringTime}) {
    if (time != null) {
      var data = time.toDate().toString();
      var date = DateTime.parse(data);
      return "${NumberFormat("0000").format(date.year)}년 ${NumberFormat("00").format(date.month)}월 ${NumberFormat("00").format(date.day)}일";
    } else if (stringTime != null) {
      var date = DateTime.fromMillisecondsSinceEpoch(int.parse(stringTime));
      return "${NumberFormat("0000").format(date.year)}년 ${NumberFormat("00").format(date.month)}월 ${NumberFormat("00").format(date.day)}일";
    }

    return "0000년 00월 00일";
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserDataProvider>(context).userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("내 정보"),
      ),
      body: Column(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData.name ?? "",
                  style: const TextStyle(fontSize: 30),
                ),
                Text(
                  userData.school ?? "",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  userData.dept ?? "",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "이메일 : ${userData.email}",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  "생일 : ${userData.birthDate}",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  "가입일 : ${timeStampToYYYYMMDD(time: userData.registDate)}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BanUserManagementScreen(),
                  ));
            },
            title: const Text("차단한 유저 관리"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordUpdateScreen(),
                  ));
            },
            title: const Text("비밀번호 변경"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteAccountScreen(),
                ),
              );
            },
            title: const Text(
              "회원 탈퇴",
              style: TextStyle(color: AppColors.alertText),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:campusmate/AppColors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/profile/profile_setting_a.dart';
import 'package:flutter/material.dart';

class RegistResult extends StatelessWidget {
  const RegistResult({super.key, required this.userData});
  final UserData userData;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "가입 완료!",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
            ),
            Text(
              "프로필을 설정해 볼까요?",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                /* 회원가입 데이터에 나머지 저장 후 데이터베이스에 삽입 */
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileSettingA(userData: userData),
                    ));
              },
              child: const Text(
                "프로필 설정하기",
                style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                minimumSize: const Size(10000, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

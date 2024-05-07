import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ProfileSettingResult extends StatelessWidget {
  ProfileSettingResult({super.key, required this.userData});
  UserData userData;

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
              "프로필 설정 완료!",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
            ),
            Text(
              "친구를 만나러 가요!",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ));
              },
              child: const Text(
                "캠퍼스 메이트 시작",
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

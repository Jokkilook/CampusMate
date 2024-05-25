import 'package:campusmate/app_colors.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

///회원가입 결과 화면<br>
///프로필 설정으로 넘어가기 전 화면
class RegisterResult extends StatelessWidget {
  const RegisterResult({super.key});

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
                context.goNamed(Screen.profileA);
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

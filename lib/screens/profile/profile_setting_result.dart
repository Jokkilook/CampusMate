import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///프로필 완료 화면<br>
///여기서 회원가입과 데이터 업로드 실행
//ignore: must_be_immutable
class ProfileSettingResult extends StatefulWidget {
  const ProfileSettingResult({super.key});

  @override
  State<ProfileSettingResult> createState() => _ProfileSettingResultState();
}

class _ProfileSettingResultState extends State<ProfileSettingResult> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    final UserData userData = context.read<UserDataProvider>().userData;
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
              onPressed: () async {
                isLoading = true;
                setState(() {});

                await AuthService().registUser(userData).then((value) {
                  //가입 성공 시
                  if (value) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                        (route) => false);
                  }
                  //회원가입 실패 시
                  else {
                    //실패 스낵바 출력
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        elevation: 0,
                        backgroundColor: Colors.black.withOpacity(0.8),
                        content: const Text(
                          "가입에 실패했어요...😭 다시 시도해주세요.",
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: const Duration(milliseconds: 3000),
                      ),
                    );

                    //로그인 화면으로 이동
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                        (route) => false);
                  }
                });
              },
              child: isLoading
                  ? const CircleLoading(color: AppColors.buttonText)
                  : const Text(
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

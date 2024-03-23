import 'package:flutter/material.dart';

class RegistResult extends StatelessWidget {
  const RegistResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "가입 완료!",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            const Text(
              "프로필을 설정해 볼까요?",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {/* 회원가입 데이터에 나머지 저장 후 데이터베이스에 삽입 */},
              child: const Text(
                "프로필 설정하기",
                style: TextStyle(
                    color: Color(0xFF0A351E),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BB56B),
                minimumSize: const Size(10000, 60),
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

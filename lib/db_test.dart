import 'package:campusmate/modules/database.dart';
import 'package:campusmate/modules/user_generator.dart';
import 'package:flutter/material.dart';

class DBTest extends StatelessWidget {
  DBTest({super.key});
  final db = DataBase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DB TEST"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("버튼 누르면 10개씩 생성됨"),
            ElevatedButton(
              onPressed: () {
                UserGenerator().addDummy(10);
              },
              child: const Text("더미유저생성"),
            ),
            ElevatedButton(
              onPressed: () {
                UserGenerator().deleteDummy(10);
              },
              child: const Text("더미유저삭제"),
            )
          ],
        ),
      ),
    );
  }
}

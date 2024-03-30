import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/modules/user_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DBTest extends StatelessWidget {
  DBTest({super.key});
  final db = DataBase();
  final uid = "be5g1pnzgLQGF8ICgXQyxHeIbH82";
  Map<String, dynamic>? data;

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

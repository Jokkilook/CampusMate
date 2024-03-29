import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DBTest extends StatelessWidget {
  DBTest({super.key});
  final db = DataBase();
  late UserData userData;
  final uid = "NmD3grykMqXaoc0famvykP0Trqc2";

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
            const Text("Start"),
            ElevatedButton(
              onPressed: () {
                // late Map<String, dynamic>? a;
                // final b = db.db.collection("users").doc(uid);
                // b.get().then((value) => print(value.data()!["name"]));
                // b.get().then((value) {
                //   print(value.data()!);
                // });
                userData = db.getUser(uid);
                print(userData.age);
              },
              child: const Text("GET USERDATA"),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DBTest extends StatelessWidget {
  DBTest({super.key});
  final db = DataBase();
  final uid = "NmD3grykMqXaoc0famvykP0Trqc2";
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
            const Text("Start"),
            ElevatedButton(
              onPressed: () {
                // final b = db.db.collection("users").doc(uid);
                // b.get().then((value) => print(value.data()!["name"]));
                // b.get().then((value) {
                //   print(value.data()!);
                // });
                print(FirebaseAuth.instance.currentUser!.email.toString());
                print(FirebaseAuth.instance.currentUser!.uid.toString());
              },
              child: const Text("외않되"),
            )
          ],
        ),
      ),
    );
  }
}

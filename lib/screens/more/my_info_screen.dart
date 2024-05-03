import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
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
          Text(userData.name ?? ""),
          Text("이메일 : ${userData.email}"),
          Text("가입일 : ${timeStampToYYYYMMDD(time: userData.registDate)}")
        ],
      ),
    );
  }
}

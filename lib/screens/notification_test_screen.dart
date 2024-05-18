import 'package:campusmate/modules/noti_test.dart';
import 'package:flutter/material.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("알림 테스트"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("알림 보내기"),
          onPressed: () {
            NotiTest.showNoti();
            print("눌렀다.");
          },
        ),
      ),
    );
  }
}

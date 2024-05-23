import 'package:campusmate/services/noti_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String token = "TOKEN PLACE";

  String getAccessToken() {
    String token = "";

    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("알림 테스트"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text("토큰 얻기"),
                onPressed: () async {
                  token =
                      await FirebaseMessaging.instance.getToken() ?? "EMPTY";
                  setState(() {});

                  debugPrint(token);
                },
              ),
              Text(token),
              ElevatedButton(
                child: const Text("로컬 알림 보내기"),
                onPressed: () {
                  NotiService.showNoti();
                },
              ),
              ElevatedButton(
                child: const Text("API로 알림 보내기"),
                onPressed: () async {
                  String pToken =
                      "d1li6JjkT5K_8yzEwlXyXc:APA91bEBqQlz9l4m75V_rfQCLxbEvyv3rVBAjulfazqO-Vcv6AhzkSNnIuY1-Zs4wwBsMscV-XhOX5h1rjsUiUiVPTECaJEqi8Q5MnpH2meZSBN1Wdh0jekf1jPbMNDrR3X0G8Wkkjx5";

                  NotiService.sendNoti(
                    targetToken: pToken,
                    title: "금쪽이",
                    content: "꺄ㅡ악",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

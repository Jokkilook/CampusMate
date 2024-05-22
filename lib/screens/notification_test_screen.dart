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
                      "cABp2IIhSme5pP7rkoajqr:APA91bH6yhe8qprFBpH9T8Vzw404CL0Xa3bU-MO9fRf9s22rmjTcBF1MxGxF8eATUcSViIChwsXs19IRuBjz9uyRv6_o7-gbxtzK7_X2CKmjPG2cTRCLfSg0Z6nn1QLnW5PaD6qcxPlB";
                  String eToken =
                      "dPuUYcSQRcW869GaB8AD7b:APA91bEZylvBCiDmlkkvz1hP1semLOOIfIqnlb7xtSU95hNkp87bKI-o5fxHfCCZhhg8d2hAjVnZ8y53ilK4COrlbWp3H0v8Pi5cwwU5eavNMn3H0HllAKzyBxKR1EiZFLdOm8lc2SQL";

                  NotiService.sendNoti(
                      targetToken: pToken, title: "오은영", content: "금쪽이 어딨니~");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

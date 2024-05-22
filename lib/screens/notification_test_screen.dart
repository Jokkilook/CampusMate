import 'dart:convert';

import 'package:campusmate/modules/noti_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        child: Column(
          children: [
            ElevatedButton(
              child: const Text("토큰 얻기"),
              onPressed: () async {
                var token = await FirebaseMessaging.instance.getToken();
                print("TOKEN: $token");
              },
            ),
            ElevatedButton(
              child: const Text("로컬 알림 보내기"),
              onPressed: () {
                NotiTest.showNoti();
                print("눌렀다.");
              },
            ),
            ElevatedButton(
              child: const Text("API로 알림 보내기"),
              onPressed: () async {
                print("API 눌렀다.");
                var respone = await http.post(
                    Uri.parse(
                        "https://fcm.googleapis.com/v1/projects/classmate-81447/messages:send"),
                    headers: {
                      'Content-Type': 'application/json',
                      "Authorization":
                          "Bearer ya29.a0AXooCgs_K-XU2a64qEyDedC_n4TUl2aKv_AvKomU4YZJxw9iodQOooXdS-yYQywT-qUZ8U4j2ugzIMgdIksed829ifOFB7Er1lSj9Vtcu1xzWTZCWuVspryMMu_0m56kRWc9PofW_CUHmBWaCgpqcN2DeKeeMxfothubaCgYKAdgSARESFQHGX2MiM9Y402dANrWZTC91c-PuRQ0171"
                    },
                    body: json.encode({
                      "message": {
                        "token":
                            "fhjTH1obR1-_1-uRI4Hyuh:APA91bE5losYNp3-yinSwczdKn38VBp68GmvrZ5LqmJJIYnbN3UuJbWTA6pikcK7KC1RTKwZJWdkHQYxK4LyLjpq_r1kesIuIZTBXaybZUtzQY8JYX-qs2GI79VLrldPhJGMHaTVhD6N",
                        "notification": {
                          "title": "FCM Test Title",
                          "body": "FCM Test Body",
                        },
                      }
                    }));

                print("RESULT: ${respone.reasonPhrase}");
              },
            ),
          ],
        ),
      ),
    );
  }
}

//POST https://fcm.googleapis.com/v1/{parent=projects/*}/messages:send
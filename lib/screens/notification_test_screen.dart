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
  String token = "TOKEN PLACE";
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
                  print("TOKEN: $token");
                },
              ),
              Text(token),
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
                  String pToken =
                      "cofzPQd7S0CZF-5vGTpTpG:APA91bH2KN92TURDzujE6I-zQ3wAt5scGH-znizr2NGB2Va6WRSei3AuczwNIXlwWXsEsMuFUXSobkAAfGd_-4Tf__bq2YH1wH9naC2-CCsBWPh_0wD6HvD9zRn34S_8qKhR0IIS1hsB";
                  String aToken =
                      "fhjTH1obR1-_1-uRI4Hyuh:APA91bE5losYNp3-yinSwczdKn38VBp68GmvrZ5LqmJJIYnbN3UuJbWTA6pikcK7KC1RTKwZJWdkHQYxK4LyLjpq_r1kesIuIZTBXaybZUtzQY8JYX-qs2GI79VLrldPhJGMHaTVhD6N";
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
                          "token": pToken,
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
      ),
    );
  }
}

//POST https://fcm.googleapis.com/v1/{parent=projects/*}/messages:send
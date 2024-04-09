import 'package:campusmate/modules/database.dart';
import 'package:campusmate/modules/post_generator.dart';
import 'package:campusmate/modules/user_generator.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class DBTest extends StatelessWidget {
  DBTest({super.key});
  final db = DataBase();
  final List<Container> cards = [
    Container(
      alignment: Alignment.center,
      child: const Text('1'),
      color: Colors.blue,
    ),
    Container(
      alignment: Alignment.center,
      child: const Text('2'),
      color: Colors.red,
    ),
    Container(
      alignment: Alignment.center,
      child: const Text('3'),
      color: Colors.purple,
    )
  ];

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
                UserGenerator().addDummyUser(10);
              },
              child: const Text("더미유저생성"),
            ),
            ElevatedButton(
              onPressed: () {
                UserGenerator().deleteDummyUser(10);
              },
              child: const Text("더미유저삭제"),
            ),
            ElevatedButton(
              onPressed: () {
                PostGenerator().addDummyPost(10);
              },
              child: const Text("더미포스트생성"),
            ),
            ElevatedButton(
              onPressed: () {
                PostGenerator().deleteDummyPost(10);
              },
              child: const Text("더미포스트삭제"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance
                    .signOut()
                    .whenComplete(() => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                        (route) => false));
              },
              child: const Text("로그아웃"),
            ),
            Flexible(
              child: CardSwiper(
                isLoop: false,
                cardsCount: cards.length,
                cardBuilder:
                    (context, index, percentThresholdX, percentThresholdY) =>
                        cards[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

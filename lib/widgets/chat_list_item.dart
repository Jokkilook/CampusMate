import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //decoration: const BoxDecoration(border:Border(bottom: BorderSide(color: Colors.black45))),
      width: double.infinity,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "닉네임",
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "마지막 메세지",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  )
                ],
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 5),
                const Text(
                  "1분 전",
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
                Expanded(
                  child: Center(
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications,
                            size: 20, color: Colors.black38)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

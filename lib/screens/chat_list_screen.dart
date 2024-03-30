import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/chat_list_item.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text("채팅방"),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              AdArea(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
              ChatListItem(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 70,
      ),
    );
  }
}

import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/screens/chatting/chat_room_screen.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.data});

  final ChatRoomData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(chatRoomData: data),
            ));
      },
      child: Container(
        color: Colors.transparent,
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.roomName!,
                      style: const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.lastMessage!,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 5),
                  Text(timeStampToHourMinutes(data.lastMessageTime!)),
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
      ),
    );
  }
}

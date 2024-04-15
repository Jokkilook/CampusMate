import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.data});

  final ChatRoomData data;

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    String userUID = AuthService().getUID();
    String senderUID = "";
    String name = "";
    String imageUrl = "";
    List<String> senderData = [];
    bool isDuo = false;

    data.participantsInfo!.forEach((key, value) {
      if (key != userUID) {
        senderUID = key;
        value.sort(
          (a, b) => a.length.compareTo(b.length),
        );
        senderData = value;
      }
    });

    if (data.participantsUid!.length == 2) isDuo = true;

    name = senderData[0];
    imageUrl = senderData[1];

    if (data.lastMessageTime == null) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        ChattingService.enterRoom(context, data);
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: 90,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  width: 60,
                  height: 60,
                  imageUrl: imageUrl,
                  placeholder: (context, url) {
                    return Image.asset("assets/images/default_image.png");
                  },
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDuo ? name : data.roomName!,
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
                  Text(
                    timeStampToHourMinutes(data.lastMessageTime!),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
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
      ),
    );
  }
}

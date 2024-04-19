import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//ignore: must_be_immutable
class ChatListItem extends StatelessWidget {
  ChatListItem({super.key, required this.data, this.count = 0});

  final ChatRoomData data;
  int count;

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    String userUID = AuthService().getUID();
    String name = "";
    String imageUrl = "";
    List<String> senderData = [];
    bool isDuo = false;

    data.participantsInfo!.forEach((key, value) {
      if (key != userUID) {
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
    return InkWell(
      onTap: () {
        ChattingService.enterRoom(context, data);
      },
      onLongPress: () {},
      child: Container(
        clipBehavior: Clip.none,
        color: Colors.transparent,
        width: double.infinity,
        height: 90,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //프로필 사진
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
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
                  count != 0
                      ? Positioned(
                          top: -5,
                          left: -5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1, horizontal: 5),
                            decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: BorderRadius.circular(100)),
                            child: Center(
                              child: Text(
                                count > 100 ? "100+" : "$count",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
              const SizedBox(width: 14),
              //상대방 닉네임 + 내용
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDuo ? name : data.roomName!,
                      style: const TextStyle(fontSize: 17, color: Colors.black),
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
              //시간+알림설정 버튼
              Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    timeStampToHourMinutes(data.lastMessageTime!),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800]),
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

import 'package:campusmate/models/chat_room_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatSearchItem extends StatelessWidget {
  final ChatRoomData data;
  const ChatSearchItem({super.key, required this.data});

  String timeStampToYYYYMMDD({Timestamp? time, String? stringTime}) {
    if (time != null) {
      var data = time.toDate().toString();
      var date = DateTime.parse(data);
      return "${NumberFormat("0000").format(date.year)}년 ${NumberFormat("00").format(date.month)}월 ${NumberFormat("00").format(date.day)}일";
    } else if (stringTime != null) {
      var date = DateTime.fromMillisecondsSinceEpoch(int.parse(stringTime));
      return "${NumberFormat("0000").format(date.year)}년 ${NumberFormat("00").format(date.month)}월 ${NumberFormat("00").format(date.day)}일";
    }

    return "0000년 00월 00일";
  }

  @override
  Widget build(BuildContext context) {
    List<String> seperedList = data.roomId!.split("_");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.roomName ?? "방 제목",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("생성일: ${timeStampToYYYYMMDD(stringTime: seperedList[1])}")
            ],
          )
        ],
      ),
    );
  }
}

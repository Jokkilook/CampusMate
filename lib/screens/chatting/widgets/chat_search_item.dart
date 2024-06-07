import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatSearchItem extends StatelessWidget {
  final GroupChatRoomData data;
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
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  data.roomName ?? "방 제목",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color:
                          isDark ? AppColors.darkTitle : AppColors.lightTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.description ?? "설명",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "생성일: ${timeStampToYYYYMMDD(stringTime: seperedList[1])}",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkHint : AppColors.lightHint,
                ),
              )
            ],
          ),
          Row(
            children: [
              const Icon(Icons.person),
              Text(
                data.participantsUid?.length.toString() ?? "1",
                style: TextStyle(
                  color: isDark ? AppColors.darkHint : AppColors.lightHint,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

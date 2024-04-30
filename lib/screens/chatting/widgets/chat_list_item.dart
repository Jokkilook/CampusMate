import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//ignore: must_be_immutable
class ChatListItem extends StatelessWidget {
  ChatListItem(
      {super.key,
      required this.data,
      this.groupData,
      this.isGroup = false,
      this.unreadCount = 0});

  final ChatRoomData data;
  final GroupChatRoomData? groupData;
  final bool isGroup;
  final ChattingService chat = ChattingService();
  int unreadCount;

  String timeStampToHourMinutes(Timestamp time) {
    var now = DateTime.now();
    var data = time.toDate().toString();
    var date = DateTime.parse(data);
    //현재 시간과 메세지 시간 과의 기간 Duration
    var dateDiff = date.difference(now);
    //현재 시간 = 메세지 시간 DateTime
    var pastDate = now.subtract(dateDiff.abs());
    //어떤 메세지를 출력할지 결정할 n일전 데이터
    var dayDiff = dateDiff.inDays.abs();

    //어제 온 거면 어제 라고 표시
    if (dayDiff == 1) {
      return "어제";
    }
    //3일 이상 전에 온거면 날짜 표시
    else if (dayDiff > 3) {
      return "${pastDate.month}월 ${pastDate.day}일";
    }
    //1일 이상 전에 온거면 n일 전 표시
    else if (dayDiff > 1) {
      return "${dateDiff.inDays.abs().toString()}일 전";
    }
    //오늘 온거면 시간 표시
    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    String userUID = AuthService().getUID();
    String name = "";
    String imageUrl = "";
    Map<String, List<String>> userInfo = {};
    List<List<String>> infoList = [];

    List<String> list;
    data.participantsInfo!.forEach((key, value) {
      value.sort(
        (a, b) => a.length.compareTo(b.length),
      );
      list = value;
      userInfo[key] = list;
      infoList.add([list[0], list[1]]);
    });

    if (!isGroup) {
      userInfo.forEach((key, value) {
        if (key != userUID) {
          name = value[0];
          imageUrl = value[1];
        }
      });
    }

    if (data.lastMessageTime == null) {
      return Container(
        color: Colors.amber,
        width: 50,
        height: 50,
      );
    }

    return InkWell(
      onTap: () {
        isGroup
            ? chat.enterGroupRoom(context, groupData!)
            : chat.enterRoom(context, data);
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
                    child: isGroup
                        ? Container(
                            padding: const EdgeInsets.all(1),
                            color: Colors.amber,
                            width: 60,
                            height: 60,
                            child: Center(
                              child: ExtendedWrap(
                                spacing: 2,
                                runSpacing: 2,
                                maxLines: 2,
                                children: [
                                  for (var info in infoList)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        width: 28,
                                        height: 28,
                                        imageUrl: info[1],
                                        errorWidget: (context, url, error) {
                                          return Image.asset(
                                              "assets/images/default_image.png");
                                        },
                                        placeholder: (context, url) {
                                          return Image.asset(
                                              "assets/images/default_image.png");
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                ],
                              ),
                            ))
                        : CachedNetworkImage(
                            width: 60,
                            height: 60,
                            imageUrl: imageUrl,
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                  "assets/images/default_image.png");
                            },
                            placeholder: (context, url) {
                              return Image.asset(
                                  "assets/images/default_image.png");
                            },
                            fit: BoxFit.cover,
                          ),
                  ),
                  unreadCount != 0
                      ? Positioned(
                          top: -5,
                          left: -5,
                          child: Badge.count(count: unreadCount))
                      : Container(),
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
                      !isGroup ? name : data.roomName!,
                      style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).textTheme.titleLarge?.color),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.lastMessage!,
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).textTheme.displayLarge?.color),
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
                        color: Theme.of(context).textTheme.displayLarge?.color),
                  ),
                  Expanded(
                    child: Center(
                      child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications,
                              size: 20,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color)),
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

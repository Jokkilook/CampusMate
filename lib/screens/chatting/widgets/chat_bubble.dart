import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/modules/enums.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

//ignore: must_be_immutable
class ChatBubble extends StatelessWidget {
  final QueryDocumentSnapshot messageData;
  final int index;
  final bool showTime;
  final bool showDay;
  final bool isOther;
  final bool viewSender;
  final MessageType type;
  final String? name;
  final String? senderUid;
  final String? profileImageUrl;
  final String reader;
  final bool isDark;
  Function()? function;

  ChatBubble(
      {super.key,
      required this.messageData,
      this.index = 0,
      this.showTime = false,
      this.showDay = true,
      this.isOther = false,
      this.viewSender = true,
      this.type = MessageType.text,
      this.name,
      this.senderUid,
      this.profileImageUrl,
      this.reader = "",
      this.isDark = false,
      this.function});

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    var thumbUrl = "";
    var videoUrl = "";
    if (type == MessageType.video) {
      List<String> list = (messageData["content"] as String).split(":-:");
      thumbUrl = list[0];
      videoUrl = list[1];
    }
    CachedNetworkImage cachedProfileImage = CachedNetworkImage(
      imageUrl: profileImageUrl!,
      placeholder: (context, url) {
        return Image.asset(
          "assets/images/default_image.png",
          fit: BoxFit.cover,
        );
      },
      errorWidget: (context, url, error) {
        return Image.asset(
          "assets/images/default_image.png",
          fit: BoxFit.cover,
        );
      },
      fit: BoxFit.cover,
    );

    //최근 온 노티스에 따라 참여자 토큰 업데이트
    if (type == MessageType.notice &&
        (messageData["time"] as Timestamp)
            .toDate()
            .isAfter(DateTime.now().subtract(const Duration(seconds: 1)))) {
      function;
    }

    CachedNetworkImage cachedMediaImage = CachedNetworkImage(
      imageUrl: type == MessageType.video ? thumbUrl : messageData["content"]!,
      placeholder: (context, url) {
        return Container(
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width * 0.65,
          height: MediaQuery.of(context).size.width * 0.65,
          child: const Center(
            child: Icon(Icons.photo_size_select_actual_outlined),
          ),
        );
      },
    );

    return Column(
      children: [
        //날짜 구분선 표시
        showDay
            ? Stack(alignment: Alignment.center, children: [
                Divider(
                  height: 40,
                  color: isDark ? AppColors.darkLine : AppColors.lightLine,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                  ),
                  child: Text(
                    DateFormat("yyyy년 M월 dd일")
                        .format((messageData["time"] as Timestamp).toDate())
                        .toString(),
                    style: TextStyle(
                      color: isDark ? AppColors.darkLine : AppColors.lightLine,
                    ),
                  ),
                )
              ])
            : Container(),
        //유저 입장 퇴장 알림바
        type == MessageType.notice
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isDark ? AppColors.darkTag : AppColors.lightTag,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(
                  "$name 님이 ${messageData["content"] == "left" ? "퇴장" : messageData["content"] == "enter" ? "입장" : ""}했습니다.",
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkHint : AppColors.lightHint),
                ),
              )
            : Align(
                //내 채팅버블이면 오른쪽 정렬, 상대버블이면 왼쪽 정렬
                alignment:
                    isOther ? Alignment.centerLeft : Alignment.centerRight,
                child: Row(
                  mainAxisAlignment:
                      //내 채팅버블이면 오른쪽 정렬, 상대버블이면 왼쪽 정렬
                      isOther ? MainAxisAlignment.start : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment:
                          //내 채팅버블이면 아래쪽, 상대버블이면 위쪽으로 정렬해서 프로필 사진이 위로 올라가게 한다
                          isOther
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                      children: [
                        //프로필을 보여줘야하고 상대방일 때 사진 표시
                        (showDay || viewSender) && isOther
                            ? GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                    Screen.otherProfile,
                                    pathParameters: {
                                      "uid": senderUid!,
                                      "readOnly": "true"
                                    },
                                  );
                                },
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15)),
                                  width: 50,
                                  height: 50,
                                  child:
                                      // Container()
                                      cachedProfileImage,
                                ),
                              )
                            : Container(
                                width: 50,
                              ),
                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                //왼쪽 안읽은 사람 수 표시(내 버블일 때)
                                !isOther
                                    ? Text(reader,
                                        style: const TextStyle(fontSize: 10))
                                    : Container(),
                                !isOther
                                    ? const SizedBox(width: 6)
                                    : Container(),
                              ],
                            ),
                            Row(
                              children: [
                                //왼쪽 시간표시 (시간을 보여줘야하고 내 버블일 때)
                                showTime && !isOther
                                    ? Text(
                                        timeStampToHourMinutes(
                                            messageData["time"]),
                                        style: const TextStyle(fontSize: 10))
                                    : Container(),
                                isOther
                                    ? Container()
                                    : const SizedBox(width: 6),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //프로필을 보여줘야 하고 상대방일 때 이름표시
                            (showDay || viewSender) && isOther
                                ? Text(name ?? "")
                                : Container(),
                            const SizedBox(height: 5),
                            //채팅 버블 부분
                            Container(
                              clipBehavior: Clip.hardEdge,
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.65),
                              decoration: BoxDecoration(
                                  color:
                                      //상대 채팅버블이면 회색, 내 채팅버블이면 초록
                                      isOther
                                          ? (isDark
                                              ? AppColors.darkTag
                                              : AppColors.lightTag)
                                          : Colors.green,
                                  borderRadius: (type != MessageType.text)
                                      ? const BorderRadius.all(
                                          Radius.circular(10))
                                      : isOther
                                          ? BorderRadius.only(
                                              topLeft: viewSender
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(10),
                                              bottomLeft:
                                                  const Radius.circular(10),
                                              bottomRight:
                                                  const Radius.circular(10),
                                              topRight:
                                                  const Radius.circular(10))
                                          : BorderRadius.only(
                                              topRight: viewSender
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(10),
                                              bottomLeft:
                                                  const Radius.circular(10),
                                              bottomRight:
                                                  const Radius.circular(10),
                                              topLeft:
                                                  const Radius.circular(10))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //채팅이 텍스트일 때 보여줄 곳
                                  if (type == MessageType.text)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Text(
                                        messageData["content"],
                                        style: TextStyle(
                                            color: isOther
                                                ? (isDark
                                                    ? AppColors.darkText
                                                    : AppColors.lightText)
                                                : Colors.black,
                                            fontSize: 16),
                                      ),
                                    ),
                                  //채팅이 사진일 때 보여줄 곳
                                  if (type == MessageType.picture)
                                    InstaImageViewer(child: cachedMediaImage),
                                  //채팅이 동영상일 때 보여줄 곳
                                  if (type == MessageType.video)
                                    InkWell(
                                      onTap: () {
                                        context.pushNamed(Screen.videoPlayer,
                                            pathParameters: {"url": videoUrl});
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          cachedMediaImage,
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            //오른쪽 안읽은 사람 수 표시(상대방 버블일 때)
                            isOther ? const SizedBox(width: 6) : Container(),
                            isOther
                                ? Text(reader,
                                    style: const TextStyle(fontSize: 10))
                                : Container(),
                          ],
                        ),
                        Row(
                          children: [
                            //오른쪽 시간표시 (시간을 보여줘야하고 상대방 버블일 때)
                            isOther ? const SizedBox(width: 6) : Container(),
                            showTime && isOther
                                ? Text(
                                    timeStampToHourMinutes(messageData["time"]),
                                    style: const TextStyle(fontSize: 10))
                                : Container(),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
      ],
    );
  }
}

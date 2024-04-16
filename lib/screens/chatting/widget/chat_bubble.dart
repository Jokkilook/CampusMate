import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/modules/enums.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

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

  const ChatBubble(
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
      this.reader = ""});

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    CachedNetworkImage cachedImage = CachedNetworkImage(
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

    return Column(
      children: [
        showDay
            ? Stack(alignment: Alignment.center, children: [
                const Divider(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: Colors.grey[50]),
                  child: Text(
                    DateFormat("yyyy년 M월 dd일")
                        .format((messageData["time"] as Timestamp).toDate())
                        .toString(),
                    style: const TextStyle(color: Colors.black54),
                  ),
                )
              ])
            : Container(),
        Align(
          //내 채팅버블이면 오른쪽 정렬, 상대버블이면 왼쪽 정렬
          alignment: isOther ? Alignment.centerLeft : Alignment.centerRight,
          child: Row(
            mainAxisAlignment:
                //내 채팅버블이면 오른쪽 정렬, 상대버블이면 왼쪽 정렬
                isOther ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment:
                    //내 채팅버블이면 아래쪽, 상대버블이면 위쪽으로 정렬해서 프로필 사진이 위로 올라가게 한다
                    isOther ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  //프로필을 보여줘야하고 상대방일 때 사진 표시
                  viewSender && isOther
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StrangerProfilScreen(
                                    uid: senderUid!, readOnly: true),
                              ),
                            );
                          },
                          child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15)),
                              width: 50,
                              height: 50,
                              child: cachedImage),
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
                          !isOther ? const SizedBox(width: 6) : Container(),
                        ],
                      ),
                      Row(
                        children: [
                          //왼쪽 시간표시 (시간을 보여줘야하고 내 버블일 때)
                          showTime && !isOther
                              ? Text(
                                  timeStampToHourMinutes(messageData["time"]),
                                  style: const TextStyle(fontSize: 10))
                              : Container(),
                          isOther ? Container() : const SizedBox(width: 6),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //프로필을 보여줘야 하고 상대방일 때 이름표시
                      viewSender && isOther ? Text(name ?? "") : Container(),
                      const SizedBox(height: 5),
                      Container(
                        // padding: const EdgeInsets.symmetric(
                        //     horizontal: 15, vertical: 10),
                        clipBehavior: Clip.hardEdge,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65),
                        decoration: BoxDecoration(
                            color:
                                //상대 채팅버블이면 회색, 내 채팅버블이면 초록
                                isOther ? Colors.grey[200] : Colors.green[400],
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (type == MessageType.text)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Text(
                                  messageData["content"],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            if (type == MessageType.picture)
                              GestureDetector(
                                onTap: () {
                                  // showImageViewer(
                                  //   context,
                                  //   CachedNetworkImageProvider(
                                  //       profileImageUrl!),
                                  // );
                                },
                                child: InstaImageViewer(
                                  child: CachedNetworkImage(
                                    imageUrl: profileImageUrl!,
                                    placeholder: (context, url) {
                                      return const Center(
                                        child: Icon(Icons
                                            .photo_size_select_actual_outlined),
                                      );
                                    },
                                  ),
                                ),
                                // CachedNetworkImage(
                                //   imageUrl: profileImageUrl!,
                                //   placeholder: (context, url) {
                                //     return const Center(
                                //       child: Icon(Icons
                                //           .photo_size_select_actual_outlined),
                                //     );
                                //   },
                                // ),
                              ),
                            if (type == MessageType.video)
                              const Text(
                                "이것은 비디오입니다.",
                                style: TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      //오른쪽 안읽은 사람 수 표시(상대방 버블일 때)
                      isOther ? const SizedBox(width: 6) : Container(),
                      isOther
                          ? Text(reader, style: const TextStyle(fontSize: 10))
                          : Container(),
                    ],
                  ),
                  Row(
                    children: [
                      //오른쪽 시간표시 (시간을 보여줘야하고 상대방 버블일 때)
                      isOther ? const SizedBox(width: 6) : Container(),
                      showTime && isOther
                          ? Text(timeStampToHourMinutes(messageData["time"]),
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

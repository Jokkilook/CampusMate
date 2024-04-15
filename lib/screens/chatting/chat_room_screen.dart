import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widget/chat_bubble.dart';

//ignore: must_be_immutable
class ChatRoomScreen extends StatelessWidget {
  ChatRoomScreen({super.key, required this.chatRoomData, this.isNew = false});

  ChatRoomData chatRoomData;
  bool isNew;
  final FocusNode focusNode = FocusNode();
  TextEditingController chatController = TextEditingController();
  final scrollController = ScrollController();
  ChattingService chat = ChattingService();
  AuthService auth = AuthService();
  String senderUID = "";
  String? userUID;

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    userUID = auth.getUID();
    List<String> senderData = [];
    String name = "";
    String imageUrl = "";
    bool isDuo = false;
    chatRoomData.participantsInfo!.forEach((key, value) {
      if (key != userUID) {
        senderUID = key;
        value.sort(
          (a, b) => a.length.compareTo(b.length),
        );
        senderData = value;
      }
    });

    name = senderData[0];
    imageUrl = senderData[1];

    if (chatRoomData.participantsUid!.length == 2) isDuo = true;

    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: const Text("채팅방 나가기"),
                    onTap: () async {
                      chat.leaveRoom(context, chatRoomData.roomId!, userUID!);
                    },
                  ),
                  PopupMenuItem(
                    child: const Text("신고하기"),
                    onTap: () {},
                  ),
                ];
              },
            )
          ],
          elevation: 2,
          shadowColor: Colors.black,
          title: Text(isDuo ? name : chatRoomData.roomName ?? ""),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chat.getChattingMessages(chatRoomData.roomId!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("에러발생"));
                  }

                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot<Object?>> docs =
                        snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(child: Text("채팅을 시작해보세요!"));
                    } else {
                      return GestureDetector(
                        onTap: () => focusNode.unfocus(),
                        child: Container(
                          color: Colors.grey[50],
                          height: double.infinity,
                          child: ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(10),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            reverse: true,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              bool isOther = true;
                              bool viewSender = false;
                              bool showTime = false;
                              bool showDay = false;
                              //메세지의 읽은 사람 리스트 반환
                              List<String> messageReaderList =
                                  (docs[index]["readers"] as List)
                                      .map((e) => e.toString())
                                      .toList();

                              //사용자가 읽은 사람 리스트에 포함되어 있지 않으면 추가 후 파이어스토어 업데이트
                              if (!messageReaderList.contains(userUID)) {
                                messageReaderList.add(userUID!);

                                chat.updateReader(chatRoomData.roomId!,
                                    docs[index].id, messageReaderList);
                              }

                              //채팅방 데이터에서 참여자 수 반환
                              int participantsCount = 0;
                              try {
                                participantsCount =
                                    chatRoomData.participantsUid!.length;
                              } catch (e) {}

                              //메세지 데이터에서 읽은 사람 수 반환
                              int readerCount = 0;
                              try {
                                readerCount = messageReaderList.length;
                              } catch (e) {}

                              //출력할 문자로 계산
                              String count = "";
                              try {
                                count = (participantsCount - readerCount)
                                    .toString();

                                count == "0" ? count = "" : null;
                              } catch (e) {}

                              try {
                                //시간출력 여부 결정 (한칸 아래의 메세지가 다른사람이 보낸것 이거나 보낸 시간이 다르면 showTime=true)
                                if (docs[index]["senderUID"] !=
                                        docs[index - 1]["senderUID"] ||
                                    timeStampToHourMinutes(
                                            docs[index]["time"]) !=
                                        timeStampToHourMinutes(
                                            docs[index - 1]["time"])) {
                                  showTime = true;
                                }
                              } catch (e) {
                                //한칸 아래 메세지가 없으면 시간 출력
                                showTime = true;
                              }

                              try {
                                //날짜 구분선 출력 여부 (한칸 위 메세지가 다른 날짜면 날짜 구분선 출력)
                                var currentDay =
                                    DateTime.fromMicrosecondsSinceEpoch(
                                            (docs[index]["time"] as Timestamp)
                                                .microsecondsSinceEpoch)
                                        .day;

                                var oneDayAgo =
                                    DateTime.fromMicrosecondsSinceEpoch(
                                            (docs[index + 1]["time"]
                                                    as Timestamp)
                                                .microsecondsSinceEpoch)
                                        .day;

                                if (currentDay != oneDayAgo) {
                                  showDay = true;
                                }
                              } catch (e) {
                                //한칸 위 메세지가 없으면 날짜 구분선 출력
                                showDay = true;
                              }

                              //메세지의 uid가 접속중인 유저와 같으면 MyChatUnit
                              if (docs[index]["senderUID"] == userUID) {
                                isOther = false;
                              }

                              try {
                                //한칸 위의 메세지의 uid와 현재 칸의 uid가 다르면 그 칸에 보낸 사람 표시(프로필과 이름)
                                if (docs[index]["senderUID"] !=
                                    docs[index + 1]["senderUID"]) {
                                  viewSender = true;
                                }
                              } catch (e) {
                                //한칸 위의 메세지가 없으면 보낸 사람 표시 출력

                                viewSender = true;
                              }

                              return ChatBubble(
                                isOther: isOther,
                                reader: count,
                                viewSender: viewSender,
                                name: name,
                                imageUrl: imageUrl,
                                showTime: showTime,
                                showDay: showDay,
                                messageData: docs[index],
                                index: index,
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            //하단 채팅 입력바
            Container(
              constraints: const BoxConstraints(maxHeight: 60),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //+버튼
                  FilledButton(
                      style: FilledButton.styleFrom(
                          fixedSize: const Size(60, 60),
                          backgroundColor: Colors.green,
                          shape: const ContinuousRectangleBorder()),
                      onPressed: () {
                        focusNode.requestFocus();
                      },
                      child: const Icon(Icons.add)),
                  //텍스트 입력창
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          focusNode: focusNode,
                          controller: chatController,
                          maxLines: 4,
                        )),
                  ),
                  //보내기 버튼
                  FilledButton(
                      style: FilledButton.styleFrom(
                          fixedSize: const Size(60, 60),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1000))),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(focusNode);
                        if (chatController.value.text == "") return;

                        String message = chatController.value.text;
                        chatController.value = TextEditingValue.empty;
                        MessageData data = MessageData(
                            senderUID: auth.getUID(),
                            content: message,
                            readers: [],
                            time: Timestamp.fromDate(DateTime.now()));

                        chat.sendMessage(
                            roomId: chatRoomData.roomId!, data: data);
                        if (scrollController.hasClients) {
                          scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

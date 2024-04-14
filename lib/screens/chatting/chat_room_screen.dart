import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widget/chat_bubble.dart';

//ignore: must_be_immutable
class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({super.key, required this.chatRoomData, this.isNew = false});

  ChatRoomData chatRoomData;
  bool isNew;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FocusNode focusNode = FocusNode();
  TextEditingController chatController = TextEditingController();
  final scrollController = ScrollController();
  ChattingService chat = ChattingService();
  AuthService auth = AuthService();
  String senderUID = "";
  String? userUID;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    focusNode.dispose();
    chatController.dispose();
    scrollController.dispose();
  }

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    for (var element in widget.chatRoomData.participantsUid!) {
      if (element != auth.getUID()) senderUID = element;
    }

    userUID = auth.getUID();

    return Scaffold(
      body: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: const Text("채팅방 나가기"),
                    onTap: () async {
                      var data = await FirebaseFirestore.instance
                          .collection("chats")
                          .doc(widget.chatRoomData.roomId)
                          .get();

                      List list = data.data()!["participantsUid"];
                      list.remove(userUID);

                      if (list.isEmpty) {
                        FirebaseFirestore.instance
                            .collection("chats")
                            .doc(widget.chatRoomData.roomId)
                            .delete()
                            .whenComplete(() => Navigator.pop(context));
                      } else {
                        FirebaseFirestore.instance
                            .collection("chats")
                            .doc(widget.chatRoomData.roomId)
                            .update({"participantsUid": list}).whenComplete(
                                () => Navigator.pop(context));
                      }
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
          title: Text(widget.chatRoomData.roomName ?? ""),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<DocumentSnapshot<Object>>(
                future: chat.getUserProfile(senderUID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    DocumentSnapshot<Object> doc = snapshot.data!;

                    if (doc.exists) {
                      String name = "";
                      String imageUrl =
                          "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/images%2Ftest.png?alt=media&token=4a231bcd-04fa-4220-9914-1028783f5f350";
                      try {
                        name = doc["name"];
                        imageUrl = doc["imageUrl"];
                      } catch (e) {
                        debugPrint(
                            ">>>>>>>>>>>>>>>>>>>>>>>>$e<<<<<<<<<<<<<<<<<<<<<<<<<<");
                      }
                      return StreamBuilder<QuerySnapshot>(
                        stream: chat
                            .getChattingMessages(widget.chatRoomData.roomId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

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
                                      if (!messageReaderList
                                          .contains(userUID)) {
                                        messageReaderList.add(userUID!);

                                        chat.updateReader(
                                            widget.chatRoomData.roomId!,
                                            docs[index].id,
                                            messageReaderList);
                                      }

                                      //채팅방 데이터에서 참여자 수 반환
                                      int participantsCount = 0;
                                      try {
                                        participantsCount = widget.chatRoomData
                                            .participantsUid!.length;
                                      } catch (e) {}

                                      //메세지 데이터에서 읽은 사람 수 반환
                                      int readerCount = 0;
                                      try {
                                        readerCount = messageReaderList.length;
                                      } catch (e) {}

                                      //출력할 문자로 계산
                                      String count = "";
                                      try {
                                        count =
                                            (participantsCount - readerCount)
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
                                                    (docs[index]["time"]
                                                            as Timestamp)
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

                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("데이터를 불러올 수 없습니다."),
                      );
                    }
                  }
                  return const Center(
                    child: Text("데이터를 불러올 수 없습니다."),
                  );
                },
              ),
            ),
            //채팅 입력바
            Container(
              constraints: const BoxConstraints(maxHeight: 70),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          shape: const ContinuousRectangleBorder()),
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
                            roomId: widget.chatRoomData.roomId!, data: data);
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

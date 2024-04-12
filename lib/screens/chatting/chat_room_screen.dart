import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/provider/chatting_data_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({super.key, required this.chatRoomData});
  TextEditingController chatController = TextEditingController();
  ChatRoomData chatRoomData;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  var chattings = [];
  Map<String, List<String>> nameMap = {};
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNamesAndImages();
  }

  void getNamesAndImages() async {
    for (var element in widget.chatRoomData.participantsUid!) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(element)
          .get()
          .then(
            (value) => nameMap[element] = [
              value["name"].toString(),
              value["imageUrl"].toString()
            ],
          );
    }
  }

  void sendMessage() async {
    if (widget.chatController.value.text == "") {
      return;
    }
    String message = widget.chatController.value.text;
    widget.chatController.value = TextEditingValue.empty;
    await FirebaseFirestore.instance
        .collection("chats/${widget.chatRoomData.roomId}/messages")
        .doc("${DateTime.now().microsecondsSinceEpoch}")
        .set(MessageData(
                senderUID: context.read<UserDataProvider>().userData.uid,
                content: message,
                time: Timestamp.fromDate(DateTime.now()))
            .toJson())
        .whenComplete(() {
      FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.chatRoomData.roomId)
          .update({
        "lastMessage": message,
        "lastMessageTime": Timestamp.fromDate(DateTime.now())
      });
    });
  }

  final image =
      "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/images%2Ftest.png?alt=media&token=4a231bcd-04fa-4220-9914-1028783f5f350";
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black,
          title: Text(widget.chatRoomData.roomName ?? ""),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                initialData: context
                    .read<ChattingDataProvider>()
                    .chattingCache[widget.chatRoomData.roomId],
                //  await FirebaseFirestore.instance
                //     .collection("chats/${widget.chatRoomData.roomId}/messages")
                //     .orderBy("time", descending: true)
                //     .get(const GetOptions(source: Source.cache)),
                stream: FirebaseFirestore.instance
                    .collection("chats/${widget.chatRoomData.roomId}/messages")
                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("에러발생"));
                  }

                  if (snapshot.hasData) {
                    var docs = snapshot.data!.docs;

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
                            bool showTime = false;
                            bool showDay = false;
                            try {
                              //시간출력 여부 결정 (한칸 아래의 메세지가 다른사람이 보낸것 이거나 보낸 시간이 다르면 showTime=true)
                              if (docs[index]["senderUID"] !=
                                      docs[index - 1]["senderUID"] ||
                                  timeStampToHourMinutes(docs[index]["time"]) !=
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
                                          docs[index]["time"]
                                              .microsecondsSinceEpoch)
                                      .day;

                              var oneDayAgo =
                                  DateTime.fromMicrosecondsSinceEpoch(
                                          docs[index + 1]["time"]
                                              .microsecondsSinceEpoch)
                                      .day;

                              if (currentDay != oneDayAgo) {
                                showDay = true;
                              }
                            } catch (e) {
                              //아님 랄로~!
                              showDay = false;
                            }

                            //메세지의 uid가 접속중인 유저와 같으면 MyChatUnit
                            if (docs[index]["senderUID"] ==
                                context.read<UserDataProvider>().userData.uid) {
                              return ChatBubble(
                                data: docs[index],
                                index: index,
                                showTime: showTime,
                                showDay: showDay,
                              );
                            }

                            try {
                              //한칸 위의 메세지의 uid와 현재 칸의 uid가 다르면 그 칸에 보낸 사람 표시(프로필과 이름)
                              if (docs[index]["senderUID"] !=
                                  docs[index + 1]["senderUID"]) {
                                return ChatBubble(
                                  isOther: true,
                                  data: docs[index],
                                  senderUid: docs[index]["senderUID"],
                                  viewSender: true,
                                  name: nameMap.isEmpty
                                      ? "알 수 없음"
                                      : nameMap[docs[index]["senderUID"]]![0],
                                  index: index,
                                  showTime: showTime,
                                  showDay: showDay,
                                  imageUrl: nameMap.isEmpty
                                      ? image
                                      : nameMap[docs[index]["senderUID"]]![1],
                                );
                              }
                            } catch (e) {
                              //한칸 위의 메세지가 없으면 보낸 사람 표시 출력
                              return ChatBubble(
                                isOther: true,
                                data: docs[index],
                                senderUid: docs[index]["senderUID"],
                                viewSender: true,
                                name: nameMap.isEmpty
                                    ? "알 수 없음"
                                    : nameMap[docs[index]["senderUID"]]![0],
                                index: index,
                                showTime: showTime,
                                showDay: showDay,
                                imageUrl: nameMap.isEmpty
                                    ? image
                                    : nameMap[docs[index]["senderUID"]]![1],
                              );
                            }

                            //다 아니면 보낸 사람 표시 안하고 말풍선만 출력
                            return ChatBubble(
                              isOther: true,
                              data: docs[index],
                              senderUid: docs[index]["senderUID"],
                              viewSender: false,
                              name: nameMap.isEmpty
                                  ? "알 수 없음"
                                  : nameMap[docs[index]["senderUID"]]![0],
                              index: index,
                              showTime: showTime,
                              showDay: showDay,
                              imageUrl: nameMap.isEmpty
                                  ? image
                                  : nameMap[docs[index]["senderUID"]]![1],
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
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
                          controller: widget.chatController,
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

                        sendMessage();
                        scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
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

class ChatBubble extends StatelessWidget {
  const ChatBubble(
      {super.key,
      required this.data,
      this.index = 0,
      this.showTime = false,
      this.showDay = true,
      this.isOther = false,
      this.viewSender = true,
      this.name,
      this.senderUid,
      this.imageUrl});

  final QueryDocumentSnapshot data;
  final int index;
  final bool showTime;
  final bool showDay;
  final bool isOther;
  final bool viewSender;
  final String? name;
  final String? senderUid;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
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
                        .format((data["time"] as Timestamp).toDate())
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
                                builder: (context) =>
                                    StrangerProfilScreen(uid: senderUid ?? ""),
                              ),
                            );
                          },
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            width: 50,
                            height: 50,
                            child: Image.network(
                                imageUrl ??
                                    "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/images%2Ftest.png?alt=media&token=4a231bcd-04fa-4220-9914-1028783f5f35",
                                fit: BoxFit.cover),
                          ),
                        )
                      : Container(
                          width: 50,
                        ),
                  const SizedBox(width: 10),
                  //왼쪽 시간표시 (시간을 보여줘야하고 내 버블일 때)
                  showTime && !isOther
                      ? Text(timeStampToHourMinutes(data["time"]),
                          style: const TextStyle(fontSize: 10))
                      : Container(),
                  isOther ? Container() : const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //프로필을 보여줘야 하고 상대방일 때 이름표시
                      viewSender && isOther ? Text(name ?? "") : Container(),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
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
                            Text(
                              data["content"],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              //오른쪽 시간표시 (시간을 보여줘야하고 상대방 버블일 때)
              isOther ? const SizedBox(width: 6) : Container(),
              showTime && isOther
                  ? Text(timeStampToHourMinutes(data["time"]),
                      style: const TextStyle(fontSize: 10))
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}

String timeStampToHourMinutes(Timestamp time) {
  var data = time.toDate().toString();
  var date = DateTime.parse(data);

  return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
}

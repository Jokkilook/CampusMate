import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:campusmate/widgets/input_text_field.dart';
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
    await FirebaseFirestore.instance
        .collection("chats/${widget.chatRoomData.roomId}/messages")
        .doc("${DateTime.now().microsecondsSinceEpoch}")
        .set(MessageData(
                senderUID: context.read<UserDataProvider>().userData.uid,
                content: widget.chatController.value.text,
                time: Timestamp.fromDate(DateTime.now()))
            .toJson())
        .whenComplete(() {
      widget.chatController.value = TextEditingValue.empty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        Navigator.pop(context);
      },
      child: Scaffold(
        body: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 2,
            shadowColor: Colors.black,
            title: Text(widget.chatRoomData.roomName ?? ""),
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            height: 70,
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
                      sendMessage();
                    },
                    child: const Icon(Icons.add)),
                //텍스트 입력창
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: InputTextField(
                    focusNode: focusNode,
                    controller: widget.chatController,
                    hintText: "메세지를 입력하세요.",
                  ),
                )),
                //보내기 버튼
                FilledButton(
                    style: FilledButton.styleFrom(
                        fixedSize: const Size(60, 60),
                        backgroundColor: Colors.green,
                        shape: const ContinuousRectangleBorder()),
                    onPressed: () {
                      focusNode.requestFocus();
                      sendMessage();
                    },
                    child: const Icon(Icons.send)),
              ],
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            // initialData: await FirebaseFirestore.instance
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

                return Container(
                  color: Colors.grey[50],
                  height: double.infinity,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      bool showTime = false;
                      try {
                        if (docs[index]["senderUID"] !=
                                docs[index - 1]["senderUID"] ||
                            timeStampToHourMinutes(docs[index]["time"]) !=
                                timeStampToHourMinutes(
                                    docs[index - 1]["time"])) {
                          showTime = true;
                        }
                      } catch (e) {
                        showTime = true;
                      }

                      if (docs[index]["senderUID"] ==
                          context.read<UserDataProvider>().userData.uid) {
                        return MyChatUnit(
                          data: docs[index],
                          index: index,
                          showTime: showTime,
                        );
                      }
                      try {
                        if (docs[index]["senderUID"] !=
                            docs[index + 1]["senderUID"]) {
                          return OtherChatUnit(
                            data: docs[index],
                            senderUid: docs[index]["senderUID"],
                            viewSender: true,
                            name: nameMap[docs[index]["senderUID"]]![0] ??
                                "안불러와졍",
                            index: index,
                            showTime: showTime,
                            imageUrl: nameMap[docs[index]["senderUID"]]![1],
                          );
                        }
                      } catch (e) {
                        print(">>>>>>>>>>>>>>>>$e<<<<<<<<<<<<<<<<<<<");
                        return OtherChatUnit(
                          data: docs[index],
                          senderUid: docs[index]["senderUID"],
                          viewSender: true,
                          name:
                              nameMap[docs[index]["senderUID"]]![0] ?? "안불러와졍",
                          index: index,
                          showTime: showTime,
                          imageUrl: nameMap[docs[index]["senderUID"]]![1],
                        );
                      }

                      return OtherChatUnit(
                        data: docs[index],
                        senderUid: docs[index]["senderUID"],
                        index: index,
                        showTime: showTime,
                        imageUrl: nameMap[docs[index]["senderUID"]]![1],
                      );
                    },
                  ),
                );
              }
              print(">>>>>>>>>>>>>>>>>>>>>this is it<<<<<<<<<<<<<<<<<<<<");
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

class MyChatUnit extends StatelessWidget {
  const MyChatUnit(
      {super.key, required this.data, this.index = 0, this.showTime = false});

  final QueryDocumentSnapshot data;
  final int index;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          showTime
              ? Text(timeStampToHourMinutes(data["time"]),
                  style: const TextStyle(fontSize: 10))
              : Container(),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["content"],
                  style: const TextStyle(fontSize: 16),
                ),
                //  Text("$index")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OtherChatUnit extends StatelessWidget {
  const OtherChatUnit(
      {super.key,
      required this.data,
      required this.senderUid,
      this.viewSender = false,
      this.name = "알 수 없음",
      this.index = 0,
      this.showTime = false,
      this.imageUrl = ""});

  final QueryDocumentSnapshot data;
  final bool viewSender;
  final String senderUid;
  final String name;
  final int index;
  final bool showTime;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              viewSender
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StrangerProfilScreen(uid: senderUid),
                          ),
                        );
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        width: 50,
                        height: 50,
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                    )
                  : Container(
                      width: 50,
                    ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  viewSender ? Text(name) : Container(),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
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
              // Text("$index")
            ],
          ),
          const SizedBox(width: 6),
          showTime
              ? Text(timeStampToHourMinutes(data["time"]),
                  style: const TextStyle(fontSize: 10))
              : Container(),
        ],
      ),
    );
  }
}

String timeStampToHourMinutes(Timestamp time) {
  var data = time.toDate().toString();
  var date = DateTime.parse(data);

  return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
}

import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({super.key, required this.chatRoomData});
  TextEditingController chatController = TextEditingController();
  ChatRoomData chatRoomData;
  DataBase db = DataBase();

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  var chattings = [];
  Map<String, String> nameMap = {};
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNames();
  }

  void getNames() async {
    widget.chatRoomData.participantsUid!.forEach((element) async {
      await widget.db.db
          .collection("users")
          .doc(element)
          .get()
          .then((value) => nameMap[element] = value["name"]);
    });
  }

  void sendMessage() {
    if (widget.chatController.value.text == "") {
      return;
    }
    widget.db.db
        .collection("chats/${widget.chatRoomData.roomId}/messages")
        .doc()
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
    return Scaffold(
      body: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black,
          title: Text(widget.chatRoomData.roomName ?? ""),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          height: 70,
          child: Row(
            children: [
              Expanded(
                  child: InputTextField(
                focusNode: focusNode,
                controller: widget.chatController,
                hintText: "메세지를 입력하세요.",
              )),
              const SizedBox(width: 10),
              IconButton(
                  onPressed: () {
                    focusNode.requestFocus();
                    sendMessage();
                  },
                  icon: const Icon(Icons.send))
            ],
          ),
        ),
        body: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: widget.db.db
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
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.white,
                    height: double.infinity,
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        bool showTime = false;
                        try {
                          if (snapshot.data!.docs[index]["senderUID"] !=
                                  snapshot.data!.docs[index - 1]["senderUID"] ||
                              timeStampToHourMinutes(
                                      snapshot.data!.docs[index]["time"]) !=
                                  timeStampToHourMinutes(
                                      snapshot.data!.docs[index - 1]["time"])) {
                            showTime = true;
                          }
                        } catch (e) {
                          showTime = true;
                        }

                        if (snapshot.data!.docs[index]["senderUID"] ==
                            context.read<UserDataProvider>().userData.uid) {
                          return MyChatUnit(
                              data: snapshot.data!.docs[index],
                              index: index,
                              showTime: showTime);
                        }
                        try {
                          if (snapshot.data!.docs[index]["senderUID"] !=
                              snapshot.data!.docs[index + 1]["senderUID"]) {
                            return OtherChatUnit(
                                data: snapshot.data!.docs[index],
                                viewSender: true,
                                name: nameMap[snapshot.data!.docs[index]
                                        ["senderUID"]] ??
                                    "안불러와졍",
                                index: index,
                                showTime: showTime);
                          }
                        } catch (e) {
                          return OtherChatUnit(
                              data: snapshot.data!.docs[index],
                              viewSender: true,
                              name: nameMap[snapshot.data!.docs[index]
                                      ["senderUID"]] ??
                                  "안불러와졍",
                              index: index,
                              showTime: showTime);
                        }

                        return OtherChatUnit(
                            data: snapshot.data!.docs[index],
                            index: index,
                            showTime: showTime);
                      },
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
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
          showTime ? Text(timeStampToHourMinutes(data["time"])) : Container(),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(10)),
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
      this.viewSender = false,
      this.name = "알 수 없음",
      this.index = 0,
      this.showTime = false});

  final QueryDocumentSnapshot data;
  final bool viewSender;
  final String name;
  final int index;
  final bool showTime;

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
                  ? const CircleAvatar(radius: 25)
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
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                        color: Colors.blue,
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
          showTime ? Text(timeStampToHourMinutes(data["time"])) : Container(),
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

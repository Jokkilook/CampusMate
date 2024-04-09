import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void sendMessage() {
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
          title: const Text('채팅상대닉네임'),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.amber,
          height: 70,
          child: Row(
            children: [
              Expanded(
                  child: InputTextField(
                controller: widget.chatController,
                hintText: "메세지를 입력하세요.",
              )),
              const SizedBox(width: 10),
              IconButton(
                  onPressed: () {
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
                    color: Colors.yellow,
                    height: double.infinity,
                    child: ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs[index]["senderUID"] ==
                            context.read<UserDataProvider>().userData.uid) {
                          return MyChatUnit(data: snapshot.data!.docs[index]);
                        }
                        return OtherChatUnit(data: snapshot.data!.docs[index]);
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
  MyChatUnit({super.key, required this.data});

  QueryDocumentSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
            color: Colors.green, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["content"],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(data["time"].toString()),
          ],
        ),
      ),
    );
  }
}

class OtherChatUnit extends StatelessWidget {
  OtherChatUnit({super.key, required this.data});

  QueryDocumentSnapshot data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["content"],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(data["time"].toString()),
          ],
        ),
      ),
    );
  }
}

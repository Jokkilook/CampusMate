import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//ignore: must_be_immutable
class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({super.key, required this.chatRoomData});
  TextEditingController chatController = TextEditingController();
  ChatRoomData chatRoomData;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              IconButton(onPressed: () {}, icon: const Icon(Icons.send))
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.yellow,
              height: double.infinity,
              child: ListView.builder(
                reverse: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const Column(
                    children: [
                      MyChatUnit(),
                      OtherChatUnit(),
                    ],
                  );
                },
              ),
            ),
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: Container(
            //     color: Colors.amber,
            //     height: 70,
            //     child: Row(
            //       children: [
            //         const Expanded(child: TextField()),
            //         IconButton(onPressed: () {}, icon: const Icon(Icons.send))
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

class MyChatUnit extends StatelessWidget {
  const MyChatUnit({super.key});

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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "fashflkajs",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text("12:00"),
          ],
        ),
      ),
    );
  }
}

class OtherChatUnit extends StatelessWidget {
  const OtherChatUnit({super.key});

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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "fashflkajs",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text("12:00"),
          ],
        ),
      ),
    );
  }
}

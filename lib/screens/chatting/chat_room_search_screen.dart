import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/widgets/chatting/chat_search_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//ignore: must_be_immutable
class ChatRoomSearchScreen extends StatefulWidget {
  ChatRoomSearchScreen({super.key});

  @override
  State<ChatRoomSearchScreen> createState() => _ChatRoomSearchScreenState();
  String searchWord = "";
}

class _ChatRoomSearchScreenState extends State<ChatRoomSearchScreen> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: 500,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back)),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                            controller: controller,
                            onChanged: (value) {
                              widget.searchWord = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Center(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: (controller.value.text == "")
                          ? FirebaseFirestore.instance
                              .collection("groupChats")
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection("groupChats")
                              .where("roomName",
                                  isGreaterThanOrEqualTo: controller.value.text)
                              .where("roomName",
                                  isLessThan: controller.value.text + "z")
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        // if (!snapshot.hasData) {
                        //   return const Text("일치하는 방이 없어요.");
                        // }
                        if (snapshot.hasData) {
                          var rooms = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              var roomData = ChatRoomData.fromJson(
                                  rooms[index].data() as Map<String, dynamic>);
                              return ChatSearchItem(data: roomData);
                            },
                          );
                        }
                        return const Text("방 이름을 검색해보세요!");
                        return ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ChatSearchItem(data: ChatRoomData());
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

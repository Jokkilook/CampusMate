import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/screens/chatting/widget/chat_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key});
  DataBase db = DataBase();

  @override
  State<ChatListScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>>? chatList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadChatList();
  }

  void loadChatList() async {
    await FirebaseFirestore.instance
        .collection("chats")
        .where("participantsUid",
            arrayContains: context.read<UserDataProvider>().userData.uid)
        .get()
        .then((value) {
      for (var snapshot in value.docs) {
        chatList!.add(snapshot.data());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text("채팅"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const AdArea(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .where("participantsUid",
                        arrayContains:
                            context.read<UserDataProvider>().userData.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasData) {
                    var rooms = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        return ChatListItem(
                          data: ChatRoomData(
                              roomName: rooms[index]["roomName"],
                              roomId: rooms[index]["roomId"],
                              lastText:
                                  rooms[index]["participantsUid"].toString(),
                              participantsUid:
                                  (rooms[index]["participantsUid"] as List)
                                      .map((e) => e.toString())
                                      .toList()),
                        );
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 70,
      ),
    );
  }
}

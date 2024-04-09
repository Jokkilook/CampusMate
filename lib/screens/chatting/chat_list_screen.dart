import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/chat_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key});
  DataBase db = DataBase();

  @override
  State<ChatListScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatListScreen> {
  var chatList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadChatList();
  }

  void loadChatList() async {
    var list = context.read<UserDataProvider>().userData.chatRoomList;
    if (list != null) {
      for (var room in list) {
        var data = await widget.db.db.collection("chats").doc(room).get();
        chatList.add(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text("채팅방"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const AdArea(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: chatList != null ? chatList.length : 5,
                itemBuilder: (context, index) {
                  return ChatListItem(
                    data: ChatRoomData(
                        roomName: "asd", roomId: "Asd", lastText: "asd"),
                  );
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

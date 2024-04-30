import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/chatting/widgets/chat_search_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ChatRoomSearchScreen extends StatefulWidget {
  ChatRoomSearchScreen({super.key});

  @override
  State<ChatRoomSearchScreen> createState() => _ChatRoomSearchScreenState();
  String searchWord = "";
}

class _ChatRoomSearchScreenState extends State<ChatRoomSearchScreen> {
  TextEditingController controller = TextEditingController();
  late UserData userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userData = context.read<UserDataProvider>().userData;
  }

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
                      const Divider(),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextField(
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            decoration: const InputDecoration(
                                hintText: "채팅방 제목을 검색해주세요!",
                                suffixIcon: Icon(Icons.search),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
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
                              .collection(
                                  "schools/${userData.school}/groupChats")
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection(
                                  "schools/${userData.school}/groupChats")
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
                        if (!snapshot.hasData) {
                          return const Text("일치하는 방이 없어요.");
                        }
                        if (snapshot.hasData) {
                          var rooms = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              var roomData = GroupChatRoomData.fromJson(
                                  rooms[index].data() as Map<String, dynamic>);
                              return InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        return Dialog(
                                          clipBehavior: Clip.hardEdge,
                                          shape: ContinuousRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: MediaQuery.of(_).size.width *
                                                0.8,
                                            color: Colors.amber,
                                            child: IntrinsicHeight(
                                              child: Column(
                                                children: [
                                                  Text(roomData.roomName!),
                                                  Text(roomData.description!),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(_);
                                                        Navigator.pop(context);
                                                        ChattingService()
                                                            .enterGroupRoom(
                                                                context,
                                                                roomData);
                                                      },
                                                      child:
                                                          const Text("입장하기")),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: ChatSearchItem(data: roomData));
                            },
                          );
                        }
                        return const Text("채팅방 제목을 검색해보세요!");
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

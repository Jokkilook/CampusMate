import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/community_screen.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/chatting/chat_list_item.dart';
import 'package:campusmate/screens/chatting/chat_room_search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key});
  DataBase db = DataBase();
  bool onCreating = false;

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
    String userUID = context.read<UserDataProvider>().userData.uid!;
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text("채팅"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomSearchScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "createRoom",
        child: widget.onCreating
            ? const CircularProgressIndicator()
            : const Icon(Icons.add, size: 30),
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFF0A351E),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController controller = TextEditingController();
              return Dialog(
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  child: Column(
                    children: [
                      const Text("단체 채팅방 만들기"),
                      const Text("방 이름"),
                      TextField(
                        controller: controller,
                      ),
                      TextButton(
                          onPressed: () async {
                            if (!widget.onCreating) {
                              widget.onCreating = true;
                              setState(() {});
                              await ChattingService().createGroupRoom(
                                  context, controller.value.text);
                              widget.onCreating = false;
                              setState(() {});
                            }
                          },
                          child: const Text("방 만들기"))
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Builder(builder: (_) {
              return const SizedBox(
                width: double.infinity,
                child: TabBar(
                  indicatorColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  enableFeedback: false,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(
                      child: Text("1:1 채팅"),
                    ),
                    Tab(
                      child: Text("단체 채팅"),
                    )
                  ],
                ),
              );
            }),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10), child: AdArea()),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(children: [
                //1:1 채팅방 리스트
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("chats")
                        .where("participantsUid", arrayContains: userUID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("오류가 발생했어요..ToT"));
                      }
                      if (!snapshot.hasData) {
                        return const Text("채팅방이 없습니다.");
                      }

                      if (snapshot.hasData) {
                        var rooms = snapshot.data!.docs;

                        if (rooms.isEmpty) {
                          return const Center(
                            child: Text("아직 채팅방이 없어요!"),
                          );
                        }

                        return ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            Map<String, List<String>> participantsInfo = {};
                            (rooms[index]["participantsInfo"] as Map)
                                .forEach((key, value) {
                              participantsInfo[key] = (value as List)
                                  .map((e) => e.toString())
                                  .toList();
                            });

                            //안읽은 메세지 수 스트림
                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(
                                      "chats/${rooms[index]["roomId"]}/messages")
                                  .where("time",
                                      isGreaterThan: rooms[index]["leavingTime"]
                                              [userUID] ??
                                          Timestamp.fromDate(DateTime.now()))
                                  .snapshots(),
                              builder: (context, messages) {
                                var data = messages.data?.docs ?? [];
                                int count = data.length;
                                return ChatListItem(
                                  unreadCount: count,
                                  isGroup: false,
                                  data: ChatRoomData(
                                      roomName: rooms[index]["roomName"],
                                      roomId: rooms[index]["roomId"],
                                      participantsUid: (rooms[index]
                                              ["participantsUid"] as List)
                                          .map((e) => e.toString())
                                          .toList(),
                                      participantsInfo: participantsInfo,
                                      lastMessage: rooms[index]["lastMessage"],
                                      lastMessageTime: rooms[index]
                                          ["lastMessageTime"]),
                                );
                              },
                            );
                          },
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
                //단체 채팅방 리스트
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("groupChats")
                        .where("participantsUid", arrayContains: userUID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("오류가 발생했어요..ToT"));
                      }
                      if (!snapshot.hasData) {
                        return const Text("채팅방이 없습니다.");
                      }

                      if (snapshot.hasData) {
                        var rooms = snapshot.data!.docs;

                        if (rooms.isEmpty) {
                          return const Center(
                            child: Text("아직 채팅방이 없어요!"),
                          );
                        }

                        return ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            Map<String, List<String>> participantsInfo = {};
                            (rooms[index]["participantsInfo"] as Map)
                                .forEach((key, value) {
                              participantsInfo[key] = (value as List)
                                  .map((e) => e.toString())
                                  .toList();
                            });

                            //안읽은 메세지 수 스트림
                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection(
                                      "groupChats/${rooms[index]["roomId"]}/messages")
                                  .where("time",
                                      isGreaterThan: rooms[index]["leavingTime"]
                                              [userUID] ??
                                          Timestamp.fromDate(DateTime.now()))
                                  .snapshots(),
                              builder: (context, messages) {
                                var data = messages.data?.docs ?? [];
                                int count = data.length;
                                return ChatListItem(
                                  unreadCount: count,
                                  isGroup: true,
                                  data: ChatRoomData(
                                      roomName: rooms[index]["roomName"],
                                      roomId: rooms[index]["roomId"],
                                      participantsUid: (rooms[index]
                                              ["participantsUid"] as List)
                                          .map((e) => e.toString())
                                          .toList(),
                                      participantsInfo: participantsInfo,
                                      lastMessage: rooms[index]["lastMessage"],
                                      lastMessageTime: rooms[index]
                                          ["lastMessageTime"]),
                                );
                              },
                            );
                          },
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ]),
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

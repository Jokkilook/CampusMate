import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/screens/community/community_screen.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/chatting/chat_list_item.dart';
import 'package:campusmate/screens/chatting/chat_room_search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key, required this.userData});
  UserData userData;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              TextEditingController titleController = TextEditingController();
              TextEditingController descController = TextEditingController();
              return Dialog(
                backgroundColor: Colors.white,
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Column(
                    children: [
                      const Text("단체 채팅방 만들기"),
                      const Text("방 이름"),
                      TextField(
                        controller: titleController,
                      ),
                      TextField(
                        controller: descController,
                      ),
                      TextButton(
                          onPressed: () async {
                            if (!widget.onCreating) {
                              widget.onCreating = true;
                              setState(() {});
                              await ChattingService().createGroupRoom(
                                  context: context,
                                  roomName: titleController.value.text,
                                  desc: descController.value.text,
                                  limit: 30);
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
            //탭 바
            const SizedBox(
              width: double.infinity,
              child: TabBar(
                indicatorColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                padding: EdgeInsets.symmetric(vertical: 5),
                enableFeedback: false,
                dividerColor: Colors.transparent,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(
                    color: Colors.black45,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    child: Text("1:1 채팅"),
                  ),
                  Tab(
                    child: Text("단체 채팅"),
                  )
                ],
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10), child: AdArea()),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(children: [
                //1:1 채팅방 리스트
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: ChattingService().getChattingList(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("오류가 발생했어요..ToT"));
                      }
                      if (!snapshot.hasData) {
                        return const Text("아직 채팅방이 없어요!");
                      }

                      if (snapshot.hasData) {
                        var rooms = snapshot.data!.docs;
                        //가져온 방 데이터 가장 최신 메세지가 온 순서로 정렬하기
                        rooms.sort(
                          (a, b) {
                            var aa = ChatRoomData.fromJson(
                                a.data() as Map<String, dynamic>);
                            var bb = ChatRoomData.fromJson(
                                b.data() as Map<String, dynamic>);
                            var aTime = aa.lastMessageTime!;
                            var bTime = bb.lastMessageTime!;
                            if (DateTime.parse(aTime.toDate().toString())
                                .isAfter(DateTime.parse(
                                    bTime.toDate().toString()))) {
                              return -1;
                            } else {
                              return 1;
                            }
                          },
                        );

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
                                      "schools/${widget.userData.school}/chats/${rooms[index]["roomId"]}/messages")
                                  .where("time",
                                      isGreaterThan: rooms[index]["leavingTime"]
                                              [widget.userData.uid] ??
                                          Timestamp.fromDate(DateTime.now()))
                                  .snapshots(),
                              builder: (context, messages) {
                                //안읽은 메세지에서 내가 보낸 메세지 빼기
                                //미디어 파일 전송 시 전송 누르고 완료 전에 화면을 나가면 내 화면에서도 안읽은 메세지로 표시되서 필터링 해줌
                                //파이어베이스에서 not in 쿼리를 지원해주지 않는다... 비교식 where 2번 쓰는 것도 안됌
                                var ref = messages.data?.docs ?? [];
                                var data = List.from(ref);
                                for (var element in ref) {
                                  if (element.get("senderUID") ==
                                      widget.userData.uid) {
                                    data.remove(element);
                                  }
                                }
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
                    stream: ChattingService()
                        .getChattingList(context, isGroup: true),
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
                                      "schools/${widget.userData.school}/groupChats/${rooms[index]["roomId"]}/messages")
                                  .where("time",
                                      isGreaterThan: rooms[index]["leavingTime"]
                                              [widget.userData.uid] ??
                                          Timestamp.fromDate(DateTime.now()))
                                  .snapshots(),
                              builder: (context, messages) {
                                //안읽은 메세지에서 내가 보낸 메세지 빼기
                                //미디어 파일 전송 시 전송 누르고 완료 전에 화면을 나가면 내 화면에서도 안읽은 메세지로 표시되서 필터링 해줌
                                var ref = messages.data?.docs ?? [];
                                var data = List.from(ref);
                                for (var element in ref) {
                                  if (element.get("senderUID") ==
                                      widget.userData.uid) {
                                    data.remove(element);
                                  }
                                }
                                int count = data.length;
                                return ChatListItem(
                                  unreadCount: count,
                                  isGroup: true,
                                  groupData: GroupChatRoomData.fromJson(
                                      rooms[index].data()
                                          as Map<String, dynamic>),
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

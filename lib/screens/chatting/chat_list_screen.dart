import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/services/chatting_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/screens/chatting/widgets/chat_list_item.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key});
  bool onCreating = false;

  @override
  State<ChatListScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>>? chatList = [];
  late TextEditingController titleController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("채팅"),
        actions: [
          IconButton(
              onPressed: () {
                context.pushNamed(Screen.chatRoomSearch);
              },
              icon: const Icon(Icons.search))
        ],
      ),
      //채팅방 생성 플로팅버튼
      floatingActionButton: FloatingActionButton(
        heroTag: "createRoom",
        backgroundColor: AppColors.button,
        foregroundColor: const Color(0xFF0A351E),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: () async {
          context.pushNamed(Screen.generateGroupRoom);
        },
        child: widget.onCreating
            ? const CircleLoading()
            : const Icon(Icons.add, size: 30),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            //탭 바
            SizedBox(
              width: double.infinity,
              child: TabBar(
                overlayColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                labelColor: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                indicatorColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                padding: const EdgeInsets.symmetric(vertical: 5),
                enableFeedback: false,
                dividerColor: Colors.transparent,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                    child: Text("1:1 채팅"),
                  ),
                  Tab(
                    child: Text("그룹 채팅"),
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
                StreamBuilder<QuerySnapshot>(
                  stream: ChattingService().getChattingRoomListStream(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircleLoading());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("오류가 발생했어요..ToT"));
                    }
                    if (!snapshot.hasData) {
                      return const Text("아직 채팅방이 없어요!");
                    }

                    if (snapshot.hasData) {
                      var rooms = snapshot.data!.docs;

                      if (rooms.isEmpty) {
                        return const Center(
                          child: Text("아직 채팅방이 없어요!"),
                        );
                      }

                      //가져온 방 데이터 가장 최신 메세지가 온 순서로 정렬하기
                      rooms.sort(
                        (a, b) {
                          var aa = ChatRoomData.fromJson(
                              a.data() as Map<String, dynamic>);
                          var bb = ChatRoomData.fromJson(
                              b.data() as Map<String, dynamic>);
                          var aTime = aa.lastMessageTime;
                          var bTime = bb.lastMessageTime;
                          if (DateTime.parse(
                                  aTime?.toDate().toString() ?? "20000101")
                              .isAfter(DateTime.parse(
                                  bTime?.toDate().toString() ?? "20000101"))) {
                            return -1;
                          } else {
                            return 1;
                          }
                        },
                      );

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
                                    "schools/${userData.school}/chats/${rooms[index]["roomId"]}/messages")
                                .where("time",
                                    isGreaterThan: rooms[index]["leavingTime"]
                                            [userData.uid] ??
                                        Timestamp.fromDate(DateTime.now()))
                                .snapshots(),
                            builder: (context, messages) {
                              //안읽은 메세지에서 내가 보낸 메세지 빼기
                              //미디어 파일 전송 시 전송 누르고 완료 전에 화면을 나가면 내 화면에서도 안읽은 메세지로 표시되서 필터링 해줌
                              //파이어베이스에서 not in 쿼리를 지원해주지 않는다... 비교식 where 2번 쓰는 것도 안됌
                              var ref = messages.data?.docs ?? [];
                              var data = List.from(ref);
                              for (var element in ref) {
                                if (element.get("senderUID") == userData.uid) {
                                  data.remove(element);
                                }
                              }
                              int count = data.length;

                              return ChatListItem(
                                isDark: isDark,
                                unreadCount: count,
                                isGroup: false,
                                roomData: ChatRoomData.fromJson(rooms[index]
                                    .data() as Map<String, dynamic>),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const CircleLoading();
                  },
                ),
                //단체 채팅방 리스트
                StreamBuilder<QuerySnapshot>(
                  stream: ChattingService()
                      .getChattingRoomListStream(context, isGroup: true),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircleLoading());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Column(
                        children: [
                          FilledButton(
                              onPressed: () {
                                setState(() {});
                              },
                              child: const Icon(Icons.refresh)),
                          const Text("오류가 발생했어요..ToT"),
                        ],
                      ));
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
                                    "schools/${userData.school}/groupChats/${rooms[index]["roomId"]}/messages")
                                .where("time",
                                    isGreaterThan: rooms[index]["leavingTime"]
                                            [userData.uid] ??
                                        Timestamp.fromDate(DateTime.now()))
                                .snapshots(),
                            builder: (context, messages) {
                              //안읽은 메세지에서 내가 보낸 메세지 빼기
                              //미디어 파일 전송 시 전송 누르고 완료 전에 화면을 나가면 내 화면에서도 안읽은 메세지로 표시되서 필터링 해줌
                              var ref = messages.data?.docs ?? [];
                              var data = List.from(ref);
                              for (var element in ref) {
                                if (element.get("senderUID") == userData.uid) {
                                  data.remove(element);
                                }
                                if (element.get("type") ==
                                    "MessageType.notice") {
                                  data.remove(element);
                                }
                              }
                              int count = data.length;
                              return ChatListItem(
                                isDark: isDark,
                                unreadCount: count,
                                isGroup: true,
                                groupRoomData: GroupChatRoomData.fromJson(
                                    rooms[index].data()
                                        as Map<String, dynamic>),
                                roomData: ChatRoomData.fromJson(rooms[index]
                                    .data() as Map<String, dynamic>),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const CircleLoading();
                  },
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

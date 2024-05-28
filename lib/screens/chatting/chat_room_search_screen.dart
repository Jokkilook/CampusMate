import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/services/chatting_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/chatting/widgets/chat_search_item.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
  }

  String timeStampToYYYYMMDD({Timestamp? time, String? stringTime}) {
    if (time != null) {
      var data = time.toDate().toString();
      var date = DateTime.parse(data);
      return "${NumberFormat("0000").format(date.year)}년 ${NumberFormat("00").format(date.month)}월 ${NumberFormat("00").format(date.day)}일";
    } else if (stringTime != null) {
      var date = DateTime.fromMillisecondsSinceEpoch(int.parse(stringTime));
      return "${NumberFormat("0000").format(date.year)}년 ${NumberFormat("00").format(date.month)}월 ${NumberFormat("00").format(date.day)}일";
    }

    return "0000년 00월 00일";
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  //검색 바
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(Icons.arrow_back)),
                      const Divider(),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark
                                ? AppColors.darkSearchInput
                                : AppColors.lightSearchInput,
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
                Expanded(
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
                                  isLessThan: "${controller.value.text}z")
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleLoading();
                        }
                        if (!snapshot.hasData) {
                          return const Text("일치하는 방이 없어요.");
                        }
                        if (snapshot.hasData) {
                          var rooms = snapshot.data!.docs;
                          if (rooms.isEmpty) {
                            return const Center(
                              child: Text("생성된 단체 채팅방이 존재하지 않아요 ToT"),
                            );
                          }
                          return ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              var roomData = GroupChatRoomData.fromJson(
                                  rooms[index].data() as Map<String, dynamic>);
                              return InkWell(
                                  onTap: () async {
                                    var creatorData = await AuthService()
                                        .getUserData(
                                            uid: roomData.creatorUid ?? "");

                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        return Dialog(
                                          clipBehavior: Clip.hardEdge,
                                          shape: ContinuousRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            width: MediaQuery.of(_).size.width *
                                                0.8,
                                            child: IntrinsicHeight(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        //방 이름
                                                        Text(
                                                          roomData.roomName!,
                                                          style: TextStyle(
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isDark
                                                                ? AppColors
                                                                    .darkTitle
                                                                : AppColors
                                                                    .lightTitle,
                                                          ),
                                                        ),
                                                        //방 정보
                                                        Text(
                                                          "방장: ${creatorData.name}",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark
                                                                ? AppColors
                                                                    .darkHint
                                                                : AppColors
                                                                    .lightHint,
                                                          ),
                                                        ),
                                                        Text(
                                                          "생성일: ${timeStampToYYYYMMDD(time: roomData.createdTime)}",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark
                                                                ? AppColors
                                                                    .darkHint
                                                                : AppColors
                                                                    .lightHint,
                                                          ),
                                                        ),
                                                        const Divider(),
                                                        //방 설명
                                                        Text(
                                                          roomData.description!,
                                                          style: TextStyle(
                                                            color: isDark
                                                                ? AppColors
                                                                    .darkText
                                                                : AppColors
                                                                    .lightText,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(_);
                                                        context.pop();
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

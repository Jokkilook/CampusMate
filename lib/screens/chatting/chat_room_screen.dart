import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:campusmate/modules/enums.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:campusmate/widgets/chatting/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

//ignore: must_be_immutable
class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({super.key, required this.chatRoomData, this.isNew = false});

  ChatRoomData chatRoomData;
  bool isNew;
  XFile? media;
  MessageType type = MessageType.picture;
  VideoPlayerController? videoPlayerController;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FocusNode focusNode = FocusNode();

  TextEditingController chatController = TextEditingController();

  final scrollController = ScrollController();

  ChattingService chat = ChattingService();

  AuthService auth = AuthService();

  String senderUID = "";

  String? userUID;
  bool prepareMedia = false;

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    userUID = auth.getUID();
    List<String> senderData = [];
    String name = "";
    String imageUrl = "";
    bool isDuo = false;

    widget.chatRoomData.participantsInfo!.forEach((key, value) {
      if (key != userUID) {
        senderUID = key;
        value.sort(
          (a, b) => a.length.compareTo(b.length),
        );
        senderData = value;
      }
    });

    name = senderData[0];
    imageUrl = senderData[1];

    if (widget.chatRoomData.participantsUid!.length == 2) isDuo = true;

    return PopScope(
      //스크린이 팝 될 때 실행될 이벤트 ( 채팅방 화면을 나간 시간 저장 )
      onPopInvoked: (didPop) async {
        await chat.firestore
            .collection("chats")
            .doc(widget.chatRoomData.roomId)
            .set({
          "leavingTime": {userUID: Timestamp.fromDate(DateTime.now())}
        }, SetOptions(merge: true));
      },
      child: Scaffold(
        body: Scaffold(
          appBar: AppBar(
            actions: [
              Builder(builder: (context) {
                return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.more_vert));
              }),
            ],
            elevation: 2,
            shadowColor: Colors.black,
            title: Text(isDuo ? name : widget.chatRoomData.roomName ?? ""),
          ),
          endDrawer: Drawer(
            shape: const ContinuousRectangleBorder(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "대화상대",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          widget.chatRoomData.participantsUid!.length - 1,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StrangerProfilScreen(
                                      uid: senderUID, readOnly: true),
                                ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            width: double.infinity,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    width: 50,
                                    height: 50,
                                    imageUrl: imageUrl,
                                    placeholder: (context, url) {
                                      return Image.asset(
                                          "assets/images/default_image.png");
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.black),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Builder(builder: (context) {
                            return InkWell(
                              onTap: () async {
                                Scaffold.of(context).closeEndDrawer();
                                chat.leaveRoom(context,
                                    widget.chatRoomData.roomId!, userUID!);
                              },
                              child: const SizedBox(
                                height: 40,
                                child: Center(
                                  child: Text("나가기",
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black)),
                                ),
                              ),
                            );
                          }),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {},
                            child: const SizedBox(
                              height: 40,
                              child: Center(
                                child: Text("신고하기",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              //채팅 메세지 표시 부분
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chat.getChattingMessages(widget.chatRoomData.roomId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("에러발생"));
                    }

                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot<Object?>> docs =
                          snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Center(child: Text("채팅을 시작해보세요!"));
                      } else {
                        return GestureDetector(
                          onTap: () {
                            prepareMedia = false;
                            focusNode.unfocus();
                            setState(() {});
                          },
                          child: Container(
                            color: Colors.grey[50],
                            height: double.infinity,
                            child: ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.all(10),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              reverse: true,
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                bool isOther = true;
                                bool viewSender = false;
                                bool showTime = false;
                                bool showDay = false;
                                //메세지의 읽은 사람 리스트 반환
                                List<String> messageReaderList =
                                    (docs[index]["readers"] as List)
                                        .map((e) => e.toString())
                                        .toList();

                                //사용자가 읽은 사람 리스트에 포함되어 있지 않으면 추가 후 파이어스토어 업데이트
                                if (!messageReaderList.contains(userUID)) {
                                  messageReaderList.add(userUID!);

                                  chat.updateReader(widget.chatRoomData.roomId!,
                                      docs[index].id, messageReaderList);
                                }

                                //채팅방 데이터에서 참여자 수 반환
                                int participantsCount = 0;
                                try {
                                  participantsCount = widget
                                      .chatRoomData.participantsUid!.length;
                                } catch (e) {}

                                //메세지 데이터에서 읽은 사람 수 반환
                                int readerCount = 0;
                                try {
                                  readerCount = messageReaderList.length;
                                } catch (e) {}

                                //출력할 문자로 계산
                                String count = "";
                                try {
                                  count = (participantsCount - readerCount)
                                      .toString();

                                  count == "0" ? count = "" : null;
                                } catch (e) {}

                                try {
                                  //시간출력 여부 결정 (한칸 아래의 메세지가 다른사람이 보낸것 이거나 보낸 시간이 다르면 showTime=true)
                                  if (docs[index]["senderUID"] !=
                                          docs[index - 1]["senderUID"] ||
                                      timeStampToHourMinutes(
                                              docs[index]["time"]) !=
                                          timeStampToHourMinutes(
                                              docs[index - 1]["time"])) {
                                    showTime = true;
                                  }
                                } catch (e) {
                                  //한칸 아래 메세지가 없으면 시간 출력
                                  showTime = true;
                                }

                                try {
                                  //날짜 구분선 출력 여부 (한칸 위 메세지가 다른 날짜면 날짜 구분선 출력)
                                  var currentDay =
                                      DateTime.fromMicrosecondsSinceEpoch(
                                              (docs[index]["time"] as Timestamp)
                                                  .microsecondsSinceEpoch)
                                          .day;

                                  var oneDayAgo =
                                      DateTime.fromMicrosecondsSinceEpoch(
                                              (docs[index + 1]["time"]
                                                      as Timestamp)
                                                  .microsecondsSinceEpoch)
                                          .day;

                                  if (currentDay != oneDayAgo) {
                                    showDay = true;
                                  }
                                } catch (e) {
                                  //한칸 위 메세지가 없으면 날짜 구분선 출력
                                  showDay = true;
                                }

                                //메세지의 uid가 접속중인 유저와 같으면 MyChatUnit
                                if (docs[index]["senderUID"] == userUID) {
                                  isOther = false;
                                }

                                try {
                                  //한칸 위의 메세지의 uid와 현재 칸의 uid가 다르면 그 칸에 보낸 사람 표시(프로필과 이름)
                                  if (docs[index]["senderUID"] !=
                                      docs[index + 1]["senderUID"]) {
                                    viewSender = true;
                                  }
                                } catch (e) {
                                  //한칸 위의 메세지가 없으면 보낸 사람 표시 출력
                                  viewSender = true;
                                }

                                return ChatBubble(
                                  type: stringToEnumMessageType(
                                      docs[index]["type"]),
                                  isOther: isOther,
                                  reader: count,
                                  senderUid: docs[index]["senderUID"],
                                  viewSender: viewSender,
                                  name: name,
                                  profileImageUrl: imageUrl,
                                  showTime: showTime,
                                  showDay: showDay,
                                  messageData: docs[index],
                                  index: index,
                                );
                              },
                            ),
                          ),
                        );
                      }
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              //하단 채팅 입력바
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //+버튼
                        InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () {
                            focusNode.unfocus();
                            prepareMedia = true;
                            setState(() {});
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                //margin: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  //borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),

                        //텍스트 입력창
                        widget.media == null
                            ? Expanded(
                                child: TextFormField(
                                  onTap: () {
                                    prepareMedia = false;
                                    setState(() {});
                                  },
                                  focusNode: focusNode,
                                  controller: chatController,
                                  minLines: 1,
                                  maxLines: 4,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      hintText: "메세지를 입력하세요.",
                                      hintStyle: const TextStyle(fontSize: 14),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10)),
                                ),
                              )
                            : Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (widget.type == MessageType.picture)
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Image.file(
                                          height: 100,
                                          File(widget.media!.path),
                                        ),
                                      ),
                                    if (widget.type == MessageType.video)
                                      Container(
                                          padding: const EdgeInsets.all(5),
                                          height: 100,
                                          child: VideoPlayer(
                                              widget.videoPlayerController!)),
                                    InkWell(
                                      onTap: () {
                                        widget.media = null;
                                        setState(() {});
                                      },
                                      child: Container(
                                        child: const Icon(Icons.cancel),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        //보내기 버튼
                        InkWell(
                          radius: 10,
                          highlightColor: Colors.amber,
                          //borderRadius: BorderRadius.circular(100),
                          onTap: () {
                            prepareMedia ? null : focusNode.requestFocus();
                            //입력창이 비었거나 미디어파일 올라간 게 없으면 아무것도 하지 않음
                            if (chatController.value.text == "" &&
                                widget.media == null) return;
                            MessageData data;
                            String content;
                            if (widget.media != null) {
                              String extension =
                                  path.extension(widget.media!.path);

                              if (extension == ".jpeg" ||
                                  extension == ".jpg" ||
                                  extension == ".bmp" ||
                                  extension == ".webp" ||
                                  extension == ".png") {
                                widget.type = MessageType.picture;
                              }

                              if (extension == ".mp4" ||
                                  extension == ".avi" ||
                                  extension == ".webm" ||
                                  extension == ".mkv" ||
                                  extension == ".mov" ||
                                  extension == ".wmv") {
                                widget.type = MessageType.video;
                              }

                              data = MessageData(
                                  type: widget.type,
                                  senderUID: auth.getUID(),
                                  content: "",
                                  readers: [],
                                  time: Timestamp.fromDate(DateTime.now()));

                              chat.sendMedia(
                                  widget.chatRoomData, data, widget.media!);

                              widget.media = null;
                              setState(() {});
                            } else {
                              //미디어 파일이 아니면 텍스트 전송
                              content = chatController.value.text;
                              chatController.value = TextEditingValue.empty;
                              data = MessageData(
                                  type: MessageType.text,
                                  senderUID: auth.getUID(),
                                  content: content,
                                  readers: [],
                                  time: Timestamp.fromDate(DateTime.now()));

                              chat.sendMessage(
                                  roomId: widget.chatRoomData.roomId!,
                                  data: data);
                              if (scrollController.hasClients) {
                                scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                //margin: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  //borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              const Icon(
                                Icons.send,
                                size: 18,
                                color: Colors.white,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  prepareMedia
                      ? Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.3,
                          color: Colors.grey[200],
                          child: Center(
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MediaButton(
                                    icon: Icons.photo_library_outlined,
                                    text: "사진",
                                    onTap: () async {
                                      widget.media = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (widget.media != null) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  MediaButton(
                                    icon: Icons.video_library_outlined,
                                    text: "동영상",
                                    onTap: () async {
                                      widget.media = await ImagePicker()
                                          .pickVideo(
                                              source: ImageSource.gallery);

                                      widget.videoPlayerController =
                                          VideoPlayerController.file(
                                              File(widget.media!.path));

                                      if (widget.media != null) {
                                        debugPrint(path
                                            .extension(widget.media!.path)
                                            .toString());
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  MediaButton(
                                    icon: Icons.camera_alt_outlined,
                                    text: "카메라",
                                    onTap: () async {
                                      widget.media = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.camera);
                                      if (widget.media != null) {
                                        setState(() {});
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class MediaButton extends StatelessWidget {
  final String text;
  final IconData icon;
  Function()? onTap;

  MediaButton({super.key, required this.text, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100)),
              ),
              Icon(icon)
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(text)
      ],
    );
  }
}

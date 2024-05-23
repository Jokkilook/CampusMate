import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/services/chatting_service.dart';
import 'package:campusmate/modules/enums.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:campusmate/screens/chatting/video_player_screen.dart';
import 'package:campusmate/screens/chatting/widgets/chat_bubble.dart';
import 'package:campusmate/services/noti_service.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

//ignore: must_be_immutable
class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen(
      {super.key,
      required this.chatRoomData,
      this.groupRoomData,
      this.isGroup = false});

  ChatRoomData chatRoomData;
  GroupChatRoomData? groupRoomData;
  bool isGroup;
  XFile? media;
  File? thumbnail;
  MessageType type = MessageType.text;
  VideoPlayerController? videoPlayerController;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FocusNode focusNode = FocusNode();

  late final TextEditingController chatController;

  late final ScrollController scrollController;

  late final ChattingService chat;

  late final AuthService auth;
  late final UserData userData;

  String senderUID = "";
  UserData? chatUser;
  List<UserData?> groupChatUsers = [];
  String? userUID;
  bool prepareMedia = false;
  bool isCompletelyLeaving = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    chatController = TextEditingController();
    scrollController = ScrollController();
    chat = ChattingService();
    auth = AuthService();
    userData = context.read<UserDataProvider>().userData;

    getChatUserData();
  }

  Future getChatUserData() async {
    //그룹 챗이면 참여자 데이터 모두 반환
    if (widget.isGroup) {
      for (var uid in widget.chatRoomData.participantsUid ?? []) {
        groupChatUsers.add(await auth.getUserData(uid: uid));
      }
    }
    //1:1 챗이면 상대 데이터 하나 반환
    else {
      for (var uid in widget.chatRoomData.participantsUid ?? []) {
        if (!(uid == userData.uid)) chatUser = await auth.getUserData(uid: uid);
      }
    }
  }

  String timeStampToHourMinutes(Timestamp time) {
    var data = time.toDate().toString();
    var date = DateTime.parse(data);

    return "${NumberFormat("00").format(date.hour)}:${NumberFormat("00").format(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    userUID = auth.getUID();
    String name = "";
    Map<String, List<String>> userInfo = {};
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    List<String> list;
    widget.chatRoomData.participantsInfo?.forEach((key, value) {
      value.sort(
        (a, b) => a.length.compareTo(b.length),
      );
      list = value;
      userInfo[key] = list;
    });

    if (!widget.isGroup) {
      userInfo.forEach((key, value) {
        if (key != userUID) {
          name = value[0];
        }
      });
    }

    return PopScope(
      //스크린이 팝 될 때 실행될 이벤트 ( 채팅방 화면을 나간 시간 저장 )
      onPopInvoked: (didPop) async {
        if (!isCompletelyLeaving) {
          chat.recordLeavingTime(
              isGroup: widget.isGroup,
              userData,
              widget.chatRoomData.roomId ?? "boo");
        }
      },
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: chat.getChatRoomDataStream(
              userData, widget.chatRoomData.roomId ?? "boo",
              isGroup: widget.isGroup),
          builder: (context, roomSnapshot) {
            if (roomSnapshot.hasError) {
              return const Center(child: CircleLoading());
            }

            if (roomSnapshot.hasData) {
              var roomData = roomSnapshot.data!;
              int count = 0;
              try {
                count = (roomData["participantsUid"] as List).length;
              } catch (e) {
                count = 0;
              }

              return Scaffold(
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
                  title: Text(
                      !widget.isGroup ? name : (roomData["roomName"] ?? "")),
                ),

                //드로어
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
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: count,
                            itemBuilder: (context, index) {
                              bool isCreator = widget
                                      .groupRoomData?.creatorUid ==
                                  widget.chatRoomData.participantsUid?[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StrangerProfilScreen(
                                                uid: widget.chatRoomData
                                                    .participantsUid![index],
                                                readOnly: true),
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
                                          imageUrl: roomData["participantsInfo"]
                                              [roomData["participantsUid"]
                                                  [index]][1],
                                          placeholder: (context, url) {
                                            return Image.asset(
                                                "assets/images/default_image.png");
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: isCreator ? 10 : 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          isCreator
                                              ? Icon(
                                                  Icons.star,
                                                  color: Colors.yellow[700],
                                                  size: 17,
                                                )
                                              : Container(),
                                          Text(
                                            roomData["participantsUid"]
                                                        [index] ==
                                                    userUID
                                                ? "나"
                                                : roomData["participantsInfo"][
                                                    roomData["participantsUid"]
                                                        [index]][0],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: isDark
                                                  ? AppColors.darkText
                                                  : AppColors.lightText,
                                            ),
                                          ),
                                        ],
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
                                child: Builder(builder: (_) {
                                  return InkWell(
                                    onTap: () async {
                                      isCompletelyLeaving = true;

                                      Scaffold.of(_).closeEndDrawer();
                                      if (widget.isGroup) {
                                        chat.leaveGroupChatRoom(
                                            context: context,
                                            userData: userData,
                                            roomId:
                                                widget.groupRoomData!.roomId!);
                                      }
                                      chat.leaveOTOChatRoom(
                                        context: context,
                                        userData: userData,
                                        roomId: widget.chatRoomData.roomId!,
                                      );
                                    },
                                    child: SizedBox(
                                      height: 40,
                                      child: Center(
                                        child: Text(
                                          "나가기",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              Expanded(
                                child: Builder(builder: (_) {
                                  return InkWell(
                                    onTap: () async {
                                      Scaffold.of(_).closeEndDrawer();
                                    },
                                    child: SizedBox(
                                      height: 40,
                                      child: Center(
                                        child: Text(
                                          "신고하기",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
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
                        stream: chat.getChattingMessagesStream(context,
                            roomId: widget.chatRoomData.roomId ?? "boo",
                            isGroup: widget.isGroup),
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
                                  color: isDark
                                      ? AppColors.darkBackground
                                      : AppColors.lightBackground,
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
                                      if (!messageReaderList
                                          .contains(userUID)) {
                                        messageReaderList.add(userUID!);

                                        chat.updateReader(
                                            isGroup: widget.isGroup,
                                            context,
                                            widget.chatRoomData.roomId!,
                                            docs[index].id,
                                            messageReaderList);
                                      }

                                      //채팅방 데이터에서 참여자 수 반환
                                      int participantsCount = 0;
                                      try {
                                        participantsCount = widget.chatRoomData
                                            .participantsUid!.length;
                                      } catch (e) {
                                        //
                                      }

                                      //메세지 데이터에서 읽은 사람 수 반환
                                      int readerCount = 0;
                                      try {
                                        readerCount = messageReaderList.length;
                                      } catch (e) {
                                        //
                                      }

                                      //출력할 문자로 계산
                                      String count = "";
                                      int county =
                                          (participantsCount - readerCount);
                                      try {
                                        count = county <= 0
                                            ? ""
                                            : county.toString();
                                      } catch (e) {
                                        //
                                      }

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
                                        //한칸 아래 메세지에 채팅방 출입 알림이 있으면 시간 출력
                                        else if (docs[index - 1]["type"] ==
                                            "MessageType.notice") {
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
                                                    (docs[index]["time"]
                                                            as Timestamp)
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
                                        //한칸 위의 메세지가 없으면 보낸 사람 출력
                                        viewSender = true;
                                      }

                                      try {
                                        //한칸 위의 메세지의 타입이 notice 이면 보낸 사람 출력
                                        if (docs[index + 1]["type"] ==
                                            "MessageType.notice") {
                                          viewSender = true;
                                        }
                                      } catch (e) {
                                        //한칸 위의 메세지가 없으면 보낸 사람 출력
                                        viewSender = true;
                                      }
                                      String name = "알 수 없음";
                                      String imageUrl = "";
                                      //    "https://firebasestorage.googleapis.com/v0/b/classmate-81447.appspot.com/o/test.png?alt=media&token=43db937e-0bba-4c89-a9f6-dff0387c8d45";
                                      if ((widget.chatRoomData.participantsUid
                                              ?.contains(
                                                  docs[index]["senderUID"]) ??
                                          false)) {
                                        name = userInfo[docs[index]
                                            ["senderUID"]]![0];
                                        imageUrl = userInfo[docs[index]
                                            ["senderUID"]]![1];
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
                                        isDark: isDark,
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                          return const Center(child: CircleLoading());
                        },
                      ),
                    ),
                    //미디어 전송 로딩 알림바
                    isSending
                        ? Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  " ${widget.type == MessageType.picture ? "사진" : widget.type == MessageType.video ? "동영상" : "미디어"} 전송 중...",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: CircleLoading(),
                                    ))
                              ],
                            ),
                          )
                        : Container(),
                    //하단 채팅 입력바
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkInput
                                    : AppColors.lightInput),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                //+버튼
                                InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        constraints:
                                            const BoxConstraints(minHeight: 50),
                                        width: 50,
                                        //margin: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          //borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                      Icon(
                                        prepareMedia ? Icons.close : Icons.add,
                                        color: AppColors.buttonText,
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    if (prepareMedia) {
                                      focusNode.requestFocus();
                                      prepareMedia = false;
                                    } else {
                                      focusNode.unfocus();
                                      prepareMedia = true;
                                    }

                                    setState(() {});
                                  },
                                ),
                                //텍스트 입력창
                                (widget.media == null || isSending)
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
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          decoration: InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              hintText: "메세지를 입력하세요.",
                                              hintStyle:
                                                  const TextStyle(fontSize: 14),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10)),
                                        ),
                                      )
                                    //미디어 표시 창
                                    : Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            //사진이 올라가 있을 때 보여줄 필드
                                            if (widget.type ==
                                                MessageType.picture)
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Image.file(
                                                  height: 100,
                                                  File(widget.media!.path),
                                                ),
                                              ),
                                            //비디오가 올라가 있을 때 보여줄 필드
                                            if (widget.type ==
                                                MessageType.video)
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoPlayerScreen(
                                                              file:
                                                                  widget.media),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    height: 100,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Image.file(
                                                          File(widget
                                                              .thumbnail!.path),
                                                        ),
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          child: Container(
                                                            height: 30,
                                                            width: 30,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.4),
                                                          ),
                                                        ),
                                                        const Icon(
                                                          Icons.play_arrow,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    )),
                                              ),
                                            InkWell(
                                              onTap: () {
                                                widget.media = null;
                                                widget.type = MessageType.text;
                                                setState(() {});
                                              },
                                              child: const Icon(Icons.cancel),
                                            )
                                          ],
                                        ),
                                      ),
                                //보내기 버튼
                                InkWell(
                                  radius: 10,
                                  //borderRadius: BorderRadius.circular(100),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        constraints:
                                            const BoxConstraints(minHeight: 50),
                                        width: 50,
                                        //margin: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          //borderRadius: BorderRadius.circular(100),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.send,
                                        size: 18,
                                        color: AppColors.buttonText,
                                      )
                                    ],
                                  ),
                                  onTap: () async {
                                    prepareMedia
                                        ? null
                                        : focusNode.requestFocus();
                                    //입력창이 비었거나 미디어파일 올라간 게 없으면 아무것도 하지 않음
                                    if (chatController.value.text == "" &&
                                        widget.media == null) return;

                                    //입력창에 메세지가 있거나 미디어 파일이 있으면 메세지 데이터 준비
                                    MessageData data;
                                    String content = "";

                                    //미디어가 비어있지 않으면 확장자 구별 후 메세지 타입 지정
                                    if (widget.media != null && !isSending) {
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

                                      //미디어 전송 데이터 준비
                                      data = MessageData(
                                          type: widget.type,
                                          senderUID: userUID,
                                          content: "",
                                          readers: [userUID!],
                                          time: Timestamp.fromDate(
                                              DateTime.now()));

                                      setState(() {
                                        isSending = true;
                                      });

                                      await chat.sendMedia(
                                          userData: userData,
                                          roomData: widget.chatRoomData,
                                          messageData: data,
                                          media: widget.media!,
                                          thumbnail: widget.thumbnail,
                                          isGroup: widget.isGroup);

                                      //전송 완료 후 미디어 변수 비우기
                                      try {
                                        setState(() {
                                          isSending = false;
                                          widget.media = null;
                                        });
                                      } catch (e) {
                                        //
                                      }
                                    } else {
                                      //미디어 파일이 아니면 텍스트 전송
                                      content = chatController.value.text;
                                      chatController.value =
                                          TextEditingValue.empty;

                                      //텍스트 메세지 데이터 준비
                                      data = MessageData(
                                          type: MessageType.text,
                                          senderUID: userUID,
                                          content: content,
                                          readers: [userUID!],
                                          time: Timestamp.fromDate(
                                              DateTime.now()));

                                      await chat.sendMessage(
                                          userData: userData,
                                          roomId: widget.chatRoomData.roomId!,
                                          data: data,
                                          isGroup: widget.isGroup);
                                    }

                                    print(chatUser?.notiToken);

                                    if (widget.isGroup) {
                                      for (var user in groupChatUsers) {
                                        NotiService.sendNoti(
                                            targetToken: user?.notiToken ?? "",
                                            title: user?.name ?? "",
                                            content: content);
                                      }
                                    } else {
                                      NotiService.sendNoti(
                                          targetToken:
                                              chatUser?.notiToken ?? "",
                                          title: chatUser?.name ?? "",
                                          content: content);
                                    }

                                    //전송 후 맨 아래로 이동
                                    if (scrollController.hasClients) {
                                      scrollController.animateTo(
                                        0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          //미디어 전송 패널
                          prepareMedia
                              ? Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  color: isDark
                                      ? AppColors.darkTag
                                      : AppColors.lightTag,
                                  child: Center(
                                    child: IntrinsicHeight(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          //사진 버튼
                                          MediaButton(
                                            color: Colors.yellow[700]!,
                                            icon: Icons.photo_library_outlined,
                                            text: "사진",
                                            onTap: () async {
                                              widget.media = await ImagePicker()
                                                  .pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (widget.media != null) {
                                                widget.type =
                                                    MessageType.picture;
                                                setState(() {});
                                              }
                                            },
                                          ),

                                          //동영상 버튼
                                          MediaButton(
                                            icon: Icons.video_library_outlined,
                                            text: "동영상",
                                            onTap: () async {
                                              widget.media = await ImagePicker()
                                                  .pickVideo(
                                                      source:
                                                          ImageSource.gallery);

                                              if (widget.media != null) {
                                                widget.thumbnail =
                                                    await VideoCompress
                                                        .getFileThumbnail(
                                                            widget.media!.path);
                                                widget.type = MessageType.video;
                                                setState(() {});
                                              }
                                            },
                                          ),

                                          //카메라 버튼
                                          MediaButton(
                                            color: Colors.red[400]!,
                                            icon: Icons.camera_alt_outlined,
                                            text: "카메라",
                                            onTap: () async {
                                              showDialog(
                                                barrierColor: Colors.black
                                                    .withOpacity(0.4),
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    clipBehavior: Clip.hardEdge,
                                                    shape:
                                                        ContinuousRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    child: IntrinsicHeight(
                                                      child: SizedBox(
                                                        width: 100,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                widget.media =
                                                                    await ImagePicker()
                                                                        .pickImage(
                                                                            source:
                                                                                ImageSource.camera);
                                                                if (widget
                                                                        .media !=
                                                                    null) {
                                                                  widget.type =
                                                                      MessageType
                                                                          .picture;
                                                                  setState(
                                                                      () {});
                                                                }
                                                              },
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            15),
                                                                child: Text(
                                                                  "사진",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                ),
                                                              ),
                                                            ),
                                                            const Divider(
                                                                height: 0),
                                                            InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                widget.media =
                                                                    await ImagePicker()
                                                                        .pickVideo(
                                                                            source:
                                                                                ImageSource.camera);

                                                                if (widget
                                                                        .media !=
                                                                    null) {
                                                                  widget.thumbnail =
                                                                      await VideoCompress.getFileThumbnail(widget
                                                                          .media!
                                                                          .path);
                                                                  widget.type =
                                                                      MessageType
                                                                          .video;
                                                                  Navigator.pop(
                                                                      context);
                                                                  setState(
                                                                      () {});
                                                                }
                                                              },
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            15),
                                                                child: Text(
                                                                  "동영상",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
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
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircleLoading());
          },
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class MediaButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  Function()? onTap;

  MediaButton(
      {super.key,
      required this.text,
      required this.icon,
      this.color = Colors.blue,
      this.onTap});

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
                    color: color, borderRadius: BorderRadius.circular(100)),
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

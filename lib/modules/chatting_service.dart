import 'dart:io';
import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/enums.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/chatting/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class ChattingService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firestorage = FirebaseStorage.instance;

  //1:1채팅방 ID 생성
  String makeRoomId(String ownerUID, String targetUID) {
    //문자열 순서에 따라 정렬한 후 '_'로 연결 (누가 먼저 시작해도 정렬 후 생성하기 때문에 중복되지 않음)
    List<String> list = [ownerUID, targetUID];
    list.sort();
    String roomId = list.join("_");
    return roomId;
  }

  //1:1 채팅시작
  void startChatting(
      BuildContext context, String ownerUID, String targetUID) async {
    //1:1 채팅방ID 구하기
    String roomId = makeRoomId(ownerUID, targetUID);
    //원래 채팅방이 있는지 조회
    await firestore.collection("chats").doc(roomId).get().then((value) {
      //채팅방이 있으면 그 채팅방으로 화면 이동
      if (value.exists) {
        var json = value.data() as Map<String, dynamic>;
        ChatRoomData data = ChatRoomData.fromJson(json);
        if (!data.participantsUid!.contains(ownerUID)) {
          data.participantsUid!.add(ownerUID);
          firestore
              .collection("chats")
              .doc(roomId)
              .update({"participantsUid": data.participantsUid});
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(chatRoomData: data),
          ),
        );
        return;
      } else {
        createRoom(context, targetUID);
        return;
      }
    });
  }

  //채팅방 생성
  void createRoom(BuildContext context, String targetUID) async {
    UserData userData = context.read<UserDataProvider>().userData;
    //1:1 채팅방ID 구하기
    String roomId = makeRoomId(userData.uid!, targetUID);

    var data = await getUserProfile(targetUID);
    var doc = data.data() as Map<String, dynamic>;
    String targetName = doc["name"];
    String targetImageUrl = doc["imageUrl"];
    List<String> inputData = [targetName, targetImageUrl];

    ChatRoomData roomData = ChatRoomData(
        roomId: roomId,
        roomName: "새로운 채팅방",
        leavingTime: {
          targetUID: Timestamp.fromDate(DateTime.now()),
          userData.uid!: Timestamp.fromDate(DateTime.now())
        },
        participantsInfo: {
          userData.uid!: [userData.name!, userData.imageUrl!],
          targetUID: inputData
        },
        participantsUid: [userData.uid!, targetUID],
        lastMessage: "");

    await firestore.collection("chats").doc(roomId).set(roomData.toJson());

    enterRoom(context, roomData);
  }

  //채팅방 입장
  static void enterRoom(BuildContext context, ChatRoomData data) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(chatRoomData: data),
        ));
  }

  //채팅방 나가기
  void leaveRoom(BuildContext context, String roomId, String userUID) async {
    var roomRef = firestore.collection("chats").doc(roomId);
    var messageRef = firestore.collection("chats/$roomId/messages");
    DocumentSnapshot<Map<String, dynamic>> data = await roomRef.get();

    List participantsList = data.data()!["participantsUid"];
    participantsList.remove(userUID);

    //다 나가서 참여자가 없으면 방 데이터 모두 삭제
    if (participantsList.isEmpty) {
      roomRef.delete();
      Navigator.pop(context);

      //콜렉션 통째로 삭제가 안돼서 하나하나 삭제함
      messageRef.get().then((value) async {
        for (var doc in value.docs) {
          await doc.reference.delete();
        }
      });

      var imageRef = firestorage.ref().child("chat/$roomId/images");
      var videoRef = firestorage.ref().child("chat/$roomId/videos");

      ListResult imageResult = await imageRef.listAll();
      ListResult videoResult = await videoRef.listAll();

      for (Reference ref in imageResult.items) {
        ref.delete();
      }

      for (Reference ref in videoResult.items) {
        ref.delete();
      }
    } else {
      roomRef.update({"participantsUid": participantsList}).whenComplete(
          () => Navigator.pop(context));
    }
  }

  //사용자가 참여한 채팅방 데이터 리스트 반환
  Stream<QuerySnapshot<Object>> getChattingList(String ownerUID) {
    return firestore
        .collection("chats")
        .where("participantsUid", arrayContains: ownerUID)
        .snapshots();
  }

  //채팅방의 메세지 데이터 반환
  Stream<QuerySnapshot<Object>> getChattingMessages(String roomId) {
    return firestore
        .collection("chats/$roomId/messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  //메세지 데이터 읽은 사람 갱신
  void updateReader(
      String roomId, String messageId, List<String> readerList) async {
    firestore
        .collection("chats/$roomId/messages")
        .doc(messageId)
        .update({"readers": readerList});
  }

  //사용자 정보 반환
  Future<DocumentSnapshot<Object>> getUserProfile(String uid) async {
    return firestore.collection("users").doc(uid).get();
  }

  //메세지 보내기
  Future<void> sendMessage(
      {required String roomId, required MessageData data}) async {
    await firestore
        .collection("chats/$roomId/messages")
        .doc(const Uuid().v1())
        .set(data.toJson())
        .whenComplete(() async {
      var lastMessage = "";

      switch (data.type) {
        case MessageType.text:
          lastMessage = data.content!;
          break;
        case MessageType.picture:
          lastMessage = "사진";
          break;
        case MessageType.video:
          lastMessage = "영상";
          break;
        default:
          lastMessage = data.content!;
          break;
      }

      await FirebaseFirestore.instance
          .collection("chats")
          .doc(roomId)
          .update({"lastMessage": lastMessage, "lastMessageTime": data.time});
    });
  }

  //미디어파일 보내기
  Future<void> sendMedia(
      {required ChatRoomData roomData,
      required MessageData messageData,
      required XFile media,
      File? thumbnail}) async {
    String thumbUrl = "";
    String url = "";
    XFile? compMedia;

    //이미지면 이미지 압축, 비디오면 비디오 압축
    if (messageData.type == MessageType.picture) {
      //이미지 압축
      compMedia = await FlutterImageCompress.compressAndGetFile(
          media.path, "${media.path}.jpg");
      //파이어스토어에 올리고 url 가져오기
      var ref = firestorage.ref().child(
          "chat/${roomData.roomId}/images/${roomData.roomId}-${messageData.time!.millisecondsSinceEpoch}.jpg");
      await ref.putFile(File(compMedia!.path)).whenComplete(() async {
        url = await ref.getDownloadURL();
      });
    }
    if (messageData.type == MessageType.video) {
      //동영상 썸네일 확보 후 파이어스토어에 업로드 후 url 가져오기
      XFile? compThumbnail = await FlutterImageCompress.compressAndGetFile(
          thumbnail!.path, "${thumbnail.path}.jpg");

      var thumbRef = firestorage.ref().child(
          "chat/${roomData.roomId}/thumbnails/${roomData.roomId}-thumbnail-${messageData.time!.millisecondsSinceEpoch}.jpg");
      await thumbRef.putFile(File(compThumbnail!.path)).whenComplete(() async {
        thumbUrl = await thumbRef.getDownloadURL();
      });
      //동영상 압축
      var mediaInfo = await VideoCompress.compressVideo(
        media.path,
        quality: VideoQuality.DefaultQuality,
      );

      //파이어스토어에 올리고 url 가져오기
      var ref = firestorage.ref().child(
          "chat/${roomData.roomId}/videos/${roomData.roomId}-${messageData.time!.millisecondsSinceEpoch}.mp4");
      await ref.putFile(mediaInfo!.file!).whenComplete(() async {
        url = await ref.getDownloadURL();
      });
    }

    messageData.content = [thumbUrl.isEmpty ? null : thumbUrl, url].join(":-:");
    messageData.time = Timestamp.now();

    sendMessage(roomId: roomData.roomId!, data: messageData);
  }
}

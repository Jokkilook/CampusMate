import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/message_data.dart';
import 'package:campusmate/screens/chatting/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChattingService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //1:1채팅방 ID 생성
  String makeRoomId(String ownerUID, String targetUID) {
    //문자열 순서에 따라 정렬한 후 '_'로 연결 (누가 먼저 시작해도 정렬 후 생성하기 때문에 중복되지 않음)
    List<String> list = [ownerUID, targetUID];
    list.sort();
    String roomId = list.join("_");
    return roomId;
  }

  //채팅시작
  void startChatting(
      BuildContext context, String ownerUID, String targetUID) async {
    //채팅방ID 구하기
    String roomId = makeRoomId(ownerUID, targetUID);
    //원래 채팅방이 있는지 조회
    await firestore
        .collection("chats")
        .where("id", isEqualTo: roomId)
        .get()
        .then((value) {
      //채팅방이 있으면 그 채팅방으로 화면 이동

      if (value.size > 0) {
        var json = value.docs as Map<String, dynamic>;
        ChatRoomData data = ChatRoomData.fromJson(json);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(chatRoomData: data),
          ),
        );
      } else {
        //채팅방이 없으면 생성
        ChatRoomData data = ChatRoomData(
            roomId: roomId,
            roomName: "새로운 채팅방",
            participantsUid: [ownerUID, targetUID],
            lastMessage: "");

        firestore
            .collection("chats")
            .doc(roomId)
            .set(data.toJson())
            .whenComplete(() {
          //생성 후 채팅방으로 화면 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                chatRoomData: data,
                isNew: true,
              ),
            ),
          );
        });
      }
    });
  }

  Stream<QuerySnapshot<Object>> getChattingList(String ownerUID) {
    return firestore
        .collection("chats")
        .where("participantsUid", arrayContains: ownerUID)
        .snapshots();
  }

  Stream<QuerySnapshot<Object>> getChattingMessages(String roomId) {
    return firestore
        .collection("chats/$roomId/messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Object>> getUserProfile(String uid) async {
    return firestore.collection("users").doc(uid).get();
  }

  void sendMessage({required String roomId, required MessageData data}) {
    firestore
        .collection("chats/$roomId/messages")
        .doc("${DateTime.now().microsecondsSinceEpoch}")
        .set(data.toJson())
        .whenComplete(() {
      FirebaseFirestore.instance.collection("chats").doc(roomId).update({
        "lastMessage": data.content,
        "lastMessageTime": data.time
        //Timestamp.fromDate(DateTime.now())
      });
    });
  }
}

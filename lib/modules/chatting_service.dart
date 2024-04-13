import 'package:campusmate/models/message_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChattingService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String makeRoomId(String ownerUID, String targetUID) {
    List<String> list = [ownerUID, targetUID];
    list.sort();
    String roomId = list.join("_");
    return roomId;
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

  Future<DocumentSnapshot<Object>> getSenderProfile(String senderUID) async {
    return firestore.collection("users").doc(senderUID).get();
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

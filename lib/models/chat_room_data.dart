import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomData {
  String? roomId;
  String? roomName;
  List<String>? participantsUid;
  String? lastMessage;
  Timestamp? lastMessageTime;

  ChatRoomData(
      {this.roomId,
      this.roomName,
      this.participantsUid,
      this.lastMessage,
      this.lastMessageTime});

  ChatRoomData.from(Map<String, dynamic> json) {
    roomId = json["roomId"];
    roomName = json["roomName"];
    participantsUid = json["participantsUid"];
    lastMessage = json["lastMessage"];
    lastMessageTime = json["lastMessageTime"];
  }
}

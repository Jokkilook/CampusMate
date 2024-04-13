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

  ChatRoomData.fromJson(Map<String, dynamic> json) {
    roomId = json["roomId"];
    roomName = json["roomName"];
    participantsUid = json["participantsUid"];
    lastMessage = json["lastMessage"];
    lastMessageTime = json["lastMessageTime"];
  }

  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "roomName": roomName,
      "participantsUid": participantsUid,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime
    };
  }
}

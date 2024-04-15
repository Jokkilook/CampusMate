import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomData {
  String? roomId;
  String? roomName;
  List<String>? participantsUid;
  Map<String, List<String>>? participantsInfo;
  String? lastMessage;
  Timestamp? lastMessageTime;

  ChatRoomData(
      {this.roomId,
      this.roomName,
      this.participantsUid,
      this.participantsInfo,
      this.lastMessage,
      this.lastMessageTime});

  ChatRoomData.fromJson(Map<String, dynamic> json) {
    roomId = json["roomId"];
    roomName = json["roomName"];
    participantsInfo = json["participantsInfo"];
    participantsUid = json["participantsUid"];
    lastMessage = json["lastMessage"];
    lastMessageTime = json["lastMessageTime"];
  }

  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "roomName": roomName,
      "participantsInfo": participantsInfo,
      "participantsUid": participantsUid,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime
    };
  }
}

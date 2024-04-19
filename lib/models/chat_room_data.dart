import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomData {
  String? roomId;
  String? roomName;
  List<String>? participantsUid;
  Map<String, List<String>>? participantsInfo;
  String? lastMessage;
  Timestamp? lastMessageTime;
  Map<String, Timestamp>? leavingTime;

  ChatRoomData(
      {this.roomId,
      this.roomName,
      this.participantsUid,
      this.participantsInfo,
      this.lastMessage,
      this.lastMessageTime,
      this.leavingTime});

  ChatRoomData.fromJson(Map<String, dynamic> json) {
    roomId = json["roomId"];
    roomName = json["roomName"];
    participantsInfo =
        (json["participantsInfo"] as Map<String, dynamic>).map((key, value) {
      return MapEntry(key, (value as List<dynamic>).cast<String>());
    });
    participantsUid =
        (json["participantsUid"] as List).map((e) => e.toString()).toList();
    lastMessage = json["lastMessage"];
    lastMessageTime = json["lastMessageTime"];
    leavingTime =
        (json["leavingTime"] as Map<String, dynamic>).map((key, value) {
      return MapEntry(key, (value as Timestamp));
    });
  }

  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "roomName": roomName,
      "participantsInfo": participantsInfo,
      "participantsUid": participantsUid,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
      "leavingTime": leavingTime
    };
  }
}

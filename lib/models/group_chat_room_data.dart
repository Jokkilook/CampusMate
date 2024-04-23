import 'package:campusmate/models/chat_room_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatRoomData extends ChatRoomData {
  @override
  String? roomId;
  @override
  String? roomName;
  String? creatorUid;
  String? description;
  int? limit;
  @override
  List<String>? participantsUid;
  @override
  Map<String, List<String>>? participantsInfo;
  @override
  String? lastMessage;
  @override
  Timestamp? lastMessageTime;
  Timestamp? createdTime;
  @override
  Map<String, Timestamp>? leavingTime;

  GroupChatRoomData(
      {this.roomId,
      this.roomName,
      this.creatorUid,
      this.description,
      this.limit,
      this.participantsUid,
      this.participantsInfo,
      this.lastMessage,
      this.lastMessageTime,
      this.createdTime,
      this.leavingTime});

  GroupChatRoomData.fromJson(Map<String, dynamic> json) {
    roomId = json["roomId"];
    roomName = json["roomName"];
    creatorUid = json["creatorUid"];
    description = json["description"];
    limit = json["limit"];
    participantsInfo =
        (json["participantsInfo"] as Map<String, dynamic>).map((key, value) {
      return MapEntry(key, (value as List<dynamic>).cast<String>());
    });
    participantsUid =
        (json["participantsUid"] as List).map((e) => e.toString()).toList();
    lastMessage = json["lastMessage"];
    lastMessageTime = json["lastMessageTime"];
    createdTime = json["createdTime"];
    leavingTime =
        (json["leavingTime"] as Map<String, dynamic>).map((key, value) {
      return MapEntry(key, (value as Timestamp));
    });
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "roomName": roomName,
      "creatorUid": creatorUid,
      "description": description,
      "limit": limit,
      "participantsInfo": participantsInfo,
      "participantsUid": participantsUid,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
      "createdTime": createdTime,
      "leavingTime": leavingTime
    };
  }
}

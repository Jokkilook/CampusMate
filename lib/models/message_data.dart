import 'package:cloud_firestore/cloud_firestore.dart';

class MessageData {
  String? senderUID;
  String? content;
  List<String>? readers;
  Timestamp? time;

  MessageData(
      {required this.senderUID,
      required this.content,
      required this.time,
      this.readers});

  MessageData.fromJson(Map<String, dynamic> json) {
    senderUID = json["senderUID"];
    content = json["content"];
    readers = (json["readers"] as List).map((e) => e.toString()).toList();
    time = json["time"];
  }

  toJson() {
    return {
      "senderUID": senderUID,
      "content": content,
      "readers": readers,
      "time": time,
    };
  }
}

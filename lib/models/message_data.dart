class MessageData {
  String? senderUID;
  String? content;
  String? time;

  MessageData(
      {required this.senderUID, required this.content, required this.time});

  MessageData.fromJson(Map<String, dynamic> json) {
    senderUID = json["senderUID"];
    content = json["content"];
    time = json["time"];
  }

  toJson() {
    return {
      "senderUID": senderUID,
      "content": content,
      "time": time,
    };
  }
}

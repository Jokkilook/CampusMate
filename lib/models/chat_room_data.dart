class ChatRoomData {
  String? roomId;
  String? roomName;
  String? lastText;
  List<String>? participantsUid;

  ChatRoomData(
      {this.roomId, this.roomName, this.lastText, this.participantsUid});

  ChatRoomData.from(Map<String, dynamic> json) {
    roomId = json["roomId"];
    roomName = json["roomName"];
    lastText = json["chats"];
    participantsUid = json["participantsUid"];
  }
}

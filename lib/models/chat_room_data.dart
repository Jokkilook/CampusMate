class ChatRoomData {
  String? roomId;
  String? roomName;
  String? lastText;

  ChatRoomData({this.roomId, this.roomName, this.lastText});

  ChatRoomData.from(Map<String, dynamic> json) {
    roomId = json["roomId"];
    roomName = json["roomName"];
    lastText = json["chats"];
  }
}

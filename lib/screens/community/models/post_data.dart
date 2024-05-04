import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  String? boardType;
  String? title;
  String? content;
  Timestamp? timestamp;
  String? authorUid;
  String? postId;
  List<dynamic>? viewers;
  List<dynamic>? likers;
  List<dynamic>? dislikers;

  Map<String, dynamic>? data;

  PostData({
    this.boardType = 'General',
    this.title,
    this.content,
    this.timestamp,
    this.authorUid,
    this.postId,
    this.viewers = const [],
    this.likers = const [],
    this.dislikers = const [],
  }) {
    setData();
  }

  PostData.fromJson(Map<String, dynamic> json) {
    boardType = json['boardType'];
    title = json['title'];
    content = json['content'];
    timestamp = json['timestamp'];
    authorUid = json['authorUid'];
    postId = json['postId'];
    viewers = json['viewers'] ?? [];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];

    setData();
  }

  void setData() {
    data = {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'authorUid': authorUid,
      'postId': postId,
      'viewers': viewers,
      'likers': likers,
      'dislikers': dislikers,
    };
  }
}

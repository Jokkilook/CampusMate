import 'package:cloud_firestore/cloud_firestore.dart';

class PostCommentData {
  String? postId;
  String? commentId;
  String? content;
  Timestamp? timestamp;
  String? authorUid;
  String? boardType;
  List<dynamic>? likers;
  List<dynamic>? dislikers;

  Map<String, dynamic>? data;

  PostCommentData({
    this.postId,
    this.commentId,
    this.content,
    this.timestamp,
    this.authorUid,
    this.boardType,
    this.likers = const [],
    this.dislikers = const [],
  }) {
    setData();
  }

  PostCommentData.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    commentId = json['commentId'];
    content = json['content'];
    timestamp = json['timestamp'];
    authorUid = json['authorUid'];
    boardType = json['boardType'];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];

    setData();
  }

  void setData() {
    data = {
      'postId': postId,
      'commentId': commentId,
      'content': content,
      'timestamp': timestamp,
      'authorUid': authorUid,
      'boardType': boardType,
      'likers': likers,
      'dislikers': dislikers,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PostReplyData {
  String? postId;
  String? commentId;
  String? replyId;
  String? content;
  Timestamp? timestamp;
  String? authorUid;
  String? authorName;
  String? school;
  String? profileImageUrl;
  String? boardType;
  List<dynamic>? likers;
  List<dynamic>? dislikers;

  Map<String, dynamic>? data;

  PostReplyData({
    this.postId,
    this.commentId,
    this.replyId,
    this.content,
    this.timestamp,
    this.authorUid,
    this.authorName,
    this.school,
    this.profileImageUrl,
    this.boardType,
    this.likers = const [],
    this.dislikers = const [],
  }) {
    setData();
  }

  PostReplyData.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    commentId = json['commentId'];
    replyId = json['replyId'];
    content = json['content'];
    timestamp = json['timestamp'];
    authorUid = json['authorUid'];
    authorName = json['authorName'];
    school = json['school'];
    profileImageUrl = json['profileImageUrl'];
    boardType = json['boardType'];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];
    setData();
  }

  void setData() {
    data = {
      'postId': postId,
      'commentId': commentId,
      'replyId': replyId,
      'content': content,
      'timestamp': timestamp,
      'authorUid': authorUid,
      'authorName': authorName,
      'school': school,
      'profileImageUrl': profileImageUrl,
      'boardType': boardType,
      'likers': likers,
      'dislikers': dislikers,
    };
  }
}

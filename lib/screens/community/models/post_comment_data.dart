import 'package:cloud_firestore/cloud_firestore.dart';

class PostCommentData {
  String? postId;
  String? commentId;
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

  PostCommentData({
    this.postId,
    this.commentId,
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

  PostCommentData.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    commentId = json['commentId'];
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

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
  int? writerIndex;
  List<dynamic>? likers;
  List<dynamic>? dislikers;

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
    this.writerIndex,
    this.likers,
    this.dislikers,
  }) {
    likers = [];
    dislikers = [];
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
    writerIndex = json['writerIndex'];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];
  }

  toJson() {
    return {
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
      'writerIndex': writerIndex,
      'likers': likers,
      'dislikers': dislikers,
    };
  }
}

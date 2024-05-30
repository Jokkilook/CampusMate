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
  int? writerIndex;
  int? replyCount;
  List<dynamic>? likers;
  List<dynamic>? dislikers;

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
    this.writerIndex,
    this.replyCount = 0,
    this.likers,
    this.dislikers,
  }) {
    likers = [];
    dislikers = [];
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
    writerIndex = json['writerIndex'];
    replyCount = json['replyCount'];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];
  }

  toJson() {
    return {
      'postId': postId,
      'commentId': commentId,
      'content': content,
      'timestamp': timestamp,
      'authorUid': authorUid,
      'authorName': authorName,
      'school': school,
      'profileImageUrl': profileImageUrl,
      'boardType': boardType,
      'writerIndex': writerIndex,
      'replyCount': replyCount,
      'likers': likers,
      'dislikers': dislikers,
    };
  }
}

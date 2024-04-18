import 'package:cloud_firestore/cloud_firestore.dart';

class PostCommentData {
  String? postId;
  String? commentId;
  String? content;
  Timestamp? timestamp;
  String? authorUid;
  int? likeCount;
  int? dislikeCount;
  int? replyCount;
  List<dynamic>? likers;
  List<dynamic>? dislikers;
  List<dynamic>? replies;

  Map<String, dynamic>? data;

  PostCommentData({
    this.postId,
    this.commentId,
    this.content,
    this.timestamp,
    this.authorUid,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.replyCount = 0,
    this.likers = const [],
    this.dislikers = const [],
    this.replies = const [],
  }) {
    setData();
  }

  PostCommentData.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    commentId = json['commentId'];
    content = json['content'];
    timestamp = json['timestamp'];
    authorUid = json['authorUid'];
    likeCount = json['likeCount'];
    dislikeCount = json['dislikeCount'];
    replyCount = json['replyCount'];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];
    replies = json['replies'] ?? [];

    setData();
  }

  void setData() {
    data = {
      'postId': postId,
      'commentId': commentId,
      'content': content,
      'timestamp': timestamp,
      'authorUid': authorUid,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'replyCount': replyCount,
      'likers': likers,
      'dislikers': dislikers,
      'replies': replies,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  String? boardType;
  String? title;
  String? content;
  Timestamp? timestamp;
  String? authorUid;
  String? postId;
  int? viewCount;
  int? likeCount;
  int? dislikeCount;
  int? commentCount;
  List<dynamic>? viewers;
  List<dynamic>? likers;
  List<dynamic>? dislikers;
  List<dynamic>? comments;

  Map<String, dynamic>? data;

  PostData({
    this.boardType = 'General',
    this.title,
    this.content,
    this.timestamp,
    this.authorUid,
    this.postId,
    this.viewCount = 0,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.viewers = const [],
    this.likers = const [],
    this.dislikers = const [],
    this.comments = const [],
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
    viewCount = json['viewCount'];
    likeCount = json['likeCount'];
    dislikeCount = json['dislikeCount'];
    commentCount = json['commentCount'];
    viewers = json['viewers'] ?? [];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];
    comments = json['comments'] ?? [];

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
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'viewers': viewers,
      'likers': likers,
      'dislikers': dislikers,
      'comments': comments,
    };
  }
}

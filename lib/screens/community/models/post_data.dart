import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  String? boardType;
  String? title;
  String? content;
  Timestamp? timestamp;
  String? authorUid;
  String? authorName;
  String? postId;
  String? imageUrl;
  String? profileImageUrl;
  int? commentCount;
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
    this.authorName,
    this.postId,
    this.imageUrl,
    this.profileImageUrl,
    this.commentCount,
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
    authorName = json['authorName'];
    postId = json['postId'];
    imageUrl = json['imageUrl'];
    profileImageUrl = json['profileImageUrl'];
    commentCount = json['commentCount'] ?? 0;
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
      'authorName': authorName,
      'postId': postId,
      'imageUrl': imageUrl,
      'profileImageUrl': profileImageUrl,
      'commentCount': commentCount,
      'viewers': viewers,
      'likers': likers,
      'dislikers': dislikers,
    };
  }
}

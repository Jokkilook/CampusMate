import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  String? boardType;
  String? title;
  String? content;
  Timestamp? timestamp;
  String? authorUid;
  String? authorName;
  String? postId;
  String? school;
  List<String>? imageUrl;
  String? profileImageUrl;
  int? commentCount;
  List<dynamic>? viewers;
  List<dynamic>? commentWriters;
  List<dynamic>? likers;
  List<dynamic>? dislikers;

  PostData({
    this.boardType = 'General',
    this.title,
    this.content,
    this.timestamp,
    this.authorUid,
    this.authorName,
    this.postId,
    this.school,
    this.imageUrl,
    this.profileImageUrl,
    this.commentCount,
    this.viewers,
    this.commentWriters,
    this.likers,
    this.dislikers,
  }) {
    viewers = [];
    commentWriters = [];
    likers = [];
    dislikers = [];
    imageUrl = ["", "", "", "", "", ""];
  }

  PostData.fromJson(Map<String, dynamic> json) {
    boardType = json['boardType'];
    title = json['title'];
    content = json['content'];
    timestamp = json['timestamp'];
    authorUid = json['authorUid'];
    authorName = json['authorName'];
    postId = json['postId'];
    school = json['school'];
    imageUrl = (json['imageUrl'] as List).map((e) => e.toString()).toList();
    profileImageUrl = json['profileImageUrl'];
    commentCount = json['commentCount'] ?? 0;
    viewers = json['viewers'] ?? [];
    commentWriters = json['commentWriters'] ?? [];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'authorUid': authorUid,
      'authorName': authorName,
      'postId': postId,
      'school': school,
      'imageUrl': imageUrl,
      'profileImageUrl': profileImageUrl,
      'commentCount': commentCount,
      'viewers': viewers,
      'commentWriters': commentWriters,
      'likers': likers,
      'dislikers': dislikers,
    };
  }
}

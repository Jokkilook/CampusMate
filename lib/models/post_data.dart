import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_comment_data.dart'; // import PostCommentData class

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
  List<PostCommentData>? comments; // Change to List<PostCommentData>

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
    viewers = json['viewers'] ?? [];
    likers = json['likers'] ?? [];
    dislikers = json['dislikers'] ?? [];
    if (json['comments'] != null && json['comments'] is Map<String, dynamic>) {
      // Check if comments is not null and is a Map
      comments = (json['comments'] as Map<String, dynamic>)
          .values
          .map<PostCommentData>(
              (commentJson) => PostCommentData.fromJson(commentJson))
          .toList();
    } else {
      comments = [];
    }

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
      'comments': comments?.map((comment) => comment.data).toList(),
    };
  }

  void addComment(PostCommentData comment) {
    comments?.add(comment);
    setData();
  }
}

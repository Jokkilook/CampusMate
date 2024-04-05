import 'package:campusmate/models/schedule_data.dart';

class PostData {
  String? boardType;
  String? title;
  String? content;
  String? timestamp;
  String? author;
  String? uid;
  int? viewCount;
  int? likeCount;
  int? dislikeCount;
  int? commentCount;

  Map<String, dynamic>? data;

  PostData({
    this.boardType = 'A',
    this.title,
    this.content,
    this.timestamp,
    this.author,
    this.uid,
    this.viewCount = 0,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
  }) {
    data = {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'author': author,
      'uid': uid,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
    };
  }

  PostData.fromJson(Map<String, dynamic> json) {
    boardType = json['boardType'];
    title = json['title'];
    content = json['content'];
    timestamp = json['timestamp'];
    author = json['author'];
    uid = json['uid'];
    viewCount = json['viewCount'];
    likeCount = json['likeCount'];
    dislikeCount = json['dislikeCount'];
    commentCount = json['commentCount'];

    data = {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'author': author,
      'uid': uid,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
    };
  }

  void setData() {
    data = {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'author': author,
      'uid': uid,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
    };
  }
}

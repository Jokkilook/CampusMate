class PostData {
  String? boardType;
  String? title;
  String? content;
  String? timestamp;
  String? author;
  String? authorUid;
  String? postId;
  int? viewCount;
  int? likeCount;
  int? dislikeCount;
  int? commentCount;
  List<dynamic>? viewers;

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
    this.viewers,
  }) {
    data = {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'author': author,
      'authorUid': authorUid,
      'postId': postId,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'viewers': viewers,
    };
  }

  PostData.fromJson(Map<String, dynamic> json) {
    boardType = json['boardType'];
    title = json['title'];
    content = json['content'];
    timestamp = json['timestamp'];
    author = json['author'];
    authorUid = json['authorUid'];
    postId = json['postId'];
    viewCount = json['viewCount'];
    likeCount = json['likeCount'];
    dislikeCount = json['dislikeCount'];
    commentCount = json['commentCount'];
    viewers = json['viewers'];

    data = {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'author': author,
      'authorUid': authorUid,
      'postId': postId,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'viewers': viewers,
    };
  }

  void setData() {
    data = {
      'boardType': boardType,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'author': author,
      'authorUid': authorUid,
      'postId': postId,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'viewers': viewers,
    };
  }
}

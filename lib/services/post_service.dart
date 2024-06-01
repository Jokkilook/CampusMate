import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  ///게시글 정보 불러오기
  Future<PostData> getPostData(
      {required String postId,
      required UserData userData,
      bool isAnonymous = false}) async {
    var data = await firestore
        .collection(
            "schools/${userData.school}/${(isAnonymous ? 'anonymousPosts' : 'generalPosts')}")
        .doc(postId)
        .get();

    PostData postData = PostData.fromJson(data.data() as Map<String, dynamic>);

    return postData;
  }

  ///게시글 올리기
  Future<void> addPost(
      {required PostData postData, required UserData userData}) async {
    try {
      if (postData.boardType == 'General') {
        await firestore
            .collection('schools/${userData.school}/generalPosts')
            .doc(postData.postId)
            .set(postData.toJson());
      }
      if (postData.boardType == 'Anonymous') {
        await firestore
            .collection('schools/${userData.school}/anonymousPosts')
            .doc(postData.postId)
            .set(postData.toJson());
      }
    } catch (error) {
      //
    }
  }

  ///게시글 삭제
  Future deletePost({required PostData postData}) async {
    for (var url in postData.imageUrl!) {
      if (url != "") {
        var targetRef = storage.refFromURL(url);
        await targetRef.delete();
      }
    }
    // Firestore batch 초기화
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 게시글 컬렉션 참조
    CollectionReference postsCollection = FirebaseFirestore.instance.collection(
        "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}");

    // 게시글 문서 참조
    DocumentReference postDocRef = postsCollection.doc(postData.postId);

    // 댓글 컬렉션 참조
    CollectionReference commentsCollection = postDocRef.collection('comments');

    // 댓글 문서들 가져오기
    QuerySnapshot commentsSnapshot = await commentsCollection.get();

    // 각 댓글과 해당 답글을 삭제하기 위한 반복문
    for (var commentDoc in commentsSnapshot.docs) {
      // 댓글 문서 참조
      DocumentReference commentDocRef = commentsCollection.doc(commentDoc.id);

      // 답글 컬렉션 참조
      CollectionReference repliesCollection =
          commentDocRef.collection('replies');

      // 답글 문서들 가져오기
      QuerySnapshot repliesSnapshot = await repliesCollection.get();

      // 각 답글을 배치에 추가
      for (var replyDoc in repliesSnapshot.docs) {
        batch.delete(repliesCollection.doc(replyDoc.id));
      }

      // 댓글을 배치에 추가
      batch.delete(commentDocRef);
    }

    // 게시글을 배치에 추가
    batch.delete(postDocRef);

    // 배치 커밋
    await batch.commit();

    await firestore
        .collection(
            'schools/${postData.school}/${postData.boardType == "General" ? "generalPosts" : "anonymousPosts"}')
        .doc(postData.postId)
        .delete();
  }

  ///게시글 수정
  Future updatePost(
      {required UserData userData, required PostData editedData}) async {
    if (userData.uid != editedData.authorUid) return;

    await firestore
        .collection(
            'schools/${editedData.school}/${editedData.boardType == "General" ? "generalPosts" : "anonymousPosts"}')
        .doc(editedData.postId)
        .update(editedData.toJson());
  }

  ///조회수 업데이트
  Future<void> updateViewCount(
      {required PostData postData, required UserData userData}) async {
    String viewerUID = userData.uid ?? "";
    bool userAlreadyViewed = postData.viewers?.contains(viewerUID) ?? false;

    try {
      if (!userAlreadyViewed) {
        await firestore
            .collection(
                "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
            .doc(postData.postId)
            .update({
          'viewers': FieldValue.arrayUnion([viewerUID]),
        });
      } else {}
    } catch (error) {
      //
    }
  }

  ///댓글 불러오기
  Future<QuerySnapshot<Map<String, dynamic>>> getPostComment(
      PostData postData) async {
    return firestore
        .collection(
            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
        .doc(postData.postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .get();
  }

  ///댓&답글 갯수 불러오기
  Future getCommentCount(PostData postData) async {
    int count = 0;

    var postRef = firestore
        .collection(
            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}/")
        .doc(postData.postId);

    //댓글 수 더하기
    await postRef.collection('comments').get().then((value) {
      count += value as int;
    });

    //답글 수 더하기
    await postRef.collection('comments').get().then((value) {
      count += value as int;
    });

    return count;
  }

  ///댓글 작성
  Future postComment(
      {required UserData userData,
      required PostData postData,
      required String content}) async {
    //게시글 데이터 파이어스토어 레퍼런스
    var postRef = firestore
        .collection(
            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}/")
        .doc(postData.postId);

    //익명일 시, 유저 번호를 나타낼 인덱스
    int writerIndex = 0;

    //댓글 작성자가 게시글 작성자가 아니고, 게시글 댓글 작성자 리스트에 포함되어 있지 않으면,
    if (userData.uid != postData.authorUid &&
        !(postData.commentWriters!.contains(userData.uid))) {
      //댓글 작성자 리스트에 추가
      await postRef.update({
        'commentWriters': FieldValue.arrayUnion([userData.uid])
      });

      writerIndex = postData.commentWriters!.length + 1;
    }

    writerIndex = postData.commentWriters!.indexOf(userData.uid) + 1;

    Timestamp time = Timestamp.now();
    String commentId = "comment_${userData.uid}_${time.millisecondsSinceEpoch}";

    //댓글 데이터 생성
    PostCommentData comment = PostCommentData(
      commentId: commentId,
      boardType: postData.boardType,
      postId: postData.postId,
      authorUid: userData.uid,
      authorName: userData.name,
      profileImageUrl: userData.imageUrl,
      school: userData.school,
      content: content,
      timestamp: time,
      writerIndex: writerIndex,
    );

    //댓글 데이터 삽입
    await postRef.collection("comments").doc(commentId).set(comment.toJson());

    //표시할 댓글 수 수정 (+1)
    await postRef.update({'commentCount': FieldValue.increment(1)});
  }

  ///답글 작성
  Future postReply(
      {required UserData userData,
      required PostData postData,
      required String targetCommentId,
      required String content}) async {
    //게시글 데이터 파이어스토어 레퍼런스
    var postRef = firestore
        .collection(
            "schools/${userData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}/")
        .doc(postData.postId);

    //익명일 시, 유저 번호를 나타낼 인덱스
    int writerIndex = 0;

    //답글 작성자가 게시글 작성자가 아니고, 게시글 댓글 작성자 리스트에 포함되어 있지 않으면,
    if (userData.uid != postData.authorUid &&
        !(postData.commentWriters!.contains(userData.uid))) {
      //댓글 작성자 리스트에 추가
      await postRef.update({
        'commentWriters': FieldValue.arrayUnion([userData.uid])
      });

      writerIndex = postData.commentWriters!.length + 1;
    }

    writerIndex = postData.commentWriters!.indexOf(userData.uid) + 1;

    Timestamp time = Timestamp.now();
    String replyId = "reply_${userData.uid}_${time.millisecondsSinceEpoch}";

    //답글 데이터 생성
    PostReplyData reply = PostReplyData(
      replyId: replyId,
      commentId: targetCommentId,
      boardType: postData.boardType,
      postId: postData.postId,
      authorUid: userData.uid,
      authorName: userData.name,
      profileImageUrl: userData.imageUrl,
      school: userData.school,
      content: content,
      timestamp: time,
      writerIndex: writerIndex,
    );

    //답글 데이터 삽입
    await postRef
        .collection("comments")
        .doc(targetCommentId)
        .collection("replies")
        .doc(replyId)
        .set(reply.toJson());

    //댓글의 답글 수 업데이트
    await postRef
        .collection("comments")
        .doc(targetCommentId)
        .update({"replyCount": FieldValue.increment(1)});

    //표시할 댓글 수 수정 (+1)
    await postRef.update({'commentCount': FieldValue.increment(1)});
  }

  ///댓글(하위 답글 포함) 삭제
  Future deleteCommentAndReply(PostCommentData commentData) async {
    //게시글 파이어스토어 레퍼런스
    DocumentReference postRef = firestore
        .collection(
            "schools/${commentData.school}/${commentData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
        .doc(commentData.postId);

    // 댓글의 하위 답글 가져오기
    QuerySnapshot replySnapshot = await postRef
        .collection('comments')
        .doc(commentData.commentId)
        .collection('replies')
        .get();

    // 댓글과 답글 삭제
    WriteBatch batch = firestore.batch();
    batch.delete(postRef.collection('comments').doc(commentData.commentId));

    for (var doc in replySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // commentCount 업데이트
    int repliesCount = replySnapshot.docs.length;

    batch.update(postRef, {
      'commentCount': FieldValue.increment(-(1 + repliesCount)),
    });

    await batch.commit();
  }

  ///답글 삭제
  Future deleteReply(PostReplyData replyData) async {
    // Firestore batch 초기화
    WriteBatch batch = firestore.batch();

    // 댓글 컬렉션 참조
    CollectionReference commentsCollection = firestore
        .collection(
            "schools/${replyData.school}/${replyData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
        .doc(replyData.postId)
        .collection('comments');

    // 답글 문서 참조
    DocumentReference replyDocRef = commentsCollection
        .doc(replyData.commentId)
        .collection('replies')
        .doc(replyData.replyId);

    // 답글 삭제를 배치에 추가
    batch.delete(replyDocRef);

    // 게시글의 commentCount 감소를 배치에 추가
    DocumentReference postDocRef = firestore
        .collection(
            "schools/${replyData.school}/${replyData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
        .doc(replyData.postId);

    batch.update(postDocRef, {
      'commentCount': FieldValue.increment(-1),
    });

    // 배치 커밋
    await batch.commit();
  }
}

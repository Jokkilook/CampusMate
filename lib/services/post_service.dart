import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
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
  Future<QuerySnapshot> getPostComment(PostData postData) async {
    return firestore
        .collection(
            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
        .doc(postData.postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .get();
  }
}

import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  //게시글 정보 불러오기
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

  //게시글 올리기
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

  //게시글 삭제
  Future deletePost({required PostData postData}) async {
    for (var url in postData.imageUrl!) {
      if (url != "") {
        var targetRef = storage.refFromURL(url);
        await targetRef.delete();
      }
    }

    await firestore
        .collection(
            'schools/${postData.school}/${postData.boardType == "General" ? "generalPosts" : "anonymousPosts"}')
        .doc(postData.postId)
        .delete();
  }

  //게시글 수정
  Future updatePost(
      {required UserData userData, required PostData editedData}) async {
    if (userData.uid != editedData.authorUid) return;

    await firestore
        .collection(
            'schools/${editedData.school}/${editedData.boardType == "General" ? "generalPosts" : "anonymousPosts"}')
        .doc(editedData.postId)
        .update(editedData.toJson());
  }

  // 조회수
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
}

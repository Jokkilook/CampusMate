import 'package:campusmate/app_colors.dart';
import 'package:campusmate/screens/community/edit_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusmate/screens/community/models/post_data.dart';

class PostController extends StatefulWidget {
  const PostController({
    Key? key,
    required this.currentUserUid,
    required this.postData,
  }) : super(key: key);

  final String currentUserUid;
  final PostData postData;

  @override
  State<PostController> createState() => _PostControllerState();
}

class _PostControllerState extends State<PostController> {
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 9),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "취소",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _deletePost(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    try {
      // Firestore batch 초기화
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 게시글 컬렉션 참조
      CollectionReference postsCollection = FirebaseFirestore.instance
          .collection("schools/${widget.postData.school}/" +
              (widget.postData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'));

      // 게시글 문서 참조
      DocumentReference postDocRef =
          postsCollection.doc(widget.postData.postId);

      // 댓글 컬렉션 참조
      CollectionReference commentsCollection =
          postDocRef.collection('comments');

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

      // 다이얼로그 닫기 (3번 닫아야 원래 화면으로 돌아감)
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('삭제 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListView(
        shrinkWrap: true,
        children: [
          if (widget.currentUserUid == widget.postData.authorUid)
            ListTile(
              title: const Text(
                '수정하기',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(
                      postData: widget.postData,
                      school: widget.postData.school.toString(),
                    ),
                  ),
                ).then((_) {
                  Navigator.pop(context);
                });
              },
            ),
          if (widget.currentUserUid == widget.postData.authorUid)
            ListTile(
              title: const Text(
                '삭제하기',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.alertText),
              ),
              onTap: () {
                _showAlertDialog(context, '게시글을 삭제하시겠습니까?');
              },
            ),
          if (widget.currentUserUid != widget.postData.authorUid)
            ListTile(
              title: const Text(
                '신고하기',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.alertText),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      elevation: 0,
                      actionsPadding: const EdgeInsets.symmetric(horizontal: 9),
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      content: const Text(
                        '신고가 접수되었습니다.',
                        style: TextStyle(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("확인"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

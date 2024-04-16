import 'package:campusmate/screens/community/post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostController extends StatelessWidget {
  const PostController({
    super.key,
    required this.currentUserUid,
    required this.widget,
  });

  final String currentUserUid;
  final PostScreen widget;

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text("알림"),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deletePost(context);
                Navigator.of(context).pop();
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
      await FirebaseFirestore.instance
          .collection(widget.postData.boardType == 'General'
              ? 'generalPosts'
              : 'anonymousPosts')
          .doc(widget.postData.postId)
          .delete();
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('삭제 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        children: [
          if (currentUserUid == widget.postData.authorUid)
            ListTile(
              title: const Text(
                '수정하기',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                // 수정 로직을 여기에 추가하세요
              },
            ),
          if (currentUserUid == widget.postData.authorUid)
            ListTile(
              title: const Text(
                '삭제하기',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                _showAlertDialog(context, '정말 삭제하겠습니까?');
              },
            ),
          if (currentUserUid != widget.postData.authorUid)
            ListTile(
              title: const Text(
                '신고하기',
                textAlign: TextAlign.center,
              ),
              onTap: () {},
            ),
          if (currentUserUid != widget.postData.authorUid)
            ListTile(
              title: const Text(
                '차단하기',
                textAlign: TextAlign.center,
              ),
              onTap: () {},
            ),
        ],
      ),
    );
  }
}

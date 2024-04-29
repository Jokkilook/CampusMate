import 'package:campusmate/screens/community/edit_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusmate/screens/community/models/post_data.dart';

class PostController extends StatefulWidget {
  const PostController({
    Key? key,
    required this.currentUserUid,
    required this.postData,
    required this.school,
  }) : super(key: key);

  final String currentUserUid;
  final PostData postData;
  final String school;

  @override
  State<PostController> createState() => _PostControllerState();
}

class _PostControllerState extends State<PostController> {
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
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
      await FirebaseFirestore.instance
          .collection(widget.postData.boardType == 'General'
              ? 'generalPosts'
              : 'anonymousPosts')
          .doc(widget.postData.postId)
          .delete();
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('삭제 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
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
                      school: widget.school,
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
              ),
              onTap: () {
                _showAlertDialog(context, '정말 삭제하겠습니까?');
              },
            ),
          if (widget.currentUserUid != widget.postData.authorUid)
            ListTile(
              title: const Text(
                '신고하기',
                textAlign: TextAlign.center,
              ),
              onTap: () {},
            ),
          if (widget.currentUserUid != widget.postData.authorUid)
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

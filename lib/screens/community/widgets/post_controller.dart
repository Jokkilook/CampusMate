import 'package:campusmate/app_colors.dart';
import 'package:campusmate/screens/community/edit_post_screen.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:go_router/go_router.dart';

class PostController extends StatefulWidget {
  const PostController({
    super.key,
    required this.currentUserUid,
    required this.postData,
  });

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
              onPressed: () async {
                await PostService().deletePost(postData: widget.postData);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
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
                    ),
                  ),
                ).then((_) {
                  context.pop("edit");
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
                            context.pop();
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

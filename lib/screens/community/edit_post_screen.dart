import 'package:campusmate/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/post_data.dart';
import 'widgets/show_alert_dialog.dart';

class EditPostScreen extends StatefulWidget {
  final PostData postData;
  final String school;

  const EditPostScreen({
    Key? key,
    required this.postData,
    required this.school,
  }) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.postData.title);
    _contentController = TextEditingController(text: widget.postData.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updatePost(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("schools/${widget.school}/" +
              (widget.postData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postData.postId)
          .update({
        'title': _titleController.text,
        'content': _contentController.text,
      });
      Navigator.pop(context);
    } catch (error) {
      debugPrint('게시글 수정 에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextFormField(
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '내용',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: BottomButton(
                text: '작성',
                isCompleted: true,
                onPressed: () {
                  // 제목, 내용을 입력해야 작성됨
                  if (_titleController.value.text == "") {
                    showAlertDialog(context, "제목을 입력해주세요.");
                    return;
                  }
                  if (_contentController.value.text == "") {
                    showAlertDialog(context, "내용을 입력해주세요.");
                    return;
                  }
                  _updatePost(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

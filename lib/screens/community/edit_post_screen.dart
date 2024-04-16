import 'package:campusmate/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:provider/provider.dart';
import '../../models/post_data.dart';

class EditPostScreen extends StatefulWidget {
  final PostData postData;

  const EditPostScreen({Key? key, required this.postData}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedBoard;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.postData.title);
    _contentController = TextEditingController(text: widget.postData.content);
    _selectedBoard = widget.postData.boardType.toString();
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
          .collection(widget.postData.boardType == 'General'
              ? 'generalPosts'
              : 'anonymousPosts')
          .doc(widget.postData.postId)
          .update({
        'title': _titleController.text,
        'content': _contentController.text,
        'boardType': _selectedBoard,
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
            DropdownButtonFormField(
              value: _selectedBoard,
              items: const [
                DropdownMenuItem(child: Text('일반'), value: 'General'),
                DropdownMenuItem(child: Text('익명'), value: 'Anonymous'),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedBoard = value.toString();
                });
              },
              decoration: const InputDecoration(labelText: '게시판 선택'),
            ),
            const SizedBox(height: 20),
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

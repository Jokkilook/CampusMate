import 'package:campusmate/models/post_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Color primaryColor = const Color(0xFF2BB56B);

//ignore: must_be_immutable
class AddPostScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedBoard = 'A';
  final PostData postData = PostData();
  late UserData userData;

  AddPostScreen({super.key});

  Future<void> _addPost(BuildContext context) async {
    try {
      postData.setData();
      await FirebaseFirestore.instance.collection('posts').add(postData.data!);
    } catch (error) {
      debugPrint('안 올라감ㅋ: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "addpost",
      child: Scaffold(
        appBar: AppBar(
          title: const Text('게시글 작성'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField(
                // 게시판 선택
                value: _selectedBoard,
                items: const [
                  DropdownMenuItem(child: Text('일반'), value: 'A'),
                  DropdownMenuItem(child: Text('익명'), value: 'B'),
                ],
                onChanged: (value) {
                  // 선택된 게시판 처리
                  _selectedBoard = value.toString();
                  postData.boardType = _selectedBoard;
                },
                decoration: const InputDecoration(labelText: '게시판 선택'),
              ),
              TextField(
                // 제목 입력
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextFormField(
                  // 내용 입력
                  controller: _contentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
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
                      postData.title = _titleController.value.text;
                      postData.content = _contentController.value.text;
                      postData.timestamp = DateTime.now().toString();
                      _addPost(context);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

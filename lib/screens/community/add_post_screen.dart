import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/models/user_data.dart';

import '../../widgets/bottom_button.dart';
import 'widgets/show_alert_dialog.dart';

Color primaryColor = const Color(0xFF2BB56B);

//ignore: must_be_immutable
class AddPostScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedBoard = 'General';
  final PostData postData = PostData();
  final UserData userData;
  final int currentIndex;

  AddPostScreen(
      {super.key, required this.currentIndex, required this.userData});

  Future<void> _addPost(BuildContext context) async {
    try {
      postData.setData();
      if (_selectedBoard == 'General') {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('schools/${userData.school}/generalPosts')
            .add(postData.data!);
        postData.postId = docRef.id;
        await docRef.update({'postId': postData.postId});
      }
      if (_selectedBoard == 'Anonymous') {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('schools/${userData.school}/anonymousPosts')
            .add(postData.data!);
        postData.postId = docRef.id;
        await docRef.update({'postId': postData.postId});
      }
      Navigator.pop(context);
    } catch (error) {
      debugPrint('에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex != 0) _selectedBoard = 'Anonymous';
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
                  DropdownMenuItem(child: Text('일반'), value: 'General'),
                  DropdownMenuItem(child: Text('익명'), value: 'Anonymous'),
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
                  maxLines: 10,
                  decoration: const InputDecoration(
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
                    postData.authorUid =
                        context.read<UserDataProvider>().userData.uid;
                    postData.timestamp = Timestamp.fromDate(DateTime.now());
                    // 제목, 내용을 입력해야 작성됨
                    if (_titleController.value.text == "") {
                      showAlertDialog(context, "제목을 입력해주세요.");
                      return;
                    }
                    if (_contentController.value.text == "") {
                      showAlertDialog(context, "내용을 입력해주세요.");
                      return;
                    }
                    postData.title = _titleController.value.text;
                    postData.content = _contentController.value.text;
                    _addPost(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

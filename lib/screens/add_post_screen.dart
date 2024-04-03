import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_button.dart';
import 'community_screen.dart';

class AddPostScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  AddPostScreen({super.key});

  String? _selectedBoard;

  Future<void> _saveDataToFirestore(BuildContext context) async {
    try {
      final postsRef = FirebaseFirestore.instance.collection('posts');

      await postsRef.add({
        'board': _selectedBoard,
        'title': _titleController.text,
        'content': _contentController.text,
        'author': '작성자', // 작성자 정보 추가
        'timestamp': DateTime.now(), // 작성 시간 추가
      });

      print('데이터가 Firestore에 저장되었습니다.');

      // 저장 후 CommunityScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CommunityScreen()),
      );
    } catch (error) {
      print('오류 발생: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
      ),
      bottomNavigationBar: BottomButton(
        text: '작성',
        onPressed: () async {
          await _saveDataToFirestore(context);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField(
                value: _selectedBoard,
                items: const [
                  DropdownMenuItem(child: Text('일반'), value: 'A'),
                  DropdownMenuItem(child: Text('익명'), value: 'B'),
                ],
                onChanged: (value) {
                  _selectedBoard = value as String?;
                },
                decoration: const InputDecoration(labelText: '게시판 선택'),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

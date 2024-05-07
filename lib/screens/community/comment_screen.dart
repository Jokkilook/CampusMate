import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatelessWidget {
  PostCommentData postCommentData;

  CommentScreen({
    Key? key,
    required this.postCommentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 댓글 내용
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          postCommentData.content ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '작성자: ${postCommentData.authorUid}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 답글 목록
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCommentReplies(),
                  ),
                ],
              ),
            ),
          ),
          // 답글 입력창
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildCommentReplies() {
    return Container(
      child: const Center(child: Text('답글이 없습니다.')),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '답글을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 작성 버튼
          TextButton(
            onPressed: () async {},
            child: const Text(
              '작성',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

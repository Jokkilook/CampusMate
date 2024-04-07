import 'package:campusmate/models/post_data.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key, required PostData postData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        // 게시판 타입
        title: const Text('일반 게시판'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              const Text(
                '제목일 수도 있고 아닐 수도 있고',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  // 프로필 사진
                  CircleAvatar(
                    radius: 18,
                  ),
                  SizedBox(width: 10),
                  // 작성자
                  Text(
                    '고나우',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 10),
                  // 작성일시
                  Text(
                    '방금',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 내용
              const Text(
                '위 코드에서는 데이터 스냅샷이 null인지 확인하고, 데이터가 null인 경우에 대비하여 적절한 처리를 하도록 수정되었습니다. 데이터가 null일 경우에도 오류가 발생하지 않도록 수정되었으므로 이제 해당 오류가 해결되어야 합니다.',
              ),
              const SizedBox(height: 20),
              // 좋아요, 싫어요 박스
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 좋아요 버튼
                      IconButton(
                        icon: const Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                      // 좋아요 카운트
                      const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // 싫어요 버튼
                      IconButton(
                        icon: const Icon(
                          Icons.thumb_down_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '댓글 0',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

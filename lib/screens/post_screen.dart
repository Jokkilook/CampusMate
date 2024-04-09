import 'package:campusmate/models/post_data.dart';
import 'package:flutter/material.dart';

import '../modules/format_time_stamp.dart';

class PostScreen extends StatelessWidget {
  final PostData postData;

  const PostScreen({
    Key? key,
    required this.postData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(postData.timestamp ?? '', now);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: Text(
          postData.boardType == 'General' ? '일반 게시판' : '익명 게시판',
        ),
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
              Text(
                postData.title ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 프로필 사진
                  const CircleAvatar(
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  // 작성자
                  Text(
                    postData.boardType == 'General'
                        ? postData.author ?? 'null'
                        : '익명',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 작성일시
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 내용
              Text(
                postData.content ?? '',
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
                      Text(
                        postData.likeCount?.toString() ?? '0',
                        style: const TextStyle(
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
              Text(
                '댓글 ${postData.commentCount ?? 0}',
                style: const TextStyle(
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

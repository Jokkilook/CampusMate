import 'package:flutter/material.dart';

class GeneralBoardItem extends StatelessWidget {
  final String title;
  final String author;
  final String content;
  final String likeCount;
  final String dislikeCount;
  final String commentCount;

  const GeneralBoardItem({
    super.key,
    required this.title,
    required this.author,
    required this.content,
    required this.likeCount,
    required this.dislikeCount,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 내용 첫줄
                  SizedBox(
                    width: 250,
                    child: Text(
                      content,
                      overflow:
                          TextOverflow.ellipsis, // 텍스트가 영역을 벗어날 때 "..."으로 처리
                      maxLines: 1, // 텍스트가 한 줄로만 표시되도록 제한
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      // 작성자 닉네임
                      Text(
                        author,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 작성 시간
                      const Text(
                        '| 방금',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      // 좋아요
                      const Icon(
                        Icons.thumb_up_alt_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        likeCount,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 싫어요
                      const Icon(
                        Icons.thumb_down_alt_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dislikeCount,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 댓글
                      const Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        commentCount,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  PostCommentData postCommentData;

  CommentItem({
    super.key,
    required this.postCommentData,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(postCommentData.timestamp!, now);

    return Container(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
              ),
              const SizedBox(width: 10),
              const Text(
                '닉네임',
                style: TextStyle(fontSize: 12),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ],
          ),
          // 댓글 내용
          Container(
            padding: const EdgeInsets.only(left: 46, right: 10),
            child: Text(
              postCommentData.content.toString(),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.only(left: 46, right: 10),
            child: Row(
              children: [
                // 답글 수
                const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  child: Row(
                    children: [
                      // 좋아요
                      const Icon(
                        Icons.thumb_up_alt_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        postCommentData.likers!.length.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                GestureDetector(
                  child: Row(
                    children: [
                      // 싫어요
                      const Icon(
                        Icons.thumb_down_alt_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        postCommentData.dislikers!.length.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

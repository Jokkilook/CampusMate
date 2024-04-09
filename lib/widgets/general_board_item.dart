import 'package:flutter/material.dart';

import '../models/post_data.dart';
import '../modules/format_time_stamp.dart';

class GeneralBoardItem extends StatelessWidget {
  final PostData postData;

  const GeneralBoardItem({
    super.key,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(postData.timestamp ?? '', now);

    return GestureDetector(
      child: Container(
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
                    SizedBox(
                      width: 250,
                      child: Text(
                        postData.title ?? '',
                        overflow:
                            TextOverflow.ellipsis, // 텍스트가 영역을 벗어날 때 "..."으로 처리
                        maxLines: 1, // 텍스트가 한 줄로만 표시되도록 제한
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 내용 첫줄
                    SizedBox(
                      width: 250,
                      child: Text(
                        postData.content ?? '',
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
                          postData.author ?? 'null',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // 작성 시간
                        Text(
                          '| $formattedTime',
                          style: const TextStyle(
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
                          postData.likeCount.toString(),
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
                          postData.dislikeCount.toString(),
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
                          postData.commentCount.toString(),
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
      ),
    );
  }
}

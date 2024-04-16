import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/post_data.dart';
import '../../modules/format_time_stamp.dart';

class AnonymousBoardItem extends StatelessWidget {
  final PostData postData;

  const AnonymousBoardItem({
    super.key,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(postData.timestamp!, now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        // 제목
                        SizedBox(
                          width: 250,
                          child: Text(
                            postData.title ?? '제목 없음',
                            overflow: TextOverflow.ellipsis, // ...처리
                            maxLines: 1, // 1줄 제한
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
                            postData.content ?? '내용 없음',
                            overflow: TextOverflow.ellipsis, // ...처리
                            maxLines: 2, // 2줄 제한
                          ),
                        ),
                      ],
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
                        const SizedBox(width: 10),
                        // 조회수
                        const Icon(
                          Icons.account_circle_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postData.viewCount.toString(),
                          style: const TextStyle(
                            fontSize: 16,
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
                  ],
                ),
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

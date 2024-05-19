import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/post_data.dart';
import '../modules/format_time_stamp.dart';

class GeneralBoardItem extends StatelessWidget {
  final PostData postData;
  final FirebaseFirestore firestore;
  final String school;

  const GeneralBoardItem({
    super.key,
    required this.postData,
    required this.firestore,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(postData.timestamp!, now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      width: double.infinity,
      //height: 100,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //제목 / 내용
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        postData.title ?? '제목 없음',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 내용 첫줄
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        postData.content ?? '내용 없음',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                //닉네임, 게시시간 / 좋,싫,댓,조
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 닉네임, 작성시간
                    Row(
                      children: [
                        // 닉네임
                        Text(
                          postData.authorName.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        // 작성 시간
                        Text(
                          ' | $formattedTime',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    //좋아요, 싫어요, 댓글, 조회수
                    Row(
                      children: [
                        // 좋아요
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postData.likers!.length.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 싫어요
                        const Icon(
                          Icons.thumb_down_alt_outlined,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postData.dislikers!.length.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 댓글
                        const Icon(
                          Icons.mode_comment_outlined,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postData.commentCount.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 조회수
                        const Icon(
                          Icons.account_circle_outlined,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postData.viewers!.length.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            //이미지 썸네일
            Container(
              clipBehavior: Clip.hardEdge,
              width: MediaQuery.of(context).size.height * 0.1,
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: postData.imageUrl != null
                  ? Image.network(
                      postData.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

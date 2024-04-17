import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/post_data.dart';
import '../../modules/format_time_stamp.dart';

class GeneralBoardItem extends StatelessWidget {
  final PostData postData;
  final FirebaseFirestore firestore;

  const GeneralBoardItem({
    super.key,
    required this.postData,
    required this.firestore,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    // 제목
                    SizedBox(
                      width: 250,
                      child: Text(
                        postData.title ?? '제목 없음',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        // 작성자 닉네임 가져오기
                        FutureBuilder<DocumentSnapshot>(
                          future: firestore
                              .collection('users')
                              .doc(postData.authorUid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const Text('No Data');
                            }

                            // 문서에서 사용자 이름 가져오기
                            String authorName = snapshot.data!['name'];

                            return Row(
                              children: [
                                Text(
                                  authorName,
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
                            );
                          },
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

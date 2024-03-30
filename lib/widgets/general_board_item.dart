import 'package:flutter/material.dart';

class GeneralBoardItem extends StatelessWidget {
  const GeneralBoardItem({
    super.key,
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
              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    '제목',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 내용 첫줄
                  Text('글의 첫줄을 보여줍니다.'),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      // 작성자 닉네임
                      Text(
                        '닉네임',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 6),
                      // 작성 시간
                      Text(
                        '| 방금',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      // 좋아요
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      // 싫어요
                      Icon(
                        Icons.thumb_down_alt_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      // 댓글
                      Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '0',
                        style: TextStyle(
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

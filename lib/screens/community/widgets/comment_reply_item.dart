import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentReplyItem extends StatelessWidget {
  const CommentReplyItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 46),
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
            child: const Text(
                'initState() 메서드는 StatefulWidget의 상태가 생성될 때 호출되는 메서드입니다. 이 메서드는 상태가 처음 생성될 때 한 번만 호출되며, 주로 초기화 작업을 수행하는 데 사용됩니다.'),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.only(left: 46, right: 10),
            child: const Row(
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
                SizedBox(width: 14),
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
                Spacer(),
                // 작성시간
                Text(
                  '방금',
                  style: TextStyle(
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

import 'package:campusmate/widgets/thread_item.dart';
import 'package:flutter/material.dart';

class GeneralBoard extends StatelessWidget {
  const GeneralBoard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('일반 게시판'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              size: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 광고 영역
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                '광고 영역',
              ),
            ),
            const ThreadItem(),
            const ThreadItem(),
            const ThreadItem(),
            const ThreadItem(),
          ],
        ),
      ),
    );
  }
}

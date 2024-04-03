import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatelessWidget {
  final String postId;

  const PostScreen({required this.postId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            // 데이터 스냅샷이 null인지 확인
            return const Center(
              child: Text('게시글을 찾을 수 없습니다.'),
            );
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? '', // 데이터가 없을 경우를 대비하여 null 체크
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data['content'] ?? '', // 데이터가 없을 경우를 대비하여 null 체크
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(
                      data['author'] ?? '', // 데이터가 없을 경우를 대비하여 null 체크
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      data['timestamp']?.toString() ??
                          '', // 데이터가 없을 경우를 대비하여 null 체크
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

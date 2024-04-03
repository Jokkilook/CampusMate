import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ad_area.dart';
import 'add_post_screen.dart';
import '../widgets/general_board_item.dart';
import '../widgets/anonymous_board_item.dart'; // AnonymousBoardItem을 import 해야 합니다.

Color primaryColor = const Color(0xFF2BB56B);

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 수를 2개로 설정
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black,
          title: const Text('커뮤니티'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                size: 30,
              ),
            )
          ],
          bottom: TabBar(
            isScrollable: false,
            indicatorColor: primaryColor,
            indicatorWeight: 4,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: '일반'),
              Tab(text: '익명'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TabBarView(
            children: [
              // 일반 게시판
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('데이터가 없습니다.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return Column(
                          children: [
                            if (index == 0 || (index + 1) % 10 == 0) ...[
                              const SizedBox(height: 12),
                              const AdArea(),
                            ],
                            // 데이터를 GeneralBoardItem에 넣어서 표시
                            GeneralBoardItem(
                              title: data['title'] ?? '',
                              content: data['content'] ?? '',
                              author: data['author'] ?? '',
                              timestamp: data['timestamp']?.toString() ?? '',
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // 익명 게시판
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('데이터가 없습니다.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return Column(
                          children: [
                            if (index == 0 || (index + 1) % 10 == 0) ...[
                              const SizedBox(height: 12),
                              const AdArea(),
                            ],
                            AnonymousBoardItem(
                              title: data['title'] ?? '',
                              content: data['content'] ?? '',
                              author: data['author'] ?? '',
                              timestamp: data['timestamp']?.toString() ?? '',
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "addpost",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPostScreen()),
            );
          },
          child: const Icon(Icons.add, size: 30),
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF0A351E),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        bottomNavigationBar: const SizedBox(
          height: 70,
        ),
      ),
    );
  }
}

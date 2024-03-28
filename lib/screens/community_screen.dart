import 'package:campusmate/widgets/anonymous_board_item.dart';
import 'package:campusmate/widgets/general_board_item.dart';
import 'package:flutter/material.dart';

import '../widgets/ad_area.dart';
import 'add_post_screen.dart';

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
                child: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index) {
                    // 10번째 아이템마다 광고 영역 추가
                    if (index == 0 || (index + 1) % 10 == 0) {
                      return const Column(
                        children: [
                          SizedBox(height: 12),
                          AdArea(),
                          GeneralBoardItem(),
                        ],
                      );
                    } else {
                      return const GeneralBoardItem();
                    }
                  },
                ),
              ),
              // 익명 게시판
              Expanded(
                child: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index) {
                    // 10번째 아이템마다 광고 영역 추가
                    if (index == 0 || (index + 1) % 10 == 0) {
                      return const Column(
                        children: [
                          SizedBox(height: 12),
                          AdArea(),
                          AnonymousBoardItem(),
                        ],
                      );
                    } else {
                      return const AnonymousBoardItem();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPostScreen()),
            );
          },
          child: const Icon(Icons.add, size: 40),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            print(value);
          },
          elevation: 1,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "finding"),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble), label: "chatting"),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_list_outlined), label: "community"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: "myInfo"),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "more")
          ],
        ),
      ),
    );
  }
}

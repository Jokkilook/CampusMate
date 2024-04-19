import 'package:campusmate/screens/community/post_screen.dart';
import 'package:campusmate/widgets/community/anonymous_board_item.dart';
import 'package:campusmate/widgets/community/general_board_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/post_data.dart';
import 'add_post_screen.dart';

Color primaryColor = const Color(0xFF2BB56B);

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    super.key,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  Future<void> _refreshScreen() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {});
  }

  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black,
          title: const Text('커뮤니티'),
          actions: [
            // 검색
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                size: 30,
              ),
            ),
            // 내가 쓴 글 조회
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.person_outlined,
                size: 30,
              ),
            ),
          ],
          bottom: TabBar(
            controller: tabController,
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
        body: TabBarView(
          children: [
            // 일반 게시판
            RefreshIndicator(
              onRefresh: _refreshScreen,
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('generalPosts')
                    .orderBy('timestamp', descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  var data = snapshot.data!.docs;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text('게시글이 없습니다.'),
                    );
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(height: 0);
                    },
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var postData = PostData.fromJson(
                          data[index].data() as Map<String, dynamic>);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(
                                postData: postData,
                                firestore: FirebaseFirestore.instance,
                              ),
                            ),
                          ).then((_) {
                            _refreshScreen();
                          });
                        },
                        child: GeneralBoardItem(
                          postData: postData,
                          firestore: FirebaseFirestore.instance,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // 익명 게시판
            RefreshIndicator(
              onRefresh: _refreshScreen,
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('anonymousPosts')
                    .orderBy('timestamp', descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  var data = snapshot.data!.docs;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text('게시글이 없습니다.'),
                    );
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(height: 0);
                    },
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var postData = PostData.fromJson(
                          data[index].data() as Map<String, dynamic>);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(
                                postData: postData,
                                firestore: FirebaseFirestore.instance,
                              ),
                            ),
                          ).then((_) {
                            _refreshScreen();
                          });
                        },
                        child: AnonymousBoardItem(
                          postData: postData,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "addpost",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AddPostScreen(currentIndex: tabController.index)),
            ).then((_) {
              // AddPostScreen이 닫힌 후에 CommunityScreen을 새로고침
              _refreshScreen();
            });
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

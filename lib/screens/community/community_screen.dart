import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/my_posts_screen.dart';
import 'package:campusmate/screens/community/post_screen.dart';
import 'package:campusmate/screens/community/post_search_screen.dart';
import 'package:campusmate/screens/community/widgets/anonymous_board_item.dart';
import 'package:campusmate/screens/community/widgets/general_board_item.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/post_data.dart';
import 'add_post_screen.dart';

Color primaryColor = const Color(0xFF2BB56B);

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _refreshScreen();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshScreen() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("커뮤니티"),
              Text(
                userData.school ?? "",
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: [
            // 검색
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostSearchScreen(),
                  ),
                ).then((_) {
                  _refreshScreen();
                });
              },
              icon: const Icon(
                Icons.search,
              ),
            ),
            // 내가 쓴 글 조회
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPostsScreen(),
                  ),
                ).then((_) {
                  _refreshScreen();
                });
              },
              icon: const Icon(
                Icons.person_outlined,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            isScrollable: false,
            indicatorColor: primaryColor,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: isDark ? AppColors.darkTitle : AppColors.lightTitle,
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
          controller: _tabController,
          children: [
            // 일반 게시판
            RefreshIndicator(
              onRefresh: _refreshScreen,
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('schools/${userData.school}/generalPosts')
                    .orderBy('timestamp', descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircleLoading(),
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
                      return Divider(
                        height: 0,
                        color:
                            isDark ? AppColors.darkLine : AppColors.lightLine,
                      );
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
                                userData: userData,
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
                    .collection('schools/${userData.school}/anonymousPosts')
                    .orderBy('timestamp', descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircleLoading(),
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
                      return Divider(
                        height: 0,
                        color:
                            isDark ? AppColors.darkLine : AppColors.lightLine,
                      );
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
                                userData: userData,
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
          heroTag: "addPost",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddPostScreen(
                        currentIndex: _tabController.index,
                        userData: userData,
                      )),
            ).then((_) {
              _refreshScreen();
            });
          },
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
          backgroundColor: AppColors.button,
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

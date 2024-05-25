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
            _buildGeneralBoard(userData, isDark),
            _buildAnonymousBoard(userData, isDark),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "addPost",
          onPressed: () {
            debugPrint('index: ${_tabController.index}');
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
            color: AppColors.buttonText,
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

  Widget _buildGeneralBoard(UserData userData, bool isDark) {
    return RefreshIndicator(
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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('게시글이 없습니다.'),
            );
          }
          var data = snapshot.data!.docs;
          return ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
                color: isDark ? AppColors.darkLine : AppColors.lightLine,
              );
            },
            itemCount: data.length,
            itemBuilder: (context, index) {
              try {
                var postData = PostData.fromJson(
                    data[index].data() as Map<String, dynamic>);
                if (postData.authorUid == null || postData.authorUid!.isEmpty) {
                  // 작성자 UID가 없으면 건너뛰기
                  return const SizedBox.shrink();
                }
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
              } catch (e) {
                // 예외 발생 시 건너뛰기
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAnonymousBoard(UserData userData, bool isDark) {
    return RefreshIndicator(
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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('게시글이 없습니다.'),
            );
          }
          var data = snapshot.data!.docs;
          return ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
                color: isDark ? AppColors.darkLine : AppColors.lightLine,
              );
            },
            itemCount: data.length,
            itemBuilder: (context, index) {
              try {
                var postData = PostData.fromJson(
                    data[index].data() as Map<String, dynamic>);
                if (postData.authorUid == null || postData.authorUid!.isEmpty) {
                  // 작성자 UID가 없으면 건너뛰기
                  return const SizedBox.shrink();
                }
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
              } catch (e) {
                // 예외 발생 시 건너뛰기
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}

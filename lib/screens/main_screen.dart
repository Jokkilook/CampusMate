import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/chatting/chat_list_screen.dart';
import 'package:campusmate/screens/community/community_screen.dart';
import 'package:campusmate/screens/matching/matching_screen.dart';
import 'package:campusmate/screens/more/more_screen.dart';
import 'package:campusmate/screens/profile/profile_screen.dart';
import 'package:campusmate/widgets/fadein_indexedstack.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.index = 0});
  final int index;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final fcmToken = FirebaseMessaging.instance.getToken();

  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return PopScope(
      canPop: canPop,
      onPopInvoked: (bool value) async {
        setState(() {
          canPop = !value;
        });

        if (canPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.black.withOpacity(0.8),
              content: const Text(
                "뒤로가기를 한번 더 누르면 앱이 종료됩니다.",
                style: TextStyle(color: Colors.white),
              ),
              duration: const Duration(milliseconds: 1500),
            ),
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            setState(() {
              canPop = false;
            });
          });
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Consumer<UserDataProvider>(
          builder: (context, userData, child) {
            return FadeIndexedStack(
              duration: const Duration(milliseconds: 100),
              index: index,
              children: [
                const MatchingScreen(),
                ChatListScreen(),
                const CommunityScreen(),
                ProfileScreen(),
                const MoreScreen()
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  width: 1,
                  color: isDark ? Colors.grey[800]! : Colors.grey[400]!),
            ),
          ),
          height: 70,
          child: BottomNavigationBar(
            selectedItemColor: Colors.green,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
            onTap: (value) {
              index = value;
              setState(() {});
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined), label: "친구찾기"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble), label: "채팅"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.view_list_outlined), label: "커뮤니티"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), label: "내 정보"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz), label: "더보기")
            ],
          ),
        ),
      ),
    );
  }
}

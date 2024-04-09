import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/chatting/chat_list_screen.dart';
import 'package:campusmate/screens/community/community_screen.dart';
import 'package:campusmate/screens/matching_screen.dart';
import 'package:campusmate/screens/more_screen.dart';
import 'package:campusmate/screens/profile/profile_screen.dart';
import 'package:campusmate/widgets/fadein_indexedstack.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.index = 0});
  final index;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final List<Widget> list = [
    const MatchingScreen(), //0
    ChatListScreen(), //1
    const CommunityScreen(), //2
    ProfileScreen(), //3
    MoreScreen() //4
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    index = widget.index;
  }

  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (bool value) async {
        setState(() {
          canPop = !value;
        });

        if (canPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              content: const Text("뒤로가기를 한번 더 누르면 앱이 종료됩니다."),
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
                MoreScreen()
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5,
              ),
            ],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(20)),
          ),
          height: 70,
          child: BottomNavigationBar(
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.black45,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.shifting,
            currentIndex: index,
            onTap: (value) {
              index = value;
              setState(() {});
            },
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined), label: "finding"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble), label: "chatting"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.view_list_outlined), label: "community"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), label: "myInfo"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz), label: "more")
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/group_chat_room_data.dart';
import 'package:campusmate/screens/chatting/chat_list_screen.dart';
import 'package:campusmate/screens/chatting/chat_room_screen.dart';
import 'package:campusmate/screens/chatting/chat_room_search_screen.dart';
import 'package:campusmate/screens/chatting/group_chat_room_generation_screen.dart';
import 'package:campusmate/screens/chatting/video_player_screen.dart';
import 'package:campusmate/screens/community/add_post_screen.dart';
import 'package:campusmate/screens/community/community_screen.dart';
import 'package:campusmate/screens/community/my_posts_screen.dart';
import 'package:campusmate/screens/community/post_screen.dart';
import 'package:campusmate/screens/community/post_search_screen.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/more/my_info_screen.dart';
import 'package:campusmate/screens/more/theme_setting_screen.dart';
import 'package:campusmate/screens/profile/profile_revise_screen.dart';
import 'package:campusmate/screens/profile/profile_screen.dart';
import 'package:campusmate/screens/profile/profile_setting_a.dart';
import 'package:campusmate/screens/profile/profile_setting_b.dart';
import 'package:campusmate/screens/profile/profile_setting_c.dart';
import 'package:campusmate/screens/profile/profile_setting_result.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:campusmate/screens/register/register_result.dart';
import 'package:campusmate/screens/register/register_screen_a.dart';
import 'package:campusmate/screens/register/register_screen_b.dart';
import 'package:campusmate/screens/register/register_screen_c.dart';
import 'package:campusmate/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final router = GoRouter(initialLocation: Screen.splash, routes: [
  //스플래쉬 화면
  GoRoute(
    name: Screen.splash,
    path: Screen.splash,
    builder: (context, state) => const SplashScreen(),
  ),

  //메인 화면
  GoRoute(
    name: Screen.main,
    path: Screen.main,
    onExit: (context, state) {
      return true;
    },
    builder: (context, state) {
      final int index = (state.extra ?? 0) as int;
      return MainScreen(index: index);
    },
  ),

  //로그인 화면
  GoRoute(
    name: Screen.login,
    path: Screen.login,
    builder: (context, state) => const LoginScreen(),
  ),

  //회원가입A 화면
  GoRoute(
    name: Screen.registerA,
    path: Screen.registerA,
    builder: (context, state) => const RegisterScreenA(),
  ),

  //회원가입B 화면
  GoRoute(
    name: Screen.registerB,
    path: Screen.registerB,
    builder: (context, state) => RegisterScreenB(),
  ),

  //회원가입C 화면
  GoRoute(
    name: Screen.registerC,
    path: Screen.registerC,
    builder: (context, state) => RegisterScreenC(),
  ),

  //회원가입 중간결과 화면
  GoRoute(
    name: Screen.registerResult,
    path: Screen.registerResult,
    builder: (context, state) => const RegisterResult(),
  ),

  //프로필 설정A 화면
  GoRoute(
    name: Screen.profileA,
    path: Screen.profileA,
    builder: (context, state) => const ProfileSettingA(),
  ),

  //프로필 설정B 화면
  GoRoute(
    name: Screen.profileB,
    path: Screen.profileB,
    builder: (context, state) => const ProfileSettingB(),
  ),

  //프로필 설정C 화면
  GoRoute(
    name: Screen.profileC,
    path: Screen.profileC,
    builder: (context, state) => const ProfileSettingC(),
  ),

  //프로필 설정 결과 화면
  GoRoute(
    name: Screen.profileResult,
    path: Screen.profileResult,
    builder: (context, state) => const ProfileSettingResult(),
  ),

  //타 유저 프로필 화면
  GoRoute(
    name: Screen.otherProfile,
    path: "${Screen.otherProfile}/uid=:uid&readOnly=:readOnly",
    onExit: (context, state) {
      return true;
    },
    builder: (context, state) {
      final String uid = state.pathParameters["uid"] ?? "";
      final bool readOnly =
          (state.pathParameters["readOnly"] ?? "false") == "true";
      return StrangerProfilScreen(
        uid: uid,
        readOnly: readOnly,
      );
    },
  ),

  //내 프로필 화면
  GoRoute(
    name: Screen.myProfile,
    path: Screen.myProfile,
    builder: (context, state) => const ProfileScreen(),
    routes: [
      //프로필 수정 화면
      GoRoute(
        name: Screen.editProfile,
        path: Screen.editProfile,
        builder: (context, state) => ProfileReviseScreen(),
      ),
    ],
  ),

  //채팅방 리스트 화면
  GoRoute(
    name: Screen.chatList,
    path: Screen.chatList,
    builder: (context, state) => ChatListScreen(),
  ),

  //채팅방 화면
  GoRoute(
    name: Screen.chatRoom,
    path: "${Screen.chatRoom}/:isGroup",
    onExit: (context, state) {
      return true;
    },
    builder: (context, state) {
      final bool isGroup =
          state.pathParameters["isGroup"] == "group" ? true : false;
      var data = state.extra;
      final ChatRoomData crd = data as ChatRoomData;
      final GroupChatRoomData? grd =
          isGroup ? (data as GroupChatRoomData) : null;

      return ChatRoomScreen(
        chatRoomData: crd,
        groupRoomData: isGroup ? grd : null,
        isGroup: isGroup,
      );
    },
  ),

  //채팅방 검색 화면
  GoRoute(
    name: Screen.chatRoomSearch,
    path: Screen.chatRoomSearch,
    builder: (context, state) => ChatRoomSearchScreen(),
  ),

  //그룹 채팅방 생성 화면
  GoRoute(
    name: Screen.generateGroupRoom,
    path: Screen.generateGroupRoom,
    builder: (context, state) => const GroupChatRoomGenerationScreen(),
  ),

  //커뮤니티 화면
  GoRoute(
    name: Screen.community,
    path: Screen.community,
    builder: (context, state) => const CommunityScreen(),
    routes: [
      //일반 게시글 상세페이지
      GoRoute(
        name: Screen.post,
        path: "${Screen.post}=:postId",
        onExit: (context, state) {
          return true;
        },
        builder: (context, state) {
          final String postId = state.pathParameters["postId"] ?? "";
          return PostScreen(
            postId: postId,
            isAnonymous: false,
          );
        },
      ),

      //익명 게시글 상세페이지
      GoRoute(
        name: Screen.anonymousPost,
        path: "${Screen.anonymousPost}=:postId",
        onExit: (context, state) {
          return true;
        },
        builder: (context, state) {
          final String postId = state.pathParameters["postId"] ?? "";
          return PostScreen(
            postId: postId,
            isAnonymous: true,
          );
        },
      )
    ],
  ),

  //게시글 추가 화면
  GoRoute(
    name: Screen.addPost,
    path: Screen.addPost,
    builder: (context, state) {
      final int index = (state.extra ?? 0) as int;
      return AddPostScreen(currentIndex: index);
    },
  ),

  //게시글 검색 화면
  GoRoute(
    name: Screen.searchPost,
    path: Screen.searchPost,
    builder: (context, state) => const PostSearchScreen(),
  ),

  //내 정보 화면
  GoRoute(
    name: Screen.myInfo,
    path: Screen.myInfo,
    builder: (context, state) => const MyInfoScreen(),
  ),

  //내가 쓴 게시글 화면
  GoRoute(
    name: Screen.myPosts,
    path: Screen.myPosts,
    builder: (context, state) => const MyPostsScreen(),
  ),

  //앱 테마 화면
  GoRoute(
    name: Screen.themeSetting,
    path: Screen.themeSetting,
    builder: (context, state) => ThemeSettingScreen(),
  ),

  //비디오 플레이어 화면
  GoRoute(
    name: Screen.videoPlayer,
    path: "${Screen.videoPlayer}/:url",
    builder: (context, state) {
      final String url = state.pathParameters["url"].toString();
      return VideoPlayerScreen(url: url);
    },
  ),
]);

class Screen {
  static String splash = '/splash';
  static String main = '/main';
  static String login = '/login';
  static String registerA = '/register_a';
  static String registerB = '/register_b';
  static String registerC = '/register_c';
  static String registerResult = '/register_result';
  static String profileA = '/profile_a';
  static String profileB = '/profile_b';
  static String profileC = '/profile_c';
  static String profileResult = '/profile_result';
  static String otherProfile = '/other_profile';
  static String myProfile = '/my_profile';
  static String editProfile = 'edit_profile';
  static String chatList = '/chat_list';
  static String chatRoom = '/chat_room';
  static String chatRoomSearch = '/chat_room_search';
  static String generateGroupRoom = '/generate_group_room';
  static String community = '/community';
  static String post = 'post';
  static String anonymousPost = 'anonymous_post';
  static String editPost = '/edit_post';
  static String addPost = '/add_post';
  static String searchPost = '/search_post';
  static String myPosts = '/my_posts';
  static String myInfo = '/my_info';
  static String themeSetting = '/theme_setting';
  static String videoPlayer = '/video_player';
}

import 'package:campusmate/Theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppInfoScreen extends StatelessWidget {
  AppInfoScreen({super.key});

  final List<String> packageList = [
    "firebase",
    "firebase_core",
    "firebase_auth",
    "firebase_database",
    "firebase_storage",
    "cloud_firestore",
    "firebase_messaging",
    "firebase_analytics",
    "firebase_app_check",
    "flutter_local_notifications",
    "googleapis_auth",
    "google_mobile_ads",
    "cupertino_icons",
    "provider",
    "go_router",
    "shared_preferences",
    "async",
    "mailer",
    "crypto",
    "excel",
    "intl",
    "uuid",
    "flutter_card_swiper",
    "dropdown_search",
    "extended_wrap",
    "auto_size_text",
    "auto_size_text_field",
    "image_picker",
    "cached_network_image",
    "flutter_cache_manager",
    "insta_image_viewer",
    "video_player",
    "flutter_image_compress",
    "video_compress",
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("앱 정보"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //개발진 정보
              const Text(
                " 개발자",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      isDark ? AppColors.darkCard : AppColors.lightInnerSection,
                ),
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " 캠퍼스메이트 [ 조성윤, 박관우 ]",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              //패키지 리스트
              const Text(
                " 사용된 패키지",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      isDark ? AppColors.darkCard : AppColors.lightInnerSection,
                ),
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (String package in packageList)
                      Text(
                        package,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),

              //앱 버전
              const Text(
                " 버전",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      isDark ? AppColors.darkCard : AppColors.lightInnerSection,
                ),
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ver 1.0.0",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

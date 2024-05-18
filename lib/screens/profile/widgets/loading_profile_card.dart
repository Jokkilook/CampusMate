import 'package:campusmate/app_colors.dart';
import 'package:campusmate/screens/profile/widgets/loading_schedule_table.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///프로필 화면에서 정보 로딩 위젯<br>

class LoadingProfileCard extends StatelessWidget {
  const LoadingProfileCard({super.key, this.canAd = true});
  final bool canAd;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return SingleChildScrollView(
      child: Consumer(
        builder: (context, mediaData, child) => Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              canAd ? const AdArea() : Container(),
              canAd ? const SizedBox(height: 12) : Container(),
              // 프로필 카드
              Container(
                clipBehavior: Clip.hardEdge,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 0),
                        blurRadius: 2)
                  ],
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      color: isDark
                          ? AppColors.darkInnerSection
                          : AppColors.lightInnerSection,
                      height: MediaQuery.of(context).size.width * 0.9,
                      width: double.infinity,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkInnerSection
                              : AppColors.lightInnerSection,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "                    ",
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTitle
                              : AppColors.lightTitle,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // 자기소개
                          Container(
                            width: double.infinity,
                            height: 80,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // 정보, 매너학점
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ' ',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkTitle
                                                : AppColors.lightTitle,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          ' ',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                        Text(
                                          ' ',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                        Text(
                                          ' ',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                ' ',
                                                style: TextStyle(
                                                    color: isDark
                                                        ? AppColors.darkTitle
                                                        : AppColors.lightTitle,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              " ",
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors.darkText
                                                    : AppColors.lightText,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //성향, 태그
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ' ',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTitle
                                          : AppColors.lightTitle,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    ' ',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText,
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (var i = 0; i < 8; i++)
                                        Container(
                                          decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.darkTag
                                                  : AppColors.lightTag,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: Text(
                                            "      ",
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColors.darkText
                                                  : AppColors.lightText,
                                            ),
                                          ),
                                        )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),

                          //시간표
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Text(
                                      ' ',
                                      style: TextStyle(
                                          color: isDark
                                              ? AppColors.darkTitle
                                              : AppColors.lightTitle,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                    child: LoadingScheduleTable(),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
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

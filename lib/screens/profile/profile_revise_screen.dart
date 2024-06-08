// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/profile/widgets/loading_profile_card.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/services/profile_service.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:campusmate/screens/profile/widgets/schedule_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

///프로필 수정 화면
//ignore: must_be_immutable
class ProfileReviseScreen extends StatefulWidget {
  ProfileReviseScreen({super.key});

  late UserData modifiedData;

  @override
  State<ProfileReviseScreen> createState() => ProfileReviseScreenState();
}

class ProfileReviseScreenState extends State<ProfileReviseScreen> {
  ImagePicker imagePicker = ImagePicker();

  final String uid = FirebaseAuth.instance.currentUser?.uid.toString() ?? "";

  TextEditingController nameController = TextEditingController();

  TextEditingController introController = TextEditingController();

  late bool EI;

  late bool NS;

  late bool TF;

  late bool PJ;

  late var image;

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    image = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('프로필 수정'),
      ),
      body: Stack(
        children: [
          //캐시에서 사용자 정보를 불러옴
          FutureBuilder<DocumentSnapshot>(
            future: AuthService()
                .getUserDocumentSnapshot(uid: uid, options: Source.server),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingProfileCard(canAd: false);
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("오류가 발생했어요!"),
                      const SizedBox(height: 20),
                      IconButton.filled(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        color: Colors.green,
                        iconSize: MediaQuery.of(context).size.width * 0.08,
                      )
                    ],
                  ),
                );
              } else {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                widget.modifiedData = UserData.fromJson(data);

                introController.value =
                    TextEditingValue(text: widget.modifiedData.introduce!);
                nameController.value =
                    TextEditingValue(text: widget.modifiedData.name!);

                return wholeProfile(widget, widget.modifiedData, context);
              }
            },
          ),
          //수정완료 버튼
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Hero(
              tag: "revise",
              child: BottomButton(
                text: "수정완료",
                isCompleted: true,
                isLoading: isLoading,
                onPressed: () async {
                  isLoading = true;

                  //로딩 오버레이 표시
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return const Center(
                        child: CircleLoading(),
                      );
                    },
                  );

                  final FirebaseFirestore firestore =
                      FirebaseFirestore.instance;

                  String name = nameController.value.text;
                  widget.modifiedData.name = name;
                  widget.modifiedData.introduce = introController.value.text;
                  widget.modifiedData.mbti =
                      "${EI ? "E" : "I"}${NS ? "N" : "S"}${TF ? "T" : "F"}${PJ ? "P" : "J"}";

                  //이미지 변경시 이미지 변경 로직 실행
                  if (image != null) {
                    //이미지 압축
                    XFile? compMedia =
                        await FlutterImageCompress.compressAndGetFile(
                            image?.path ?? "", "${image?.path}.jpg");

                    //프로필 이미지 파일 레퍼런스
                    var ref = FirebaseStorage.instance.ref().child(
                        "schools/${widget.modifiedData.school}/profileImages/${widget.modifiedData.uid}.png");

                    //파이어스토어에 이미지 파일 업로드
                    await ref.putFile(File(compMedia!.path));

                    //변경할 데이터에 변경된 url 저장
                    String imageUrl = await ref.getDownloadURL();
                    widget.modifiedData.imageUrl = imageUrl;

                    //채팅방 프로필 url 업데이트
                    await firestore
                        .collection(
                            "schools/${widget.modifiedData.school}/chats")
                        .where("participantsUid",
                            arrayContains: widget.modifiedData.uid)
                        .get()
                        .then(
                      (value) {
                        if (value.docs.isNotEmpty) {
                          var docs = value.docs;
                          for (var doc in docs) {
                            String id = doc.id;
                            Map<String, dynamic> data = doc.data();
                            Map<String, List<String>> userInfo =
                                (data["participantsInfo"]
                                        as Map<String, dynamic>)
                                    .map((key, value) {
                              return MapEntry(
                                  key, (value as List<dynamic>).cast<String>());
                            });

                            userInfo[widget.modifiedData.uid!] = [
                              widget.modifiedData.name!,
                              widget.modifiedData.imageUrl!
                            ];

                            firestore
                                .collection(
                                    "schools/${widget.modifiedData.school}/chats")
                                .doc(id)
                                .update({"participantsInfo": userInfo});
                          }
                        }
                      },
                    );

                    //그룹 채팅방 프로필 url 업데이트
                    await firestore
                        .collection(
                            "schools/${widget.modifiedData.school}/groupChats")
                        .where("participantsUid",
                            arrayContains: widget.modifiedData.uid)
                        .get()
                        .then(
                      (value) {
                        if (value.docs.isNotEmpty) {
                          var docs = value.docs;
                          for (var doc in docs) {
                            String id = doc.id;
                            Map<String, dynamic> data = doc.data();
                            Map<String, List<String>> userInfo =
                                (data["participantsInfo"]
                                        as Map<String, dynamic>)
                                    .map((key, value) {
                              return MapEntry(
                                  key, (value as List<dynamic>).cast<String>());
                            });

                            userInfo[widget.modifiedData.uid!] = [
                              widget.modifiedData.name!,
                              widget.modifiedData.imageUrl!
                            ];

                            firestore
                                .collection(
                                    "schools/${widget.modifiedData.school}/groupChats")
                                .doc(id)
                                .update({"participantsInfo": userInfo});
                          }
                        }
                      },
                    );
                  }

                  context.read<UserDataProvider>().userData =
                      widget.modifiedData;

                  await AuthService().setUserData(widget.modifiedData);
                  await ProfileService()
                      .updateCommunityProfile(widget.modifiedData);

                  context.pop();
                  context.pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView wholeProfile(
      ProfileReviseScreen parent, UserData userData, BuildContext context) {
    widget.modifiedData = userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    EI = userData.mbti![0] == "E";
    NS = userData.mbti![1] == "N";
    TF = userData.mbti![2] == "T";
    PJ = userData.mbti![3] == "P";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          clipBehavior: Clip.hardEdge,
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 0),
                  blurRadius: 2)
            ],
            color:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              //사진 변경
              GestureDetector(
                onTap: () {
                  showDialog(
                    barrierColor: Colors.black.withOpacity(0.4),
                    context: context,
                    builder: (context) {
                      return Dialog(
                        clipBehavior: Clip.hardEdge,
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: IntrinsicHeight(
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    image = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {});
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                      "갤러리",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                const Divider(height: 0),
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    image = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    if (image != null) {
                                      setState(() {});
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                      "카메라",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.9,
                  child: image == null
                      ? Image.network(
                          widget.modifiedData.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(image!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 10),
              //이름입력
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IntrinsicWidth(
                  child: TextField(
                    scrollPadding: const EdgeInsets.only(bottom: 100),
                    cursorColor:
                        isDark ? AppColors.darkTitle : AppColors.lightTitle,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 5),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color:
                            isDark ? AppColors.darkTitle : AppColors.lightTitle,
                      )),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color:
                            isDark ? AppColors.darkTitle : AppColors.lightTitle,
                      )),
                    ),
                    maxLength: 10,
                    controller: nameController,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isDark ? AppColors.darkTitle : AppColors.lightTitle,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // 자기소개
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkInnerSection
                            : AppColors.lightInnerSection,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '자기소개',
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTitle
                                    : AppColors.lightTitle,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputTextField(
                            isDark: isDark,
                            scrollPadding: const EdgeInsets.only(bottom: 120),
                            controller: introController,
                            minLines: 1,
                            maxLines: 10,
                            maxLength: 500,
                            keyboardType: TextInputType.multiline,
                            hintText: "프로필에 표시될 소개를 적어보세요!",
                          )
                        ],
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
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '내 정보',
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
                              '나이  ${DateTime.now().year - int.parse(widget.modifiedData.birthDate!.split(".")[0])}'),
                          Text(
                              '성별  ${widget.modifiedData.gender! ? "남" : "여"}'),
                          Text('학과  ${widget.modifiedData.dept}'),
                        ],
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '성향',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          MBTISelector(
                              parent: this, EI: EI, NS: NS, TF: TF, PJ: PJ),
                        ],
                      ),
                    ),
                    TagShower(parent: this),

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              '시간표',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: ScheduleTable(
                                scheduleData: widget.modifiedData.schedule,
                                readOnly: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60)
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

//태그 선택 위젯
class TagShower extends StatefulWidget {
  const TagShower({super.key, required this.parent});
  final ProfileReviseScreenState parent;

  @override
  State<TagShower> createState() => _TagShowerState();
}

class _TagShowerState extends State<TagShower> {
  late List<String> userTag =
      widget.parent.widget.modifiedData.tags!.cast<String>();
  var tagList = [
    "공부",
    "동네",
    "취미",
    "식사",
    "카풀",
    "술",
    "등하교",
    "시간 떼우기",
    "연애",
    "편입",
    "취업",
    "토익",
    "친분",
    "연상",
    "동갑",
    "연하",
    "선배",
    "동기",
    "후배"
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkInnerSection : AppColors.lightInnerSection,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                '태그',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '  ${userTag.length}/8',
                style: TextStyle(
                  color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 10,
            children: [
              for (var tag in tagList)
                OutlinedButton(
                  onPressed: () {
                    if (userTag.contains(tag)) {
                      //유저 태그 리스트에 태그가 있으면 삭제
                      userTag.remove(tag);
                    } else if (userTag.length < 8) {
                      //유저 태그 리스트에 태그가 없고 리스트가 8개를 넘지 않으면 추가
                      userTag.add(tag);
                    }

                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                      side: userTag.contains(tag)
                          ? const BorderSide(width: 2, color: Colors.green)
                          : BorderSide(
                              width: 0, color: Colors.white.withOpacity(0)),
                      backgroundColor: userTag.contains(tag)
                          ? Colors.green
                          : (isDark ? AppColors.darkTag : AppColors.lightTag),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5)),
                  child: Text(
                    tag,
                    style: TextStyle(
                        color: userTag.contains(tag)
                            ? const Color(0xff0B351E)
                            : (isDark
                                ? AppColors.darkTitle
                                : AppColors.lightTitle)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

//MBTI 선택 위젯
//ignore: must_be_immutable
class MBTISelector extends StatefulWidget {
  MBTISelector(
      {super.key,
      required this.parent,
      this.EI = true,
      this.NS = true,
      this.TF = true,
      this.PJ = true});

  bool EI; //true = E, false = I
  bool NS; //true = N, false = S
  bool TF; //true = T, false = F
  bool PJ; //true = P, false = J
  final ProfileReviseScreenState parent;

  @override
  State<MBTISelector> createState() => _MBTISelectorState();
}

class _MBTISelectorState extends State<MBTISelector> {
  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.EI = true;
              widget.parent.EI = widget.EI;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: widget.EI
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
            ),
            child: Text(
              "E",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.EI ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.EI = false;
              widget.parent.EI = widget.EI;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: !widget.EI
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
            ),
            child: Text(
              "I",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.EI ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.NS = true;
              widget.parent.NS = widget.NS;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: widget.NS
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
            ),
            child: Text(
              "N",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.NS ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.NS = false;
              widget.parent.NS = widget.NS;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: !widget.NS
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
            ),
            child: Text(
              "S",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.NS ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.TF = true;
              widget.parent.TF = widget.TF;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: widget.TF
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
            ),
            child: Text(
              "T",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.TF ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.TF = false;
              widget.parent.TF = widget.TF;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: !widget.TF
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
            ),
            child: Text(
              "F",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.TF ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.PJ = true;
              widget.parent.PJ = widget.PJ;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: widget.PJ
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
            ),
            child: Text(
              "P",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.PJ ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.PJ = false;
              widget.parent.PJ = widget.PJ;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              backgroundColor: !widget.PJ
                  ? Colors.green
                  : (isDark ? AppColors.darkTag : AppColors.lightTag),
              minimumSize: const Size(50, 60),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
            ),
            child: Text(
              "J",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.PJ ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

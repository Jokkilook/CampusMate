// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:campusmate/AppColors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/profile/image_upload_screen.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:campusmate/screens/profile/widgets/schedule_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ProfileReviseScreen extends StatefulWidget {
  ProfileReviseScreen({super.key});
  late var image;
  late UserData modifiedData;

  @override
  State<ProfileReviseScreen> createState() => ProfileReviseScreenState();
}

class ProfileReviseScreenState extends State<ProfileReviseScreen> {
  final db = DataBase();
  ImagePicker imagePicker = ImagePicker();

  final String uid = FirebaseAuth.instance.currentUser?.uid.toString() ?? "";

  TextEditingController nameController = TextEditingController();

  TextEditingController introController = TextEditingController();

  late bool EI;

  late bool NS;

  late bool TF;

  late bool PJ;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    widget.image = null;

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
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                throw Error();
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
            child: BottomButton(
              text: "수정완료",
              isCompleted: true,
              isLoading: isLoading,
              onPressed: () async {
                isLoading = true;

                //로딩 오버레이 표시
                showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                widget.modifiedData.name = nameController.value.text;
                widget.modifiedData.introduce = introController.value.text;
                widget.modifiedData.mbti =
                    "${EI ? "E" : "I"}${NS ? "N" : "S"}${TF ? "T" : "F"}${PJ ? "P" : "J"}";
                context.read<UserDataProvider>().userData = widget.modifiedData;

                //이미지 변경시 이미지 변경 로직 실행
                if (widget.image != null) {
                  //프로필 이미지 파일 레퍼런스
                  var ref = FirebaseStorage.instance.ref().child(
                      "schools/${widget.modifiedData.school}/profileImages/${widget.modifiedData.uid}.png");

                  //파이어스토어에 이미지 파일 업로드
                  await ref.putFile(File(widget.image!.path));

                  //변경할 데이터에 변경된 url 저장
                  widget.modifiedData.imageUrl = await ref.getDownloadURL();

                  //채팅방 프로필 url 업데이트
                  await FirebaseFirestore.instance
                      .collection("schools/${widget.modifiedData.school}/chats")
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
                              (data["participantsInfo"] as Map<String, dynamic>)
                                  .map((key, value) {
                            return MapEntry(
                                key, (value as List<dynamic>).cast<String>());
                          });

                          userInfo[widget.modifiedData.uid!] = [
                            widget.modifiedData.name!,
                            widget.modifiedData.imageUrl!
                          ];

                          FirebaseFirestore.instance
                              .collection(
                                  "schools/${widget.modifiedData.school}/chats")
                              .doc(id)
                              .update({"participantsInfo": userInfo});
                        }
                      }
                    },
                  );

                  //채팅방 프로필 url 업데이트
                  await FirebaseFirestore.instance
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
                              (data["participantsInfo"] as Map<String, dynamic>)
                                  .map((key, value) {
                            return MapEntry(
                                key, (value as List<dynamic>).cast<String>());
                          });

                          userInfo[widget.modifiedData.uid!] = [
                            widget.modifiedData.name!,
                            widget.modifiedData.imageUrl!
                          ];

                          FirebaseFirestore.instance
                              .collection(
                                  "schools/${widget.modifiedData.school}/groupChats")
                              .doc(id)
                              .update({"participantsInfo": userInfo});
                        }
                      }
                    },
                  );
                }

                AuthService().setUserData(widget.modifiedData);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MainScreen(userData: widget.modifiedData, index: 3),
                    ),
                    (route) => false);
              },
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
              ImageViewer(
                originUrl: widget.modifiedData.imageUrl!,
                parent: parent,
                isLoading: isLoading,
              ),
              const SizedBox(height: 10),
              //이름입력
              IntrinsicWidth(
                child: TextField(
                  scrollPadding: const EdgeInsets.only(bottom: 100),
                  cursorColor:
                      isDark ? AppColors.darkTitle : AppColors.lightTitle,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                  maxLength: 20,
                  controller: nameController,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
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

//이미지 뷰어
//ignore: must_be_immutable
class ImageViewer extends StatefulWidget {
  ImageViewer(
      {super.key,
      required this.originUrl,
      required this.parent,
      this.isLoading = false});
  final ProfileReviseScreen parent;
  bool isLoading;
  String originUrl;
  XFile? image;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.originUrl = widget.parent.modifiedData.imageUrl!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageUploadScreen(
                      originUrl: widget.parent.modifiedData.imageUrl!,
                      parent: widget,
                    ))).then((value) => setState(() {
              widget.parent.image = widget.image;
            }));
      },
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 0.9,
        child: !widget.isLoading
            ? widget.image == null
                ? Image.network(
                    widget.originUrl,
                    fit: BoxFit.cover,
                  )
                // CachedNetworkImage(
                //     imageUrl: widget.originUrl,
                //     placeholder: (context, url) {
                //       return const Center(child: Icon(Icons.error_outline));
                //     },
                //     width: double.infinity,
                //     height: MediaQuery.of(context).size.width * 0.9,
                //     fit: BoxFit.cover,
                //   )
                : Image.file(
                    File(widget.image!.path),
                    fit: BoxFit.cover,
                  )
            : const Center(
                child: CircularProgressIndicator(),
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
                  child: Text(
                    tag,
                    style: TextStyle(
                        color: userTag.contains(tag)
                            ? const Color(0xff0B351E)
                            : (isDark
                                ? AppColors.darkTitle
                                : AppColors.lightTitle)),
                  ),
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
        const Column(
          children: [],
        ),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.EI = true;
              widget.parent.EI = widget.EI;
              setState(() {});
            },
            child: Text(
              "E",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.EI ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              "I",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.EI ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              "N",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.NS ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              "S",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.NS ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              "T",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.TF ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              "F",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.TF ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              "P",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.PJ ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              "J",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !widget.PJ ? const Color(0xFF0A351E) : Colors.black45,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
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
          ),
        ),
      ],
    );
  }
}

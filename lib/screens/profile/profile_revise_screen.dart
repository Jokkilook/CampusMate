import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/screens/main_screen.dart';
import 'package:campusmate/screens/profile/image_upload_screen.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:campusmate/widgets/schedule_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileReviseScreen extends StatefulWidget {
  const ProfileReviseScreen({super.key});

  @override
  State<ProfileReviseScreen> createState() => ProfileReviseScreenState();
}

class ProfileReviseScreenState extends State<ProfileReviseScreen> {
  final db = DataBase();

  final uid = FirebaseAuth.instance.currentUser?.uid;

  late UserData modifiedData;

  TextEditingController nameController = TextEditingController();

  TextEditingController introController = TextEditingController();

  late bool EI;

  late bool NS;

  late bool TF;

  late bool PJ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('프로필 수정'),
      ),
      // bottomNavigationBar: BottomButton(
      //   text: "수정완료",
      //   isCompleted: true,
      //   onPressed: () {
      //     modifiedData.name = nameController.value.text;
      //     modifiedData.introduce = introController.value.text;
      //     modifiedData.mbti =
      //         "${EI ? "E" : "I"}${NS ? "N" : "S"}${TF ? "T" : "F"}${PJ ? "P" : "J"}";
      //     db.addUser(modifiedData);
      //     Navigator.pushAndRemoveUntil(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => const MainScreen(index: 3),
      //         ),
      //         (route) => false);
      //   },
      // ),
      body: Stack(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(const GetOptions(source: Source.cache)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                throw Error();
              } else {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                modifiedData = UserData.fromJson(data);

                introController.value =
                    TextEditingValue(text: modifiedData.introduce!);
                nameController.value =
                    TextEditingValue(text: modifiedData.name!);

                return wholeProfile(modifiedData, context);
              }
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomButton(
              text: "수정완료",
              isCompleted: true,
              onPressed: () {
                modifiedData.name = nameController.value.text;
                modifiedData.introduce = introController.value.text;
                modifiedData.mbti =
                    "${EI ? "E" : "I"}${NS ? "N" : "S"}${TF ? "T" : "F"}${PJ ? "P" : "J"}";
                db.addUser(modifiedData);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(index: 3),
                    ),
                    (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView wholeProfile(UserData userData, BuildContext context) {
    modifiedData = userData;

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImageUploadScreen(userData: modifiedData)))
                      .then((value) => setState(() {}));
                },
                child: Image.network(
                  modifiedData.imageUrl.toString(),
                  height: MediaQuery.of(context).size.width * 0.9,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              //이름입력
              IntrinsicWidth(
                child: TextField(
                  scrollPadding: const EdgeInsets.only(bottom: 100),
                  cursorColor: Colors.black87,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87)),
                  ),
                  maxLength: 20,
                  controller: nameController,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '자기소개',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputTextField(
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
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '내 정보',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                              '나이  ${DateTime.now().year - int.parse(modifiedData.birthDate!.split(".")[0])}'),
                          Text('성별  ${modifiedData.gender! ? "남" : "여"}'),
                          Text('학과  ${modifiedData.dept}'),
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
                        color: Colors.grey[50],
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
                        color: Colors.grey[50],
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
                                scheduleData: modifiedData.schedule,
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

class TagShower extends StatefulWidget {
  const TagShower({super.key, required this.parent});
  final ProfileReviseScreenState parent;

  @override
  State<TagShower> createState() => _TagShowerState();
}

class _TagShowerState extends State<TagShower> {
  late List<String> userTag = widget.parent.modifiedData.tags!.cast<String>();
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
                style: const TextStyle(
                  color: Colors.black54,
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
                            : Colors.black54),
                  ),
                  style: OutlinedButton.styleFrom(
                      side: userTag.contains(tag)
                          ? BorderSide(width: 2, color: Colors.green[400]!)
                          : BorderSide(
                              width: 0, color: Colors.white.withOpacity(0)),
                      backgroundColor: userTag.contains(tag)
                          ? Colors.green[400]
                          : Colors.grey[200],
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
              backgroundColor:
                  widget.EI ? const Color(0xFF2BB56B) : const Color(0xFFE3DFE3),
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
                  ? const Color(0xFF2BB56B)
                  : const Color(0xFFE3DFE3),
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
              backgroundColor:
                  widget.NS ? const Color(0xFF2BB56B) : const Color(0xFFE3DFE3),
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
                  ? const Color(0xFF2BB56B)
                  : const Color(0xFFE3DFE3),
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
              backgroundColor:
                  widget.TF ? const Color(0xFF2BB56B) : const Color(0xFFE3DFE3),
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
                  ? const Color(0xFF2BB56B)
                  : const Color(0xFFE3DFE3),
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
              backgroundColor:
                  widget.PJ ? const Color(0xFF2BB56B) : const Color(0xFFE3DFE3),
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
                  ? const Color(0xFF2BB56B)
                  : const Color(0xFFE3DFE3),
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

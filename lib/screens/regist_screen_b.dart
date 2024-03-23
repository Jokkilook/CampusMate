import 'package:flutter/material.dart';

class RegistScreenB extends StatefulWidget {
  const RegistScreenB({super.key});

  @override
  State<RegistScreenB> createState() => _RegistScreenBState();
}

class _RegistScreenBState extends State<RegistScreenB> {
  late String inputEmail; //이메일 입력받을 변수
  bool isCompleted = false;
  bool isSended = false;

  @override
  void initState() {
    super.initState();
    inputEmail = "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 40,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              onPressed: (/* 로그인 화면으로 돌아가기 */) {},
              icon: const Icon(Icons.close),
            ),
          )
        ],
        title: const Text(
          "회원가입",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C5C5C)),
        ),
        shadowColor: Colors.black,
        elevation: 2,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 60,
                child: Container(
                  height: 10,
                  color: const Color(0xff2CB66B),
                ),
              ),
              Expanded(
                flex: 30,
                child: Container(
                  height: 10,
                  color: const Color(0xffE4E4E4),
                ),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("   학교 이메일 인증",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black45)),
                        const SizedBox(height: 5),
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              onChanged: (value) {
                                inputEmail = value;
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black45,
                                        width: 1.5,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black45,
                                        width: 1.5,
                                      )),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  hintText: "학교 이메일을 입력하세요.",
                                  labelStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                          ),
                        ),
                        const Text(
                          "   메일 하나당 하나의 계정만 가입 가능합니다.",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: inputEmail.isNotEmpty
                              ? () {
                                  /* 인증번호 발송 버튼을 누르면 메일로 발송하는 코드 */
                                  if (isSended) return;
                                  isSended = !isSended;
                                  setState(() {});
                                }
                              : null,
                          child: Text(
                            isSended ? "재발송" : "인증번호 발송 ",
                            style: TextStyle(
                                color: inputEmail.isNotEmpty
                                    ? const Color(0xFF0A351E)
                                    : Colors.black45,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2BB56B),
                            minimumSize: const Size(10000, 60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        Visibility(
                          visible: isSended,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "   아직 인증번호가 도착하지 않았나요?",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 50,
                                child: TextField(
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Colors.black45,
                                            width: 1.5,
                                          )),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Colors.black45,
                                            width: 1.5,
                                          )),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      hintText: "인증번호를 입력하세요.",
                                      labelStyle: const TextStyle(fontSize: 14),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10)),
                                ),
                              ),
                              const Text("   03:00",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: isSended
                                    ? () {
                                        /* 인증번호 확인 */ isCompleted =
                                            !isCompleted;
                                        setState(() {});
                                      }
                                    : null,
                                child: Text(
                                  "확인",
                                  style: TextStyle(
                                      color: isSended
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2BB56B),
                                  minimumSize: const Size(10000, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                  ElevatedButton(
                    onPressed: isCompleted
                        ? () {/* 회원가입 데이터에 이메일 저장 후 다음 거로 */}
                        : null,
                    child: Text(
                      "다음",
                      style: TextStyle(
                          color: isCompleted
                              ? const Color(0xFF0A351E)
                              : Colors.black45,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BB56B),
                      minimumSize: const Size(10000, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

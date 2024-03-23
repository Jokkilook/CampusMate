import 'package:flutter/material.dart';

class RegistScreenC extends StatefulWidget {
  const RegistScreenC({super.key});

  @override
  State<RegistScreenC> createState() => _RegistScreenCState();
}

class _RegistScreenCState extends State<RegistScreenC> {
  late String email;
  late String inputPassword;
  late String checkPassword; //비밀번호 변수
  late String inputNick; //닉네임 변수

  bool isCompleted = false;
  bool isSended = false;
  bool isCorrect = false;
  bool checkStart = false;

  @override
  void initState() {
    super.initState();
    //유저 데이터에 저장된 이메일 가져오기
    email = "abc@email.ac.kr";
    inputPassword = "";
    checkPassword = "";
    inputNick = "";
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
                flex: 100,
                child: Container(
                  height: 10,
                  color: const Color(0xff2CB66B),
                ),
              ),
              Expanded(
                flex: 00,
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
                        const Text("   아이디",
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
                              readOnly: true,
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
                                  hintText: email,
                                  labelStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("   비밀번호",
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
                                inputPassword = value;
                                setState(() {});
                              },
                              obscureText: true,
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
                                  hintText: "사용할 비밀번호를 입력하세요.",
                                  labelStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("   비밀번호 확인",
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
                                checkStart = true;
                                checkPassword = value;

                                inputPassword.isNotEmpty &&
                                        value == inputPassword
                                    ? isCorrect = !isCorrect
                                    : isCorrect = false;
                                setState(() {});
                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color:
                                            checkPassword.isEmpty || isCorrect
                                                ? Colors.black45
                                                : Colors.red,
                                        width: 1.5,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color:
                                            checkPassword.isEmpty || isCorrect
                                                ? Colors.black45
                                                : Colors.red,
                                        width: 1.5,
                                      )),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  hintText: "사용할 비밀번호를 다시 한번 입력하세요.",
                                  labelStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("   닉네임",
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
                                inputNick = value;
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
                                  hintText: "사용할 닉네임을 입력하세요.",
                                  labelStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(40),
        child: ElevatedButton(
          onPressed:
              inputPassword.isNotEmpty && isCorrect && inputNick.isNotEmpty
                  ? () {/* 회원가입 데이터에 나머지 저장 후 데이터베이스에 삽입 */}
                  : null,
          child: Text(
            "다음",
            style: TextStyle(
                color: inputPassword.isNotEmpty &&
                        isCorrect &&
                        inputNick.isNotEmpty
                    ? const Color(0xFF0A351E)
                    : Colors.black45,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2BB56B),
            minimumSize: const Size(10000, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}

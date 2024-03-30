import 'dart:async';
import 'dart:math';

class OTP {
  var timer;
  var code;

  String createOTP(int digit) {
    final input = pow(10, digit) - 1;
    code = Random().nextInt(input.toInt());

    var _stringCode = code.toString();
    if (_stringCode.length != 6) {
      var count = 6 - _stringCode.length;
      for (int i = 0; i < count; i++) {
        _stringCode = "0" + _stringCode;
      }
    }

    return _stringCode;
  }

  void timerActivate() {
    timer = Timer(const Duration(minutes: 3), () {
      code = "";
    });
  }

  bool verifyOTP(String otp) {
    if (code.toString() == otp) {
      return true;
    } else {
      return false;
    }
  }

  bool isValid() {
    if (code == "") {
      return false;
    } else {
      return true;
    }
  }
}

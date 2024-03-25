import 'dart:async';
import 'dart:math';

class OTP {
  var timer;
  var _code;

  String createOTP(int digit) {
    final input = pow(10, digit) - 1;
    _code = Random().nextInt(input.toInt());

    var _stringCode = _code.toString();
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
      _code = "";
    });
  }

  bool verifyOTP(String otp) {
    if (_code.toString() == otp) {
      return true;
    } else {
      return false;
    }
  }

  bool isValid() {
    if (_code == "") {
      return false;
    } else {
      return true;
    }
  }
}

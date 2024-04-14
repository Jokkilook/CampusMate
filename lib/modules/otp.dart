import 'dart:async';
import 'dart:math';

class OTP {
  Timer? _timer;
  String? _code;

  String createOTP(int digit) {
    final input = pow(10, digit) - 1;
    String _strCode = "";
    _code = (Random().nextInt(input.toInt())).toString();

    if (_code!.length != 6) {
      int count = 6 - _code!.length;
      for (int i = 0; i < count; i++) {
        _strCode = "0" + _code!;
      }
    }

    return _strCode;
  }

  void timerActivate() {
    _timer = Timer(const Duration(minutes: 3), () {
      _code = "";
    });
  }

  bool verifyOTP(String otp) {
    if (_code == otp) {
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

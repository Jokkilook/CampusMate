import 'package:email_otp/email_otp.dart';

class EmailAuthA {
  var auth = EmailOTP();

  void sendEmail(String email) async {
    auth.setConfig(
        appEmail: "swat2054@naver.com",
        appName: "CAMPUS MATE",
        userEmail: email,
        otpLength: 6,
        otpType: OTPType.digitsOnly);
    await auth.sendOTP();
  }

  void verifyCode(var code) async {
    await auth.verifyOTP(otp: code);
  }
}

class PhoneNoConstants {
  static const String allowPhoneComm = 'Please allow use of your phone number';
  static const String createAcc = 'Create account';
  static const String enterNo = 'Enter your phone number';
  static const String createAccDesc =
      'Use your phone number to create an account';
  static const String userExists =
      'User with that phone number exists. Please sign in';
  static const String verifyPhone = 'Verify phone number';
  static String verifyDesc(String phoneNo) {
    return 'We have sent a 6 digit code to $phoneNo. Enter the code below to proceed';
  }

  static const String sendCodeAgain = ' Send the code again ';
  static const String changeNo = 'Change number';
  static const String codeSent = 'Code was resent successfully to';
  static const String resendCancel = 'Resend cancelled';
  static const String viaText = 'via Text Message';
  static const String viaWhatsApp = 'via WhatsApp';
  static const String noAccount =
      'That phone number does not exist, please enter the number you registered with';
}

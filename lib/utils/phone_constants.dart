class PhoneNoConstants {
  static final String allowPhoneComm = 'Please allow use of your phone number';
  static final String createAcc = 'Create account';
  static final String enterNo = 'Enter your phone number';
  static final String createAccDesc =
      'Use your phone number to create an account';
  static final String userExists =
      'User with that phone number exists. Please sign in';
  static final String verifyPhone = 'Verify phone number';
  static String verifyDesc(String phoneNo) {
    return 'We have sent a 6 digit code to $phoneNo. Enter the code below to proceed';
  }

  static final String sendCodeAgain = ' Send the code again ';
  static final String changeNo = 'Change number';
  static final String codeSent = 'Code was resent successfully to';
  static final String resendCancel = 'Resend cancelled';
  static final String viaText = 'via Text Message';
  static final String viaWhatsApp = 'via WhatsApp';
  static final String noAccount =
      'That phone number does not exist, please enter the number you registered with';
}

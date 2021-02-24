import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/utils/phone_constants.dart';

void main() {
//Us phone test

  String testPhone = '+2547123456789';
  test('PhoneNoConstants', () {
    expect(PhoneNoConstants.allowPhoneComm,
        'Please allow use of your phone number');
    expect(PhoneNoConstants.createAcc, 'Create account');
    expect(PhoneNoConstants.enterNo, 'Enter your phone number');
    expect(PhoneNoConstants.createAccDesc,
        'Use your phone number to create an account');
    expect(PhoneNoConstants.userExists,
        'User with that phone number exists. Please sign in');
    expect(PhoneNoConstants.verifyPhone, 'Verify phone number');
    expect(PhoneNoConstants.verifyDesc(testPhone),
        'We have sent a 6 digit code to $testPhone. Enter the code below to proceed');
    expect(PhoneNoConstants.sendCodeAgain, ' Send the code again ');
    expect(PhoneNoConstants.changeNo, 'Change number');
    expect(PhoneNoConstants.codeSent, 'Code was resent successfully to');
    expect(PhoneNoConstants.resendCancel, 'Resend cancelled');
    expect(PhoneNoConstants.viaText, 'via Text Message');
    expect(PhoneNoConstants.viaWhatsApp, 'via WhatsApp');
    expect(PhoneNoConstants.noAccount,
        'That phone number does not exist, please enter the number you registered with');
  });
}

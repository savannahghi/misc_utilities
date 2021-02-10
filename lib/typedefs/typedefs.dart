import 'package:flutter/material.dart';

///GenerateRetryOtpFunc is the method that will called to generate and send an otp
/// The signature should the one defined in sil_graphql_utils
typedef GenerateRetryOtpFunc = Future<String> Function({
  @required String phoneNumber,
  @required int step,
  @required dynamic client,
});

/// SendOtpFunc is the function that will be called to send an otp. Should match the one defined
/// in sil_graphl_utils
typedef SendOtpFunc = Future<String> Function(
    {@required BuildContext context,
    @required String phoneNumber,
    @required String logTitle,
    @required dynamic client,
    String logDescription,
    String email,
    bool sendToEmailOnly});

typedef SendOTP = Future<String> Function(
    {BuildContext context,
    String phoneNumber,
    String logTitle,
    String logDescription,
    String email,
    bool sendToEmailOnly});

/// [ShowAlertSnackBarFunc] a function that will be called to show a show for success or fail
typedef ShowAlertSnackBarFunc = Function(BuildContext ctx,
    [String msg, Color color]);

/// [VerifySuccessCallback] signature of the function called on the successful otp verification
typedef VerifySuccessCallback = Future<bool> Function(
    {String email, String phone, String otp});

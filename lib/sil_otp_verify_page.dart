import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sil_misc/sil_misc.dart';
import 'package:sil_misc/typedefs/typedefs.dart';
import 'package:sil_themes/colors.dart';
import 'package:sil_themes/constants.dart';
import 'package:sil_themes/spaces.dart';
import 'package:sil_themes/text_themes.dart';

// The maximum number of retries when an otd fails to arrive
const int maxRetries = 3;

/// The model the will used to monitor the state ot the page.
/// Why use a model instead of using a state management libary
/// 1. Because i can (@dexter)
/// 2. This library should be light-weight as possible
/// 3. Easy to model and think through
class VerifyModel {
  int retryCount = 0;
  bool invalidCode = false;
  bool resending = false;
  bool showResend = false;
  bool isProcessing = false;
  dynamic client;
  String phoneNumber;
  String email;
  String otp;

  VerifyModel(
      {this.retryCount,
      this.invalidCode,
      this.resending,
      this.showResend,
      this.isProcessing,
      this.client,
      this.phoneNumber,
      this.email,
      this.otp});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'retryCount': retryCount,
        'invalidCode': invalidCode,
        'resending': resending,
        'showResend': showResend,
        'isProcessing': isProcessing,
        'client': client,
        'phoneNumber': phoneNumber,
        'email': email,
        'otp': this.otp,
      };
}

/// [StateManager] manages the state of [SILVerifyOTPPage]
/// returns a singleton whose job is to provide intial state and mutate that state on call
/// the [SILVerifyOTPPage] should change the UI to reflect changes in the state
class StateManager {
  static final StateManager _singleton = StateManager._internal();

  factory StateManager() {
    return _singleton;
  }

  StateManager._internal();

  final BehaviorSubject<VerifyModel> _state = BehaviorSubject<VerifyModel>();

  ValueStream<VerifyModel> get stream$ => _state.stream;
  VerifyModel get current => _state.value;

  void intial({String phoneNumber, String email, String otp, dynamic client}) {
    _state.add(VerifyModel(
      phoneNumber: phoneNumber,
      email: email,
      client: client,
      otp: otp,
      retryCount: 0,
      invalidCode: false,
      resending: false,
      isProcessing: false,
      showResend: false,
    ));
  }

  void update(
      {bool invalidCode,
      bool resending,
      bool showResend,
      String otp,
      bool isProcessing}) {
    final VerifyModel current = this.current;
    this._state.add(VerifyModel(
          retryCount:
              resending == true ? current.retryCount += 1 : current.retryCount,
          invalidCode: invalidCode ?? current.invalidCode,
          resending: resending ?? current.resending,
          showResend: showResend ?? current.showResend,
          isProcessing: isProcessing ?? current.isProcessing,
          client: current.client,
          phoneNumber: current.phoneNumber,
          email: current.email,
          otp: otp ?? current.otp,
        ));
  }
}

/// SILVerifyOTPPage a generics page that will be used for verification of otps.
/// This should the the go to page to when defining an otp verification use case.
/// The page is designed to serve a number of edge cases;
/// 1. time when otp is not entered and show resend option
/// 2. call methods that do the actually generating and sending of otp
/// 3. handle errors internally and present the user a feasible way out
///
/// example:
///
///
/// ```dart
/// SILVerifyOTPPage(
///  otp: otp,
///  phone: userProfile.phoneNumber ?? this.phoneNumber,
///  client: SILAppWrapperBase.of(context).graphQLClient,
///  email: userProfile.email ?? 'fakeemail@provider.com',
///  vType: vType,
///  loader: SILLoader(),
///  successCallback: successCallback,
///  showAlertSnackBarFunc: BeWellUtils.showAlertSnackBar,
///  sendOtpFunc: SILGraphQlUtils.sendOtp,
///  afterSuccessCallback: this.afterSuccessCallback ??
///      () async {
///          final AppState state = StoreProvider.state<AppState>(context);
///           Map<String, dynamic> routeContext =
///           BeWellUtils.onboardingPath(state);
///           await Navigator.pushReplacementNamed(context, routeContext['route'], arguments: routeContext['args']);
/// },
/// generateOtpFunc: SILGraphQlUtils.generateRetryOtp)
///
/// ````

class SILVerifyOTPPage extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  /// [otp] the otp to verify against with
  final String otp;

  /// [phone] the phone number of the user that will used when resending the otp
  final String phone;

  /// [email] the email of the user that will used when resending the otp
  final String email;

  /// [vType] the type of verification.
  final VerificationType vType;

  /// [client] an instance of [SILGraphqlClient]
  final dynamic client;

  /// [successCallback] called when otp has been verified successfully
  final VerifySuccessCallback successCallback;

  /// [afterSuccessCallback] subsequent calls after successful otp verification
  final Function afterSuccessCallback;

  /// [onFailBackCallback] a navigation callback that will be called when the user reaches the maximum
  /// retry count
  final Function onFailBackCallback;

  /// [GenerateRetryOtpFunc] will be called to generate a new otp
  final GenerateRetryOtpFunc generateOtpFunc;

  final SendOtpFunc sendOtpFunc;

  final ShowAlertSnackBarFunc showAlertSnackBarFunc;

  final int retryTimeout;

  final List<Function> callbacks = <Function>[];

  final Widget loader;

  final StateManager manager = StateManager();

  SILVerifyOTPPage(
      {Key key,
      @required this.otp,
      @required this.phone,
      @required this.email,
      @required this.vType,
      @required this.client,
      this.successCallback,
      this.afterSuccessCallback,
      this.onFailBackCallback,
      this.generateOtpFunc,
      this.sendOtpFunc,
      this.showAlertSnackBarFunc,
      this.loader,
      this.retryTimeout}) {
    this
        .manager
        .intial(phoneNumber: phone, email: email, otp: otp, client: client);
  }

  Function resendOtp(BuildContext context, String phone, dynamic client) {
    return (int step) async {
      this.manager.update(resending: true);
      dynamic otpCode = await this
          .generateOtpFunc(client: client, phoneNumber: phone, step: step);
      if (otpCode != 'Error') {
        if (this.showAlertSnackBarFunc != null) {
          this.showAlertSnackBarFunc(
              context,
              'A six digit code has been sent to ${step == 1 ? " your Whatsapp" : this.phone}',
              Colors.black);
        }
        this.manager.update(showResend: false, otp: otpCode, resending: false);
      } else {
        if (this.showAlertSnackBarFunc != null) {
          this.showAlertSnackBarFunc(context);
        }
      }
    };
  }

  Function resendOtpEmail(BuildContext context, String email, dynamic client) {
    return (int x) async {
      this.manager.update(resending: true);
      dynamic otpCode = await this.sendOtpFunc(
          context: context,
          client: client,
          email: this.email,
          sendToEmailOnly: true,
          phoneNumber: null,
          logTitle: 'signup: send OTP to email',
          logDescription: 'send a verification to ');
      if (otpCode != 'Error') {
        if (this.showAlertSnackBarFunc != null) {
          this.showAlertSnackBarFunc(
              context,
              'A verification code has been sent to ${this.email}',
              Colors.black);
        }
        this.manager.update(showResend: false, otp: otpCode, resending: false);
      } else {
        if (this.showAlertSnackBarFunc != null) {
          this.showAlertSnackBarFunc(context);
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhone = this.vType == VerificationType.phone;

    return StreamBuilder<VerifyModel>(
      stream: this.manager.stream$,
      builder: (BuildContext context, AsyncSnapshot<VerifyModel> snap) {
        final VerifyModel data = snap.data;

        print(data.toJson());

        // remove previously set callbacks
        callbacks.removeRange(0, callbacks.length);

        if (isPhone) {
          callbacks.add(this.resendOtp(context, data.phoneNumber, data.client));
        }

        return Column(
          children: <Widget>[
            Text('Enter the code below'),
            smallVerticalSizedBox,
            smallVerticalSizedBox,
            PinCodeTextField(
              controller: textEditingController,
              autofocus: true,
              hideCharacter: true,
              highlight: true,
              highlightColor: Colors.blue,
              defaultBorderColor: Theme.of(context).primaryColor,
              hasTextBorderColor: Theme.of(context).accentColor,
              maxLength: 6,
              maskCharacter: '⚫',
              pinBoxWidth: 34,
              pinBoxHeight: 38,
              wrapAlignment: WrapAlignment.spaceAround,
              pinBoxDecoration: SILMisc.customRoundedPinBoxDecoration,
              pinTextStyle: TextStyle(fontSize: 10.0),
              pinTextAnimatedSwitcherTransition:
                  ProvidedPinBoxTextAnimation.scalingTransition,
              pinBoxColor: Theme.of(context).backgroundColor,
              pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
              //highlightAnimation: true,
              highlightAnimationBeginColor: Colors.black,
              highlightAnimationEndColor: Colors.white12,
              keyboardType: TextInputType.number,
              onDone: (dynamic value) async {
                if (value == data.otp) {
                  this.manager.update(invalidCode: false, resending: false);
                  if (this.successCallback != null) {
                    this.manager.update(isProcessing: true);
                    if (await this.successCallback(
                        otp: otp, email: this.email, phone: this.phone)) {
                      if (this.afterSuccessCallback != null) {
                        this.afterSuccessCallback();
                        this.manager.update(isProcessing: false);
                      }
                    }
                  }
                  if (this.showAlertSnackBarFunc != null) {
                    this.showAlertSnackBarFunc(context);
                  }
                  return;
                }
                textEditingController.clear();
                this.manager.update(invalidCode: true);
                await HapticFeedback.mediumImpact();
              },
            ),
            smallVerticalSizedBox,
            if (data.invalidCode)
              Text(
                'Wrong PIN. Please try again',
                style: TextThemes.boldSize16Text(Colors.red),
              ),
            if (data.resending) ...<Widget>[
              mediumVerticalSizedBox,
              this.loader,
              smallVerticalSizedBox,
            ],
            if (data.isProcessing) ...<Widget>[
              mediumVerticalSizedBox,
              this.loader,
              smallVerticalSizedBox,
            ],
            mediumVerticalSizedBox,
            ...<Widget>[
              if (!data.showResend && (data.retryCount < maxRetries))
                CountdownFormatted(
                    duration: Duration(
                        seconds: this.retryTimeout ?? otpResendTimeoutDuration),
                    onFinish: () {
                      print('call on counter finished');
                      this.manager.update(showResend: true);
                    },
                    builder: (BuildContext ctx, String remaining) {
                      return Text(
                        remaining,
                        style: TextStyle(fontSize: 30),
                      );
                    }),
              if (data.showResend && (data.retryCount < maxRetries))
                if (isPhone)
                  data.retryCount <= maxRetries
                      ? PhoneCodeResend(callbacks: this.callbacks)
                      : Container(),
              if (data.showResend && (data.retryCount < maxRetries))
                if (!isPhone)
                  data.retryCount <= maxRetries
                      ? ResendBtn(
                          txt: 'Resend Code',
                          callback: this
                              .resendOtpEmail(context, data.email, data.client),
                        )
                      : Container(),
            ],
            smallVerticalSizedBox,
            smallVerticalSizedBox,
            if (data.retryCount >= maxRetries)
              Column(
                children: <Widget>[
                  Text(
                    'Maximum attempts reached. If the code fails to arrive, please go back to try again',
                    textAlign: TextAlign.justify,
                  ),
                  smallVerticalSizedBox,
                  RawMaterialButton(
                    onPressed: () {
                      this.onFailBackCallback != null
                          ? this.onFailBackCallback()
                          : Navigator.pop(context);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    fillColor: green,
                    child: Text(
                      'GO BACK',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  smallVerticalSizedBox,
                ],
              ),
            smallVerticalSizedBox,
            if (<int>[
              1,
              2,
            ].contains(data.retryCount))
              Text('Remaining ${maxRetries - data.retryCount} attempts'),
          ],
        );
      },
    );
  }
}

class PhoneCodeResend extends StatefulWidget {
  final List<Function> callbacks;

  const PhoneCodeResend({
    @required this.callbacks,
  });
  @override
  PhoneCodeResendState createState() => PhoneCodeResendState();
}

class PhoneCodeResendState extends State<PhoneCodeResend> {
  bool showBtns = false;

  void showButtons(int x) {
    setState(() {
      showBtns = !showBtns;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).accentColor;
    return Wrap(
      runSpacing: 20,
      spacing: 10,
      children: <Widget>[
        if (!showBtns)
          ResendBtn(
            txt: 'Resend Code',
            callback: showButtons,
          ),
        if (showBtns) ...<Widget>[
          ResendBtn(
              txt: 'Resend via Whatsapp',
              callback: widget.callbacks[0],
              fill: color),
          ResendBtn(
              txt: 'Resend via text',
              callback: widget.callbacks[0],
              fill: color),
        ],
      ],
    );
  }
}

class ResendBtn extends StatelessWidget {
  final Color fill;
  final Function callback;
  final String txt;

  const ResendBtn({
    Key key,
    this.fill = Colors.white,
    @required this.callback,
    @required this.txt,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RawMaterialButton(
          onPressed: () {
            callback(txt == 'Resend via Whatsapp' ? 1 : 2);
          },
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6))),
          fillColor: fill,
          child: Text(
            txt,
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: fill == Colors.white ? Colors.grey : Colors.white),
          ),
        ),
        smallVerticalSizedBox,
      ],
    );
  }
}

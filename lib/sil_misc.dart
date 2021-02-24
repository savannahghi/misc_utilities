library sil_misc;

import 'dart:async';
import 'dart:io';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sil_misc/utils/widget_keys.dart';

import 'package:sil_themes/constants.dart';

class PageCopy {
  // ignore: close_sinks
  static BehaviorSubject<String> title = BehaviorSubject<String>.seeded('');
  // ignore: close_sinks
  static BehaviorSubject<String> description =
      BehaviorSubject<String>.seeded('');
}

class SILException implements Exception {
  final dynamic message;
  final dynamic cause;

  SILException({@required this.cause, @required this.message});
}

class SILMisc {
  static LinearGradient backgroundGradient(
          {@required dynamic primaryLinearGradientColor,
          @required dynamic primaryColor}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: <double>[0, 0.7],
        colors: <Color>[
          Color(primaryLinearGradientColor),
          Color(primaryColor),
        ],
      );

  static String convertDateToString({
    @required DateTime date,
    @required String format,
  }) {
    return DateFormat(format).format(date);
  }

  /// [extractNamesInitials] extracts name initials from a name
  ///
  /// Usage:
  ///
  /// if you pass in a name like 'Abiud Orina', it returns 'AO'
  static String extractNamesInitials({@required String name}) {
    final List<String> parts = name.split(' ');
    if (parts.length >= 2) {
      String initials = ' ';
      for (int i = 0; i <= 1; i++) {
        final String part = parts[i];
        initials = initials + part[0].toUpperCase();
      }
      return initials.trim().substring(0, 2);
    }
    return parts.first.split('')[0].toUpperCase();
  }

  /// converts a valid date time string to a [DateTime] object
  static DateTime convertStringToDate(
      {@required String dateTimeString, @required String format}) {
    return DateFormat(format).parse(dateTimeString);
  }

  /// checks if a number is either a [Kenyan] or [American] phone number
  static bool validatePhoneNumber(String phone) {
    if (kenyanPhoneRegExp.hasMatch(phone)) {
      return true;
    } else if (americanPhoneRegExp.hasMatch(phone)) {
      return true;
    }
    return false;
  }

  static PinBoxDecoration customRoundedPinBoxDecoration = (
    Color borderColor,
    Color pinBoxColor, {
    double borderWidth = 1.0,
    double radius,
  }) {
    return BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        color: pinBoxColor,
        borderRadius: BorderRadius.all(Radius.circular(8)));
  };

  static String formatPhoneNumber(
      {@required String countryCode, @required String phoneNumber}) {
    if (!countryCode.startsWith('+')) {
      countryCode = '+$countryCode';
    }
    if (countryCode == '+1') {
      return '$countryCode$phoneNumber';
    }
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }
    return '$countryCode$phoneNumber';
  }

  /// gets the validity period of a cover
  ///
  /// pass in a valid validTo string and it returns
  /// a validity period in human readable form
  static String getCoverValidityPeriod(String validTo) {
    Duration validityDuration =
        DateTime.parse(validTo).difference(DateTime.now());
    String remainingMonths = (validityDuration.inDays / 30).floor().toString();
    String remainingDays = (validityDuration.inDays % 30).floor().toString();
    return 'Valid for the next ' +
        remainingMonths +
        ' months and ' +
        remainingDays +
        ' days';
  }

  /// formats the validity date into a human readable format
  static String getValidityDate(String validTo) {
    return 'Till ' + DateFormat('MMM dd, yyyy').format(DateTime.parse(validTo));
  }

  /// validates an email against a regex
  static bool validateEmail(String email) {
    return emailValidator.hasMatch(email);
  }

  /// formats the amount passed in, into a human readable amount
  static String formatCurrency(dynamic amount) {
    if (amount is String || amount is int || amount is double) {
      return NumberFormat('#,###,###').format(amount);
    }
    return '0';
  }

  /// [titleCase] returns a title cased sentence
  static String titleCase(String sentence) {
    if (sentence is! String || sentence.isEmpty) {
      return '';
    }

    return sentence
        .toLowerCase()
        .split(' ')
        .map((String e) => e.trim())
        .map((String word) => toBeginningOfSentenceCase(word))
        .join(' ');
  }

  /// returns the list of auth types by removing the last comma
  static String parseAuthTypes(List<dynamic> authenticationTypes) {
    String auth = '';

    for (int i = 0; i < authenticationTypes.length; i++) {
      final String _auth = authenticationTypes[i];
      //. check if its last or only item so as not to
      // append a comma
      if ((i + 1) == authenticationTypes.length) {
        auth = auth + '$_auth ';
      } else {
        auth = auth + '$_auth & ';
      }
    }

    return auth;
  }

  static void showErr(BuildContext ctx,
      [String msg, Color color = Colors.red]) {
    Scaffold.of(ctx).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(
        msg ?? UserFeedBackTexts.getErrorMessage(),
        style: Theme.of(ctx).textTheme.bodyText2.copyWith(color: Colors.white),
      ),
      duration: Duration(seconds: kShortsnackBarDuration),
    ));
    return;
  }

  /// gets the current time of day and determines which type of greetings to show
  /// to the user
  static String getGreetingMessage(String firstName, {int currentHour}) {
    int hour = currentHour ?? DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, ${firstName ?? 'unknown'}';
    }
    if (hour < 17) {
      return 'Good Afternoon, ${firstName ?? 'unknown'}';
    }
    return 'Good Evening, ${firstName ?? 'unknown'}';
  }

  // removes underscores from a sentence
  static String removeUnderscores(String sentence) {
    return titleCase(sentence.toString().replaceAll('_', ' ').toLowerCase());
  }

  static void bottomSheet(
      {@required BuildContext context,
      @required String message,
      @required Function action,
      @required Color backgroundColor,
      @required Color textColor,
      @required Color primaryColor}) {
    showModalBottomSheet<List<dynamic>>(
        context: context,
        enableDrag: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (BuildContext bc) {
          return Container(
            key: containerKey,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            height: action != null ? 314.0 : 250.0,
            child: Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Column(
                key: columnKey,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Color(0xFF50C878),
                    child: Icon(
                      Icons.check,
                      size: 36.0,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: textColor,
                          ),
                    ),
                  ),
                  if (action != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      width: double.infinity,
                      height: 56,
                      child: MaterialButton(
                        key: okButtonKey,
                        elevation: 0,
                        child: Text('OK',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            )),
                        color: primaryColor,
                        textColor: Theme.of(context).backgroundColor,
                        onPressed: () {
                          Navigator.pop(context);
                          action();
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }

  static void verifyOTPErrorBottomSheet(
      {@required BuildContext context,
      @required String message,
      @required Function actionEnterCode,
      @required Color textColor,
      @required Color primaryColor}) {
    showModalBottomSheet<List<dynamic>>(
        context: context,
        enableDrag: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (BuildContext bc) {
          return Container(
            key: containerKey,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            height: actionEnterCode != null ? 314.0 : 250.0,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                key: columnKey,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(40.0),
                      ),
                    ),
                    child: Icon(
                      Icons.error,
                      size: 58,
                      color: Colors.white,
                    ),
                  ),
                  Center(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Theme.of(context).textSelectionColor,
                          ),
                    ),
                  ),
                  if (actionEnterCode != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        width: double.infinity,
                        child: MaterialButton(
                          key: reenterCodeButtonKey,
                          height: 56,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            Navigator.pop(context);
                            actionEnterCode();
                          },
                          child: Text(
                            'RE-ENTER CODE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        });
  }

  static SnackBar snackbar(
      {@required dynamic content,
      int durationSeconds = 10,
      String label,
      Function callback}) {
    // ignore: always_specify_types
    if (![String, Widget].contains(content.runtimeType)) {
      FlutterError.dumpErrorToConsole(FlutterErrorDetails(
          exception: 'Content must be either of type String or Widget!'));
    }

    return SnackBar(
      content: content.runtimeType == String ? Text(content) : content,
      duration: Duration(seconds: durationSeconds),
      action: callback != null
          ? SnackBarAction(label: label, onPressed: callback)
          : null,
    );
  }

  static Future<String> get localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dirPath = '${directory.path}/Pictures/sil-mobile';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/{$DateTime.now()}.png';
    return filePath;
  }

  static Map<String, dynamic> uploadMutationVariable(
      Map<String, dynamic> payload) {
    Map<String, dynamic> inputVariables = <String, dynamic>{};
    inputVariables['title'] = payload['title'];
    inputVariables['contentType'] = payload['contentType'];
    inputVariables['language'] = 'en';
    inputVariables['filename'] = payload['filename'];
    inputVariables['base64data'] = payload['base64data'];
    return <String, dynamic>{'input': inputVariables};
  }

  static String uploadMutationQuery = r'''
  mutation Upload($input: UploadInput!) {
  upload(input: $input) {
    id
    url
    size
    hash
    creation
    title
    contentType
    language
    base64data
  }
}
''';
}

/// [RefreshTokenManger] is responsible for when to fetch a brand new
/// id-token just before the expiry of the current one.
/// The [updateExpireTime] is triggered in two scenarios;
///
/// 1 . Just after successful login. Ideally this will always be the first call
/// 2 . When the app boots-up.  The scenario here is app is removed from stack by
///     user or during development. The app will retrieve the appropriate expiry time,
///     do some time math and determine whether its the right time to call for a
///     a fresh id-token
class RefreshTokenManger {
  static final RefreshTokenManger _singleton = RefreshTokenManger._internal();

  factory RefreshTokenManger() {
    return _singleton;
  }

  RefreshTokenManger._internal();

  //ignore: close_sinks
  BehaviorSubject<dynamic> listen = BehaviorSubject<dynamic>();

  final BehaviorSubject<String> _expireTime = BehaviorSubject<String>();

  RefreshTokenManger updateExpireTime(String expire) {
    _expireTime.add(expire);
    this.listen.add(null);
    return this;
  }

  bool _ifAfterCurrentTime(DateTime parsed) {
    final Duration _afterCurrentTime = parsed.difference(DateTime.now());
    if (_afterCurrentTime.inSeconds <= 0) {
      return true;
    }
    return false;
  }

  bool _ifApproachingCurrentTime(DateTime parsed) {
    final Duration _closeToCurrentTime = DateTime.now().difference(parsed);
    if (_closeToCurrentTime.inSeconds >= (10 * 60)) {
      return true;
    }
    return false;
  }

  /// [checkExpireValidity] for checking whether the expire time is valid.
  /// Recommended to be called just before the app draws its first widget in main.dart
  bool checkExpireValidity(String expireAt) {
    try {
      if (expireAt == null || expireAt.isEmpty) {
        return false;
      }

      final DateTime _parsed = DateTime.parse(expireAt);
      if (this._ifAfterCurrentTime(_parsed) == true ||
          this._ifApproachingCurrentTime(_parsed) == true) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// [reset] is responsible for resetting the timeout clock and notifying the listener [listen]
  /// when fetch a new token
  void reset() {
    print(
        '===> Expiry timer reset has been set for time ${this._expireTime.value}');

    try {
      if (this._expireTime.value != null) {
        // this is the time from login or retrieved from state store as string
        final DateTime _parsed = DateTime.parse(this._expireTime.value);
        // determine if the parsed time is after the current time
        if (this._ifAfterCurrentTime(_parsed)) {
          this.listen.add(true);
          return;
        }

        // determine if the parse time is 7 minutes to the current time
        if (this._ifApproachingCurrentTime(_parsed)) {
          this.listen.add(true);
          return;
        }

        // refresh 15 minutes before token expires
        final DateTime _threshold = _parsed.subtract(Duration(minutes: 15));
        final Duration _duration = _threshold.difference(DateTime.now());
        if (_duration.inSeconds <= 0) {
          final Duration _duration = _parsed.difference(DateTime.now());
          Timer(Duration(seconds: _duration.inSeconds), () {
            this.listen.add(true);
          });
        } else {
          Timer(Duration(seconds: _duration.inSeconds), () {
            this.listen.add(true);
          });
        }

        return;
      }
    } catch (e) {
      print(e);
      return;
    }

    return;
  }
}

class SILPerfMonitor {
  /// monitor async function that at least return a future void
  static void monitorAsyncFunc(Function action, String traceName) async {
    final Trace trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();
    await action();
    await trace.stop();
  }

  // monitors sync function that at least returns a void
  static void monitorSyncFunc(Function action, String traceName) async {
    final Trace trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();
    await action();
    await trace.stop();
  }
}

class SILEventBus {
  final StreamController<dynamic> _streamController;

  StreamController<dynamic> get streamController => _streamController;

  SILEventBus({bool sync = false})
      : _streamController = StreamController<dynamic>.broadcast(sync: sync);

  Stream<T> on<T>() {
    if (T == dynamic) {
      return streamController.stream;
    } else {
      return streamController.stream
          .where((dynamic event) => event is T)
          .cast<T>();
    }
  }

  void fire(dynamic event) async {
    streamController.add(event);
  }

  void destroy() {
    _streamController.close();
  }
}

class TriggeredEvent {
  String eventName;
  Map<String, dynamic> eventPayload;

  TriggeredEvent(
    this.eventName,
    this.eventPayload,
  );
}

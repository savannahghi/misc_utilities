library sil_misc;

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sil_misc/sil_enums.dart';
import 'package:sil_misc/src/widget_keys.dart';

import 'package:sil_themes/constants.dart';

/// [extractNamesInitials] extracts name initials from a name
///
/// Usage:
///
/// if you pass in a name like 'Abiud Orina', it returns 'AO'
String extractNamesInitials({required String name}) {
  final List<String> parts = name.split(' ');
  if (parts.length >= 2) {
    final StringBuffer initials = StringBuffer();
    for (int i = 0; i <= 1; i++) {
      final String part = parts[i];
      initials.write(part[0].toUpperCase());
    }
    return initials.toString().trim().substring(0, 2);
  }
  return parts.first.split('')[0].toUpperCase();
}

/// [convertStringToDate] converts a valid date time string to a [DateTime] object
DateTime convertStringToDate(
    {required String dateTimeString, required String format}) {
  return DateFormat(format).parse(dateTimeString);
}

/// [validatePhoneNumber] checks if a number is either a [Kenyan] or [American] phone number
bool validatePhoneNumber(String phone) {
  if (kenyanPhoneRegExp.hasMatch(phone)) {
    return true;
  } else if (americanPhoneRegExp.hasMatch(phone)) {
    return true;
  }
  return false;
}

/// [customRoundedPinBoxDecoration]
BoxDecoration customRoundedPinBoxDecoration(
  Color borderColor,
  Color pinBoxColor, {
  double borderWidth = 1.0,
  double? radius,
}) {
  return BoxDecoration(
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      color: pinBoxColor,
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}

/// [formatPhoneNumber]
String formatPhoneNumber(
    {required String countryCode, required String phoneNumber}) {
  if (!countryCode.startsWith('+')) {
    return '+$countryCode';
  }
  if (countryCode == '+1') {
    return '$countryCode$phoneNumber';
  }
  if (phoneNumber.startsWith('0')) {
    return phoneNumber.substring(1);
  }
  return '$countryCode$phoneNumber';
}

/// [getCoverValidityPeriod] gets the validity period of a cover
///
/// pass in a valid validTo string and it returns
/// a validity period in human readable form
String getCoverValidityPeriod(String validTo) {
  final Duration validityDuration =
      DateTime.parse(validTo).difference(DateTime.now());
  final String remainingMonths =
      (validityDuration.inDays / 30).floor().toString();
  final String remainingDays =
      (validityDuration.inDays % 30).floor().toString();
  return 'Valid for the next $remainingMonths months and $remainingDays days';
}

///  [getValidityDate]formats the validity date into a human readable format
String getValidityDate(String validTo) {
  return 'Till ${DateFormat('MMM dd, yyyy').format(DateTime.parse(validTo))}';
}

/// [validateEmail] validates an email against a regex
bool validateEmail(String email) {
  return emailValidator.hasMatch(email);
}

/// [formatCurrency] formats the amount passed in, into a human readable amount
String formatCurrency(dynamic amount) {
  if (amount is String || amount is int || amount is double) {
    return NumberFormat('#,###,###').format(amount);
  }
  return '0';
}

/// [titleCase] returns a title cased sentence
String titleCase(String sentence) {
  return sentence
      .toLowerCase()
      .split(' ')
      .map((String e) => e.trim())
      .map((String word) => toBeginningOfSentenceCase(word))
      .join(' ');
}

/// returns the list of auth types by removing the last comma
String parseAuthTypes(List<String> authenticationTypes) {
  String auth = '';

  for (int i = 0; i < authenticationTypes.length; i++) {
    final String _auth = authenticationTypes[i];
    //. check if its last or only item so as not to
    // append a comma
    if ((i + 1) == authenticationTypes.length) {
      auth = '$auth${'$_auth '}';
    } else {
      auth = '$auth${'$_auth & '}';
    }
  }

  return auth;
}

/// [howErrorSnackbar]
void showErrorSnackbar(BuildContext ctx,
    [String? msg, Color color = Colors.red]) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(
        msg ?? UserFeedBackTexts.getErrorMessage(),
        style: Theme.of(ctx).textTheme.bodyText2!.copyWith(color: Colors.white),
      ),
      duration: const Duration(seconds: kShortSnackBarDuration),
    ),
  );
  return;
}

/// [getGreetingMessage] gets the current time of day and determines which type of greetings to show
/// to the user
String getGreetingMessage(String? firstName, {int? currentHour}) {
  final int hour = currentHour ?? DateTime.now().hour;
  final String name = firstName == null ? '' : ', $firstName';
  if (hour < 12) {
    return 'Good Morning$name';
  }
  if (hour < 17) {
    return 'Good Afternoon$name';
  }
  return 'Good Evening$name';
}

/// [removeUnderscores] removes underscores from a sentence
String removeUnderscores(String sentence) {
  return titleCase(sentence.toString().replaceAll('_', ' ').toLowerCase());
}

/// [bottomSheet]
void bottomSheet(
    {required BuildContext context,
    required String message,
    required Function? action,
    required Color backgroundColor,
    required Color textColor,
    required Color primaryColor}) {
  showModalBottomSheet<List<dynamic>>(
    context: context,
    enableDrag: true,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    builder: (BuildContext bc) {
      return Container(
        key: containerKey,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
          ),
        ),
        height: action != null ? 314.0 : 250.0,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CircleAvatar(
                radius: 30.0,
                backgroundColor: const Color(0xFF50C878),
                child: Icon(
                  Icons.check,
                  size: 36.0,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: textColor,
                      ),
                ),
              ),
              if (action != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: double.infinity,
                  height: 56,
                  child: MaterialButton(
                    key: okButtonKey,
                    elevation: 0,
                    color: primaryColor,
                    textColor: Theme.of(context).backgroundColor,
                    onPressed: () {
                      Navigator.pop(context);
                      action();
                    },
                    child: const Text('OK',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        )),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// [verifyOTPErrorBottomSheet]
void verifyOTPErrorBottomSheet(
    {required BuildContext context,
    required String message,
    required Function? actionEnterCode,
    required Color textColor,
    required Color primaryColor}) {
  showModalBottomSheet<List<dynamic>>(
    context: context,
    enableDrag: true,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    builder: (BuildContext bc) {
      return Container(
        key: containerKey,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
          ),
        ),
        height: actionEnterCode != null ? 314.0 : 250.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(
                    Radius.circular(40.0),
                  ),
                ),
                child: const Icon(
                  Icons.error,
                  size: 58,
                  color: Colors.white,
                ),
              ),
              Center(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color:
                            Theme.of(context).textSelectionTheme.selectionColor,
                      ),
                ),
              ),
              if (actionEnterCode != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: MaterialButton(
                      key: reenterCodeButtonKey,
                      height: 56,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                        actionEnterCode();
                      },
                      child: const Text(
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
    },
  );
}

/// [snackbar]
SnackBar snackbar(

    /// [content] must be either of type [Widget] or [String]
    {required dynamic content,
    int durationSeconds = 10,
    String? label,
    Function? callback}) {
  return SnackBar(
    content: content.runtimeType == String
        ? Text(content as String)
        : content as Widget,
    duration: Duration(seconds: durationSeconds),
    action: callback != null
        ? SnackBarAction(label: label!, onPressed: callback as void Function())
        : null,
  );
}

/// [localPath]
Future<String> localPath(
    {Future<Directory> Function() fetchApplicationDirectory =
        getApplicationDocumentsDirectory}) async {
  final Directory directory = await fetchApplicationDirectory();
  final String dirPath = '${directory.path}/Pictures/sil-mobile';
  await Directory(dirPath).create(recursive: true);
  final String filePath = '$dirPath/{$DateTime.now()}.png';
  return filePath;
}

/// [uploadMutationVariable]
Map<String, dynamic> uploadMutationVariable(Map<String, dynamic> payload) {
  final Map<String, dynamic> inputVariables = <String, dynamic>{};
  inputVariables['title'] = payload['title'];
  inputVariables['contentType'] = payload['contentType'];
  inputVariables['language'] = 'en';
  inputVariables['filename'] = payload['filename'];
  inputVariables['base64data'] = payload['base64data'];
  return <String, dynamic>{'input': inputVariables};
}

/// [backgroundGradient]
LinearGradient backgroundGradient(
        {required int primaryLinearGradientColor, required int primaryColor}) =>
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const <double>[0, 0.7],
      colors: <Color>[
        Color(primaryLinearGradientColor),
        Color(primaryColor),
      ],
    );

/// [convertDateToString]
String convertDateToString({
  required DateTime date,
  required String format,
}) {
  return DateFormat(format).format(date);
}

/// [getDeviceType]
DeviceScreenType getDeviceType(MediaQueryData mediaQuery) {
  final Orientation deviceOrientation = mediaQuery.orientation;
  double deviceWidth = 0;
  if (deviceOrientation == Orientation.landscape) {
    deviceWidth = mediaQuery.size.height;
  } else {
    deviceWidth = mediaQuery.size.width;
  }

  if (deviceWidth > 950) {
    return DeviceScreenType.Desktop;
  }
  if (deviceWidth > 600) {
    return DeviceScreenType.Tablet;
  }
  return DeviceScreenType.Mobile;
}

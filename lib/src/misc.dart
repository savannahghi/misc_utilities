library sil_misc;

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_wrapper/app_wrapper.dart';
import 'package:flutter_graphql_client/graph_client.dart';
import 'package:flutter_graphql_client/graph_constants.dart';
import 'package:flutter_graphql_client/graph_event_bus.dart';
import 'package:misc_utilities/bottom_sheet_builder.dart';
import 'package:misc_utilities/enums.dart';
import 'package:misc_utilities/mutations.dart';
import 'package:misc_utilities/src/string_constant.dart';
import 'package:shared_themes/constants.dart';
import 'package:domain_objects/failures.dart';
import '../constants.dart';

enum UserInactivityStatus { okay, requiresLogin, requiresPin }

/// [extractNamesInitials] => Extracts name initials from a name
///
/// Usage:
///
/// If you pass in a name like 'Abiud Orina', it returns 'AO'
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

/// [formatPhoneNumber]
String formatPhoneNumber(
    {required String countryCode, required String phoneNumber}) {
  final String _trimmedPhone = trimWhitespace(phoneNumber);

  final String _countryCode =
      !countryCode.startsWith('+') ? '+$countryCode' : countryCode;

  if (_countryCode == '+1' || _countryCode == '+44' || _countryCode == '+32') {
    return '$countryCode$_trimmedPhone';
  } else {
    final String _phoneNumber = _trimmedPhone.startsWith('0')
        ? _trimmedPhone.substring(1)
        : _trimmedPhone;

    return '$_countryCode$_phoneNumber';
  }
}

/// [validatePhoneNumber] checks if a number is either a [Kenyan] , [American],  [UK] or [Belgium] phone number
bool validatePhoneNumber(String phone) {
  if (kenyanPhoneRegExp.hasMatch(phone) ||
      (americanPhoneRegExp.hasMatch(phone)) ||
      (unitedKingdomRegExp.hasMatch(phone)) ||
      (genericInternationalRegExp.hasMatch(phone))) {
    return true;
  } else {
    return false;
  }
}

/// [validateKenyanNumber] checks if a number is either has either prefix of '+254111', '+254110', '+254100', '+2540101', '+254102' or '+2547xx'
bool validateKenyanNumber(String phone) {
  String prefix;
  final String fifthChar = phone.substring(4, 5);
  if (fifthChar == '7') {
    return true;
  } else if (fifthChar == '1') {
    prefix = phone.substring(0, 7);
    if (validPrefixes.contains(prefix)) {
      return true;
    }
    return false;
  } else {
    return false;
  }
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
void bottomSheet({
  required BuildContext context,
  required SILBottomSheetBuilder builder,
}) {
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
    builder: builder.build,
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
DeviceScreensType getDeviceType(BuildContext context) {
  final MediaQueryData mediaQuery = MediaQuery.of(context);
  final Orientation deviceOrientation = mediaQuery.orientation;
  double deviceWidth = 0;
  if (deviceOrientation == Orientation.landscape) {
    deviceWidth = mediaQuery.size.height;
  } else {
    deviceWidth = mediaQuery.size.width;
  }

  if (deviceWidth > 1200) {
    return DeviceScreensType.Desktop;
  }
  if (deviceWidth > 600) {
    return DeviceScreensType.Tablet;
  }
  return DeviceScreensType.Mobile;
}

///[Get Upload ID]
///get ID of uploaded file
Future<String> getUploadId(
    {required Map<String, dynamic> fileData,
    required BuildContext context}) async {
  final ISILGraphQlClient _client = AppWrapperBase.of(context)!.graphQLClient;
  try {
    final http.Response result = await _client
        .query(uploadMutation, <String, dynamic>{'input': fileData});
    final Map<String, dynamic> body = _client.toMap(result);

    //check first for errors
    if (_client.parseError(body) != null) {
      return 'err';
    }

    if (body['data'] != null) {
      return body['data']['upload']['id'] as String;
    } else {
      return 'err';
    }
  } catch (e) {
    return 'err';
  }
}

String? parseError(Map<String, dynamic>? body) {
  if (body == null) return null;

  final Object? error =
      body.containsKey('errors') ? body['errors'] : body['error'];

  if (error == null) return null;

  if (error is List<dynamic>) {
    final Map<String, dynamic> firstEntry = error.first as Map<String, dynamic>;
    return firstEntry['message'] as String;
  }

  if (error is String) {
    return error.contains(RegExp('ID token', caseSensitive: false))
        ? kLoginLogoutPrompt
        : error;
  }

  return null;
}

/// [Generic Fetch Function]
/// a generic fetch function for fetching all the problems, allergies
/// medications, tests and diagnoses for the current patient
/// in an episode
///
/// it takes in a [String queryString], the Map of the query variables [variables],
/// the BuildContext [context], and a stream controller [streamController] in which the data is added to
///
/// it then updates the stream controller with the returned data (if any) or
/// an error if there was an error
Future<dynamic> genericFetchFunction({
  required StreamController<dynamic> streamController,
  required BuildContext context,
  required String queryString,
  required Map<String, dynamic> variables,
  required String logTitle,
  String? logDescription,
}) async {
  // indicate processing is ongoing
  streamController.add(<String, dynamic>{'loading': true});

  final ISILGraphQlClient _client = AppWrapperBase.of(context)!.graphQLClient;

  /// fetch the data from the api
  final http.Response response = await _client.query(
    queryString,
    variables,
  );

  final Map<String, dynamic> payLoad = _client.toMap(response);

  SaveTraceLog(
    client: AppWrapperBase.of(context)!.graphQLClient,
    query: queryString,
    data: variables,
    response: payLoad,
    title: logTitle,
    description: logDescription,
  ).saveLog();

  final String? error = parseError(payLoad);

  //check first for errors
  if (error != null) {
    return streamController
        .addError(<String, dynamic>{'error': _client.parseError(payLoad)});
  }

  return (payLoad['data'] != null)
      ? streamController.add(payLoad['data'])
      : streamController.add(null);
}

///[Get ID Type]
/// gets the selected ID type
String getIdType({required String idType, required bool userString}) {
  if (idType.toLowerCase().contains('passport')) {
    return userString ? 'Passport' : 'PASSPORT';
  }
  if (idType.toLowerCase().contains('national')) {
    return userString ? 'National ID' : 'NATIONALID';
  }
  return userString ? 'Military ID' : 'MILITARY';
}

/// [Launch WhatsApp]
/// Function that launches WhatsApp
Future<String?> launchWhatsApp({
  required String phone,
  required String message,
  required Future<bool> launch,
}) async {
  try {
    await launch;
  } catch (e) {
    throw SILException(
        cause: 'launch_whatsApp',
        message:
            'Could not launch ${whatsAppUrl(phone: phone, message: message)}');
  }
}

///[check inactivity time]
/// if inactivity period is less than an half an hour --- just resume
/// if inactivity time is greater than 1 and less than 12 hours --- require pin
/// if inactivity period is greater than 12 hours --- require login
/// [inActivitySetInTime] represents the last time the user was active in the app.
/// when user logs in or creates an account, this value is set to the current timestamp.
/// It's is then update every often when the app moves back to the foreground.
UserInactivityStatus checkInactivityTime(
  String? inActivitySetInTime,
  String? expiresAt,
) {
  if (inActivitySetInTime == null) {
    return UserInactivityStatus.okay;
  }

  final DateTime? lastActivityTime = DateTime.tryParse(inActivitySetInTime);
  if (lastActivityTime == null) {
    // we can't determine last activity time, so login is required
    return UserInactivityStatus.requiresLogin;
  }

  final int timeDiff = DateTime.now().difference(lastActivityTime).inHours;

  if (timeDiff < 1) {
    // check if token has expired or is about to and require pin if so
    lastActivityTime.add(Duration(seconds: int.tryParse(expiresAt!)!));

    final int tokenAge = DateTime.now()
        .difference(
            lastActivityTime.add(Duration(seconds: int.tryParse(expiresAt)!)))
        .inMinutes;

    // require pin login if token is about to expire
    if (tokenAge > -10) {
      return UserInactivityStatus.requiresPin;
    }

    return UserInactivityStatus.okay;
  }

  if (timeDiff > 1 && timeDiff < 12) {
    return UserInactivityStatus.requiresPin;
  }

  return UserInactivityStatus.requiresLogin;
}

/// [trim white space]
/// Removes white spaces in between a string, at the beginning and at the end
String trimWhitespace(String param) {
  assert(param is String);
  return param.toString().trim().split(' ').join();
}

/// [Dismiss snackbar]
SnackBarAction dismissSnackBar(String text, Color color, BuildContext context) {
  return SnackBarAction(
    label: text,
    textColor: color,
    onPressed: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    },
  );
}

/// [DateFormatter] Used to format date and time
class DateFormatter {
  DateFormatter(this.dateValue);

  final String dateValue;

  String parseDateValue() {
    final DateTime? parsedDate = DateTime.tryParse(this.dateValue);
    if (parsedDate == null) return unknown;
    final String formattedDate = DateFormat('d MMM, yyyy').format(parsedDate);
    return formattedDate;
  }

  String parseDateTimeValue() {
    final DateTime? parsedDate = DateTime.tryParse(this.dateValue);
    if (parsedDate == null) return unknown;
    final String formattedDateTime =
        DateFormat.jm().add_yMMMd().format(parsedDate);
    return formattedDateTime;
  }
}

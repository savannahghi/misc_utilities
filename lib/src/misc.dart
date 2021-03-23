library sil_misc;

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sil_app_wrapper/sil_app_wrapper_base.dart';
import 'package:sil_graphql_client/graph_client.dart';
import 'package:sil_graphql_client/graph_event_bus.dart';
import 'package:sil_misc/sil_bottom_sheet_builder.dart';
import 'package:sil_misc/sil_enums.dart';
import 'package:sil_misc/sil_mutations.dart';

import 'package:sil_themes/constants.dart';
import 'package:http/http.dart' as http;
import 'package:sil_ui_components/sil_comms_setting.dart';
import 'package:url_launcher/url_launcher.dart';

enum UserInactivityStatus { okey, requiresLogin, requiresPin }

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

  if (deviceWidth > 950) {
    return DeviceScreensType.Desktop;
  }
  if (deviceWidth > 600) {
    return DeviceScreensType.Tablet;
  }
  return DeviceScreensType.Mobile;
}

///[Change Communication Settings]
Future<bool> changeCommunicationSetting(
    {required CommunicationType channel,
    required bool isAllowed,
    required BuildContext context,
    required Map<String, bool>? settings,
    required Function communicationSettingsFunc}) async {
  final Map<String, bool> _variables = <String, bool>{
    'allowEmail': settings!['allowEmail']!,
    'allowWhatsApp': settings['allowWhatsApp']!,
    'allowTextSMS': settings['allowText']!,
    'allowPush': settings['allowPush']!,
  };
  final SILGraphQlClient _client = SILAppWrapperBase.of(context)!.graphQLClient;

  _variables[channel.toShortString()] = isAllowed;

  /// fetch the data from the api
  final http.Response _result = await _client.query(
    setCommSettingsMutation,
    _variables,
  );

  final Map<String, dynamic> response = _client.toMap(_result);
  // /// check if the response has timeout metadata. If yes, return an error to
  // /// handled correctly
  if (_result.statusCode == 408) {
    return false;
  }

  // // check for errors in the data here
  if (_client.parseError(response) != null) {
    return false;
  }
  communicationSettingsFunc(communicationSettings: _variables);
  return true;
}

///[Set-up as an Experiment Participant]
///function for getting whether a user is set up as an experiment participant
Future<bool?> setupAsExperimentParticipant(
    {required BuildContext context, bool participate = false}) async {
  final SILGraphQlClient _client = SILAppWrapperBase.of(context)!.graphQLClient;

  final http.Response result = await _client.query(
      setupUserAsExperimentParticipant,
      setupAsExperimentParticipantVariables());

  final Map<String, dynamic> response = _client.toMap(result);

  SaveTraceLog(
    client: SILAppWrapperBase.of(context)!.graphQLClient,
    query: setupUserAsExperimentParticipant,
    data: setupAsExperimentParticipantVariables(),
    response: response,
    title: 'Setup user as experiment participant',
    description: 'Setup user as experiment participant',
  ).saveLog();

  if (_client.parseError(response) != null) {
    return null;
  } else {
    final bool responseData =
        response['data']['setupAsExperimentParticipant'] as bool;

    return responseData;
  }
}

///[Get Upload ID]
///get ID of uploaded file
Future<String?> getUploadId(
    {required Map<String, dynamic> fileData,
    required BuildContext context}) async {
  final SILGraphQlClient _client = SILAppWrapperBase.of(context)!.graphQLClient;
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

///[Generic Fetch Function]
/// a generic fetch function for fetching all the problems, allergies
/// medications, tests and diagnoses for the current patient
/// in an episode
///
/// it takes in a [String queryString], the Map of the query variables [variables],
/// the BuildContext [context], and a stream controller [streamController] in which the data is added to
///
/// it then updates the stream controller with the returned data (if any) or
/// an error if there was an error
Future<dynamic> genericFetchFunction(
    {required StreamController<dynamic> streamController,
    required BuildContext context,
    required String queryString,
    required Map<String, dynamic> variables,
     String? logTitle,
     String? logDescription,
    }) async {
  // indicate processing is ongoing
  streamController.add(<String, dynamic>{'loading': true});

  final SILGraphQlClient _client = SILAppWrapperBase.of(context)!.graphQLClient;

  /// fetch the data from the api
  final http.Response response = await _client.query(
    queryString,
    variables,
  );

  final Map<String, dynamic> payLoad = _client.toMap(response);


  SaveTraceLog(
    client: SILAppWrapperBase.of(context)!.graphQLClient,
    query: queryString,
    data: variables,
    response: payLoad,
    title: logTitle!,
    description: logDescription,
  ).saveLog();

  //check first for errors
  if (_client.parseError(payLoad) != null) {
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

///[Launch WhatsApp]
///function that launches whatsapp
Future<String?> launchWhatsApp({
  required String phone,
  required String message,
}) async {
  final String whatsAppUrl = 'https://wa.me/$phone/?text=${Uri.parse(message)}';
  try {
    await launch(whatsAppUrl);
  } catch (e) {
    throw 'Could not launch $whatsAppUrl';
  }
}

///[check inactivity time]
/// if inactivity period is less than an hour --- just resume
/// if inactivity time is greater than 1 and less than 12 hours --- require pin
/// if inactivity period is greater than 12 hours --- require login
UserInactivityStatus checkInactivityTime(
  String? inActivitySetInTime,
  String? expiresAt,
) {
  if (inActivitySetInTime == null) {
    return UserInactivityStatus.okey;
  }

  
  final DateTime? lastActivityTime = DateTime.tryParse(inActivitySetInTime);
  if (lastActivityTime == null) {
    // we can't determine last activity time, so login is required
    return UserInactivityStatus.requiresLogin;
  }

  final int timeDiff = DateTime.now().difference(lastActivityTime).inHours;

  if (timeDiff < 1) {
    // check if token has expired or is about to and require pin if so
    final int tokenAge =
        DateTime.now().difference(DateTime.tryParse(expiresAt!)!).inMinutes;
    // require pin login if token is about to expire
    if (tokenAge > -5) {
      return UserInactivityStatus.requiresPin;
    }

    return UserInactivityStatus.okey;
  }

  if (timeDiff > 1 && timeDiff < 12) {
    return UserInactivityStatus.requiresPin;
  }

  return UserInactivityStatus.requiresLogin;
}

///[trim white space]
/// removes white spaces in between a string, at the beginning and at the end
String trimWhitespace(String param) {
  assert(param is String);
  return param.toString().trim().split(' ').join();
}



///[dismiss snackbar]
SnackBarAction dismissSnackBar(String text, Color color, BuildContext context) {
  return SnackBarAction(
    label: text,
    textColor: color,
    onPressed: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    },
  );
}

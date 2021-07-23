import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:misc_utilities/misc.dart';
import 'package:misc_utilities/refresh_token_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:domain_objects/failures.dart';
import 'package:misc_utilities/src/misc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('Misc ', () {
    test('should convertDateToString should return correctly formatted date', () {
      final DateTime date = DateTime(2020, DateTime.january, 31);
      const String expected = '31-01-2020';
      final String formattedDate =
          convertDateToString(date: date, format: 'dd-MM-yyyy');

      expect(formattedDate, expected);
    });

    test('test extract name initials', () {
      expect('DD', extractNamesInitials(name: 'david dexter'));
      expect('MV', extractNamesInitials(name: 'Michuki vincent'));
      expect('dd', isNot(extractNamesInitials(name: 'david dexter mwangi')));
      expect('D', extractNamesInitials(name: 'david'));
    });

    test('convertStringToDate should return correct date', () {
      const String stringDate = '03-02-2020';
      final DateTime expectedDate = DateTime(2020, DateTime.february, 3);

      final DateTime convertedDate = convertStringToDate(
        format: 'dd-MM-yyyy',
        dateTimeString: stringDate,
      );

      expect(convertedDate, expectedDate);
    });

    test('should format currency as a integer', () {
      // setup
      const int currency = 200;
      const String expectedFormattedCurrency = '200';

      // call the actual method
      final String actualFormattedCurrency = formatCurrency(currency);

      // verify functionality
      expect(actualFormattedCurrency, isNotNull);
      expect(actualFormattedCurrency, isA<String>());
      expect(actualFormattedCurrency, expectedFormattedCurrency);
    });

    test('should format currency as a double', () {
      // setup
      const double currency = 200.55;
      const String expectedFormattedCurrency = '201';

      // call the actual method
      final String actualFormattedCurrency = formatCurrency(currency);

      // verify functionality
      expect(actualFormattedCurrency, isNotNull);
      expect(actualFormattedCurrency, isA<String>());
      expect(actualFormattedCurrency, expectedFormattedCurrency);

      expect(actualFormattedCurrency.split('.').length, 1);
      expect(actualFormattedCurrency.contains('.'), false);
    });

    test('should format currency as a double', () {
      // setup
      final Widget currency = Container();
      const String expectedFormattedCurrency = '0';

      // call the actual method
      final String actualFormattedCurrency = formatCurrency(currency);

      // verify functionality
      expect(actualFormattedCurrency, isNotNull);
      expect(actualFormattedCurrency, isA<String>());
      expect(actualFormattedCurrency, expectedFormattedCurrency);

      expect(actualFormattedCurrency.contains('0'), true);
    });

    test('should validate email', () {
      // setup
      const String validEmail = 'a@a.com';
      const String validDomainEmail = 'test@coverage.sil';
      const String invalidEmail = 'wrongemail.comn';

      // call the actual function with the input and verify functionality
      bool isValidEmail = validateEmail(validEmail);
      expect(isValidEmail, isA<bool>());
      expect(isValidEmail, true);

      isValidEmail = validateEmail(validDomainEmail);
      expect(isValidEmail, isA<bool>());
      expect(isValidEmail, true);

      isValidEmail = validateEmail(invalidEmail);
      expect(isValidEmail, isA<bool>());
      expect(isValidEmail, false);
    });

    test('should get cover validity period', () {
      const String validTo = '2021-08-01';
      final String formattedValidTo = getCoverValidityPeriod(validTo);
      expect(formattedValidTo, isA<String>());
    });

    test('should get cover validity date', () {
      const String validTo = '2021-08-01';
      const String expectedValidity = 'Till Aug 01, 2021';
      final String formattedValidTo = getValidityDate(validTo);
      expect(formattedValidTo, isA<String>());
      expect(formattedValidTo, expectedValidity);
    });

    test('should parse auth types', () {
      final List<String> authTypes = <String>['OTP', 'Fingerprint'];
      const String expectedAuthTypes = 'OTP & Fingerprint ';
      final String formattedAuthTypes = parseAuthTypes(authTypes);
      expect(formattedAuthTypes, isA<String>());
      expect(formattedAuthTypes, expectedAuthTypes);
    });

    test('should return the titleCase of a sentence', () {
      String sentence = 'bewell is improving healthcare';
      String expectedFormattedSentence = 'Bewell Is Improving Healthcare';
      String actualTitleCasedString = titleCase(sentence);
      expect(actualTitleCasedString, expectedFormattedSentence);

      // check if it formats a spaced string
      sentence = 'kowalski    analysis';
      expectedFormattedSentence = 'Kowalski    Analysis';
      actualTitleCasedString = titleCase(sentence);
      expect(actualTitleCasedString, expectedFormattedSentence);

      // check if it returns an empty string if the sentence is empty
      sentence = '';
      expectedFormattedSentence = '';
      actualTitleCasedString = titleCase(sentence);
      expect(actualTitleCasedString, expectedFormattedSentence);
    });

    test('should return the correct greeting message', () {
      const int morningHour = 11;
      const int afternoonHour = 15;
      const int eveningHour = 20;
      const String firstName = 'coverage';

      String greetingMessage =
          getGreetingMessage(firstName, currentHour: morningHour);

      expect(greetingMessage, isA<String>());
      expect(greetingMessage.contains('Morning'), true);
      expect(greetingMessage.contains(firstName), true);

      greetingMessage =
          getGreetingMessage(firstName, currentHour: afternoonHour);
      expect(greetingMessage, isA<String>());
      expect(greetingMessage.contains('Afternoon'), true);
      expect(greetingMessage.contains(firstName), true);

      greetingMessage = getGreetingMessage(firstName, currentHour: eveningHour);
      expect(greetingMessage, isA<String>());
      expect(greetingMessage.contains('Evening'), true);
      expect(greetingMessage.contains(firstName), true);

      greetingMessage = getGreetingMessage(firstName);
      expect(greetingMessage, isA<String>());
      expect(greetingMessage.contains(firstName), true);
    });

    test('should test other phone number', () {
      expect(formatPhoneNumber(phoneNumber: '1234567', countryCode: '+255'),
          '+2551234567');

      expect(
        formatPhoneNumber(countryCode: '254', phoneNumber: '790123456'),
        '+254790123456',
      );

      expect(
        formatPhoneNumber(countryCode: '254', phoneNumber: '0790123456'),
        '+254790123456',
      );

      expect(
        formatPhoneNumber(countryCode: '+1', phoneNumber: '100000'),
        '+1100000',
      );

      expect(formatPhoneNumber(countryCode: '+254', phoneNumber: '07100000'),
          '+2547100000');

      // Output should be +442087599036 (A UK phone number)
      final String formattedUKPhoneNumber =
          formatPhoneNumber(countryCode: '+44', phoneNumber: '2087599036');
      expect(formattedUKPhoneNumber, '+442087599036');

      // validate the phone number
      expect(validatePhoneNumber(formattedUKPhoneNumber), true);

      // Output should be +32460205037 (A Belgium phone number)
      final String formattedBelgiumPhoneNumber =
          formatPhoneNumber(countryCode: '+32', phoneNumber: '460205037');
      expect(formattedBelgiumPhoneNumber, '+32460205037');

      // validate the phone number
      expect(validatePhoneNumber(formattedBelgiumPhoneNumber), true);

      // Output should be +2547123456789 (A normal Kenyan phone number)
      final String formattedNormalKenyanPhoneNumber =
          formatPhoneNumber(countryCode: '+254', phoneNumber: '7123456789');
      expect(formattedNormalKenyanPhoneNumber, '+2547123456789');

      // validate the phone number
      expect(validatePhoneNumber(formattedNormalKenyanPhoneNumber), true);

      // Output should be +254110123456 (A new Safaricom phone number)
      final String formattedNewSafaricomKenyanPhoneNumber =
          formatPhoneNumber(countryCode: '+254', phoneNumber: '110123456');
      expect(formattedNewSafaricomKenyanPhoneNumber, '+254110123456');

      // validate the phone number
      expect(validatePhoneNumber(formattedNewSafaricomKenyanPhoneNumber), true);

      // Output should be +254110123456 (A new Safaricom phone number)
      final String formattedKenyanPhoneNumberWithSpaces =
          formatPhoneNumber(countryCode: '+254', phoneNumber: '110 123 456');
      expect(formattedKenyanPhoneNumberWithSpaces, '+254110123456');

      // validate the phone number
      expect(validatePhoneNumber(formattedKenyanPhoneNumberWithSpaces), true);
    });

    test('should return background gradient', () {
      final LinearGradient gradient = backgroundGradient(
        primaryColor: 0xFF7949AF,
        primaryLinearGradientColor: 0xFF7949AF,
      );
      expect(gradient, isA<LinearGradient>());
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    test('should return uploadMutationVariable', () {
      final Map<String, dynamic> variables =
          uploadMutationVariable(<String, dynamic>{
        'title': 'title',
        'contentType': 'contentType',
        'filename': 'filename',
        'base64data': 'base64data'
      });
      expect(variables, isA<Map<String, dynamic>>());
      expect(variables['input'], isA<Map<String, dynamic>>());
    });

    test('should return localPath', () {
      final Future<String> path = localPath(
          fetchApplicationDirectory: () =>
              Future<Directory>.value(Directory('test')));
      expect(path, isA<Future<String>>());
      path.then((String value) =>
          expect(value, contains('test/Pictures/sil-mobile')));
    });

    test('should test SILException', () {
      expect(
          () => throw SILException(
              cause: 'no_user_account_found', message: 'No user'),
          throwsException);
    });

    test('should throw exception when launching WhatsApp', () {
      const String phone = '';
      const String message = '';
      final String whatsAppUrl =
          'https//wa.me/$phone/?text=${Uri.parse(message)}';
      expect(
          () async => launchWhatsApp(
              phone: phone,
              message: message,
              launch:
                  launch(whatsAppUrl, statusBarBrightness: Brightness.dark)),
          throwsException);
    });

    group('validatePhoneNumber', () {
      test('should return validate phone numbers', () {
        const String kenyanNumber = '+254123456789';
        const String usNumber = '+12025550163';
        const String validUKPhone = '+447975777666';
        const String validBelgiumPhone = '+3225450130';
        const String invalidPhone = '+322adf5013012';

        expect(validatePhoneNumber(kenyanNumber), true);
        expect(validatePhoneNumber(usNumber), true);
        expect(validatePhoneNumber(validUKPhone), true);
        expect(validatePhoneNumber(validBelgiumPhone), true);
        expect(validatePhoneNumber(invalidPhone), false);
      });
    });

    group('checkInactivityTime', () {
      test('should return okay if null', () {
        expect(checkInactivityTime(null, null), UserInactivityStatus.okay);
      });

      test(
          'should return requiresLogin because we cannot determine last activity time',
          () {
        expect(checkInactivityTime('unknown', null),
            UserInactivityStatus.requiresLogin);
      });

      test('should return okay after just login', () {
        expect(checkInactivityTime(DateTime.now().toIso8601String(), '3600'),
            UserInactivityStatus.okay);
      });

      test('should return requiresPin when token is about to expire', () {
        expect(
            checkInactivityTime(
                DateTime.now()
                    .subtract(const Duration(minutes: 53))
                    .toIso8601String(),
                '3600'),
            UserInactivityStatus.requiresPin);
      });

      test('should return requiresPin when last activity was hours ago', () {
        expect(
            checkInactivityTime(
                DateTime.now()
                    .subtract(const Duration(hours: 3))
                    .toIso8601String(),
                '3600'),
            UserInactivityStatus.requiresPin);
      });

      test(
          'should return requiresLogin when last activity is more than 12 hours',
          () {
        expect(
            checkInactivityTime(
                DateTime.now()
                    .subtract(const Duration(hours: 17))
                    .toIso8601String(),
                '3600'),
            UserInactivityStatus.requiresLogin);
      });
    });

    group('RefreshTokenManger', () {
      final BehaviorSubject<dynamic> listen = BehaviorSubject<dynamic>();
      test('should updateExpireTime', () {
        const String time = '2021-02-01 10:15:21Z';
        RefreshTokenManger().updateExpireTime(time);
        RefreshTokenManger().updateExpireTime(time).reset();
        expect(listen.hasValue, false);
        expect(listen.valueOrNull, null);
      });

      test('should reset 6 minutes to the expiry time', () {
        final String expiresAt =
            DateTime.now().add(const Duration(minutes: 6)).toString();

        RefreshTokenManger().checkExpireValidity(expiresAt);
        expect(RefreshTokenManger().checkExpireValidity(expiresAt), false);
        //Set expiry time
        RefreshTokenManger().updateExpireTime(expiresAt);
        //Reset expiry time
        RefreshTokenManger().updateExpireTime(expiresAt).reset();

        expect(listen.hasValue, false);
        expect(listen.valueOrNull, null);
      });

      test('should reset 7 minutes to the expiry time', () {
        final String expiresAt = DateTime.now()
            .subtract(const Duration(minutes: 10, seconds: 1))
            .toString();

        RefreshTokenManger().checkExpireValidity(expiresAt);

        expect(RefreshTokenManger().checkExpireValidity(expiresAt), false);
        expect(listen.hasValue, false);
        expect(listen.valueOrNull, null);
        //Set expiry time
        RefreshTokenManger().updateExpireTime(expiresAt);
        //Reset expiry time
        RefreshTokenManger().updateExpireTime(expiresAt).reset();

        expect(listen.hasValue, false);
        expect(listen.valueOrNull, null);
      });

      test('should reset 15 minutes to the expiry time', () {
        final String expiryTime =
            DateTime.now().add(const Duration(minutes: 15)).toString();

        //Reset expiry time
        RefreshTokenManger().updateExpireTime(expiryTime).reset();

        expect(listen.hasValue, false);
        expect(listen.valueOrNull, null);
      });
      test('should reset minutes to the expiry time', () {
        final String expiryTime = DateTime.now()
            .add(const Duration(hours: 2, minutes: 50))
            .toString();

        RefreshTokenManger().checkExpireValidity(expiryTime);

        expect(RefreshTokenManger().checkExpireValidity(expiryTime), true);
        expect(listen.hasValue, false);
        expect(listen.valueOrNull, null);

        expect(listen.valueOrNull, null);
        //Set expiry time
        RefreshTokenManger().updateExpireTime(expiryTime);
        //Reset expiry time
        RefreshTokenManger().updateExpireTime(expiryTime).reset();

        expect(listen.hasValue, false);
        expect(listen.valueOrNull, null);
      });
    });
    group('get ID type', () {
      test('should select passport ID type', () {
        const String idType = 'Passport';
        const bool userString = true;

        expect(getIdType(idType: idType, userString: userString), 'Passport');
      });
      test('should select national ID type', () {
        const String idType = 'national';
        const bool userString = true;

        expect(
            getIdType(idType: idType, userString: userString), 'National ID');
      });
      test('should select military ID type', () {
        const String idType = 'military';
        const bool userString = true;

        expect(
            getIdType(idType: idType, userString: userString), 'Military ID');
      });
    });

    test('should return a trimmed string', () {
      const String name = 'be   well';
      const String expectedFormattedName = 'bewell';
      final String actualTrimmedString = trimWhitespace(name);

      expect(actualTrimmedString, expectedFormattedName);
    });

    test('should return a string without underscore', () {
      const String name = 'be_well';
      const String expectedFormattedName = 'Be Well';
      final String actualRemovedUnderscoreString = removeUnderscores(name);

      expect(actualRemovedUnderscoreString, expectedFormattedName);
    });

    group('get ID type', () {
      test('should select passport ID type', () {
        const String idType = 'Passport';
        const bool userString = true;

        expect(getIdType(idType: idType, userString: userString), 'Passport');
      });
      test('should select national ID type', () {
        const String idType = 'national';
        const bool userString = true;

        expect(
            getIdType(idType: idType, userString: userString), 'National ID');
      });
      test('should select military ID type', () {
        const String idType = 'military';
        const bool userString = true;

        expect(
            getIdType(idType: idType, userString: userString), 'Military ID');
      });
    });

    test('should return a trimmed string', () {
      const String name = 'be   well';
      const String expectedFormattedName = 'bewell';
      final String actualTrimmedString = trimWhitespace(name);

      expect(actualTrimmedString, expectedFormattedName);
    });

    test('should return a string without underscore', () {
      const String name = 'be_well';
      const String expectedFormattedName = 'Be Well';
      final String actualRemovedUnderscoreString = removeUnderscores(name);

      expect(actualRemovedUnderscoreString, expectedFormattedName);
    });
    test('should return false when phone doest match prefix', () {
      const String phone = '+2541908765432';

      expect(validateKenyanNumber(phone), false);
    });
  });
}

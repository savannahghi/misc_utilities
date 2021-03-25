import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sil_misc/sil_exception.dart';
import 'package:sil_misc/sil_misc.dart';
import 'package:sil_misc/sil_refresh_token_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('SILMisc', () {
    test('convertDateToString should return correctly formatted date', () {
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
      const String valiedDomainEmail = 'test@coverage.sil';
      const String invalidEmail = 'wrongemail.comn';

      // call the actual function with the input and verify functionality
      bool isValidEmail = validateEmail(validEmail);
      expect(isValidEmail, isA<bool>());
      expect(isValidEmail, true);

      isValidEmail = validateEmail(valiedDomainEmail);
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

    test('should return the titlecase of a sentence', () {
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

    group('validatePhoneNumber', () {
      test('should return valid phone numbers', () {
        const String kenyanNumber = '+254123456789';
        const String usNumber = '+12025550163';

        expect(validatePhoneNumber(kenyanNumber), true);
        expect(validatePhoneNumber(usNumber), true);
      });

      test('should return invalid phone number', () {
        const String testPhone = '+2123456789';

        expect(validatePhoneNumber(testPhone), false);
      });
    });

    group('RefreshTokenManger', () {
      final BehaviorSubject<dynamic> listen = BehaviorSubject<dynamic>();
      test('should updateExpireTime', () {
        const String time = '2021-02-01 10:15:21Z';
        SILRefreshTokenManger().updateExpireTime(time);
        SILRefreshTokenManger().updateExpireTime(time).reset();
        expect(listen.valueWrapper, null);
      });

      test('should reset 6 minutes to the expiry time', () {
        final String expiresAt =
            DateTime.now().add(const Duration(minutes: 6)).toString();

        SILRefreshTokenManger().checkExpireValidity(expiresAt);
        expect(SILRefreshTokenManger().checkExpireValidity(expiresAt), false);
        //Set expiry time
        SILRefreshTokenManger().updateExpireTime(expiresAt);
        //Reset expiry time
        SILRefreshTokenManger().updateExpireTime(expiresAt).reset();

        expect(listen.valueWrapper, null);
      });

      test('should reset 7 minutes to the expiry time', () {
        final String expiresAt = DateTime.now()
            .subtract(const Duration(minutes: 10, seconds: 1))
            .toString();

        SILRefreshTokenManger().checkExpireValidity(expiresAt);

        expect(SILRefreshTokenManger().checkExpireValidity(expiresAt), false);
        expect(listen.valueWrapper, null);
        //Set expiry time
        SILRefreshTokenManger().updateExpireTime(expiresAt);
        //Reset expiry time
        SILRefreshTokenManger().updateExpireTime(expiresAt).reset();

        expect(listen.valueWrapper, null);
      });

      test('should reset 15 minutes to the expiry time', () {
        final String expiryTime =
            DateTime.now().add(const Duration(minutes: 15)).toString();

        //Reset expiry time
        SILRefreshTokenManger().updateExpireTime(expiryTime).reset();

        expect(listen.valueWrapper, null);
      });
      test('should reset minutes to the expiry time', () {
        final String expiryTime = DateTime.now()
            .add(const Duration(hours: 2, minutes: 50))
            .toString();

        SILRefreshTokenManger().checkExpireValidity(expiryTime);

        expect(SILRefreshTokenManger().checkExpireValidity(expiryTime), true);
        expect(listen.valueWrapper, null);

        expect(listen.value, null);
        //Set expiry time
        SILRefreshTokenManger().updateExpireTime(expiryTime);
        //Reset expiry time
        SILRefreshTokenManger().updateExpireTime(expiryTime).reset();

        expect(listen.valueWrapper, null);
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
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/sil_misc.dart';

import 'package:rxdart/rxdart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('SILMisc', () {
    test('convertDateToString should return correctly formatted date', () {
      final DateTime date = DateTime(2020, DateTime.january, 31);
      const String expected = '31-01-2020';
      final String formattedDate =
          SILMisc.convertDateToString(date: date, format: 'dd-MM-yyyy');

      expect(formattedDate, expected);
    });

    test('test extract name initials', () {
      expect('DD', SILMisc.extractNamesInitials(name: 'david dexter'));
      expect('MV', SILMisc.extractNamesInitials(name: 'Michuki vincent'));
      expect('dd',
          isNot(SILMisc.extractNamesInitials(name: 'david dexter mwangi')));
    });

    test('convertStringToDate should return correct date', () {
      const String stringDate = '03-02-2020';
      final DateTime expectedDate = DateTime(2020, DateTime.february, 3);

      final DateTime convertedDate = SILMisc.convertStringToDate(
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
     final String actualFormattedCurrency = SILMisc.formatCurrency(currency);

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
      final String actualFormattedCurrency = SILMisc.formatCurrency(currency);

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
     final String actualFormattedCurrency = SILMisc.formatCurrency(currency);

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
      bool isValidEmail = SILMisc.validateEmail(validEmail);
      expect(isValidEmail, isA<bool>());
      expect(isValidEmail, true);

      isValidEmail = SILMisc.validateEmail(valiedDomainEmail);
      expect(isValidEmail, isA<bool>());
      expect(isValidEmail, true);

      isValidEmail = SILMisc.validateEmail(invalidEmail);
      expect(isValidEmail, isA<bool>());
      expect(isValidEmail, false);
    });

    test('should get cover validity period', () {
      const String validTo = '2021-08-01';
      final String formattedValidTo = SILMisc.getCoverValidityPeriod(validTo);
      expect(formattedValidTo, isA<String>());
    });

    test('should get cover validity date', () {
      const String validTo = '2021-08-01';
      const String expectedValidity = 'Till Aug 01, 2021';
      final String formattedValidTo = SILMisc.getValidityDate(validTo);
      expect(formattedValidTo, isA<String>());
      expect(formattedValidTo, expectedValidity);
    });

    test('should parse auth types', () {
      final List<String> authTypes = <String>['OTP', 'Fingerprint'];
      const String expectedAuthTypes = 'OTP & Fingerprint ';
      final String formattedAuthTypes = SILMisc.parseAuthTypes(authTypes);
      expect(formattedAuthTypes, isA<String>());
      expect(formattedAuthTypes, expectedAuthTypes);
    });

    test('should return the titlecase of a sentence', () {
      String sentence = 'bewell is improving healthcare';
      String expectedFormattedSentence = 'Bewell Is Improving Healthcare';
      String actualTitleCasedString = SILMisc.titleCase(sentence);
      expect(actualTitleCasedString, expectedFormattedSentence);

      // check if it formats a spaced string
      sentence = 'kowalski    analysis';
      expectedFormattedSentence = 'Kowalski    Analysis';
      actualTitleCasedString = SILMisc.titleCase(sentence);
      expect(actualTitleCasedString, expectedFormattedSentence);

      // check if it returns an empty string if the sentence is empty
      sentence = '';
      expectedFormattedSentence = '';
      actualTitleCasedString = SILMisc.titleCase(sentence);
      expect(actualTitleCasedString, expectedFormattedSentence);
    });

    test('should return the correct greeting message', () {
      const int morningHour = 11;
      const int afternoonHour = 15;
      const int eveningHour = 20;
      const String firstName = 'coverage';

      String greetingMessage =
          SILMisc.getGreetingMessage(firstName, currentHour: morningHour);

      expect(greetingMessage, isA<String>());
      expect(greetingMessage.contains('Morning'), true);
      expect(greetingMessage.contains(firstName), true);

      greetingMessage =
          SILMisc.getGreetingMessage(firstName, currentHour: afternoonHour);
      expect(greetingMessage, isA<String>());
      expect(greetingMessage.contains('Afternoon'), true);
      expect(greetingMessage.contains(firstName), true);

      greetingMessage =
          SILMisc.getGreetingMessage(firstName, currentHour: eveningHour);
      expect(greetingMessage, isA<String>());
      expect(greetingMessage.contains('Evening'), true);
      expect(greetingMessage.contains(firstName), true);
    });

    test('should test phone Number not starting with a + ', () {
      final String formatedNumber =
          SILMisc.formatPhoneNumber(countryCode: '254', phoneNumber: '1234567');
      const String expectedNumber = '+2541234567';
      expect(formatedNumber, expectedNumber);
    });
    test('should test if the phone number begins with +1', () {
      final String formatedNumber =
          SILMisc.formatPhoneNumber(countryCode: '+1', phoneNumber: '2345678');
      const String expectedNumber = '+12345678';
      expect(formatedNumber, expectedNumber);
    });
    test('should test if a phone number begins with 0', () {
      final String formatedNumber = SILMisc.formatPhoneNumber(
          phoneNumber: '01234567', countryCode: '254');
      const String expectedNumber = '+2541234567';
      expect(formatedNumber, expectedNumber);
    });
    test('should test other phone number', () {
      final String formatedNumber = SILMisc.formatPhoneNumber(
          phoneNumber: '1234567', countryCode: '+255');
      const String expectedNumber = '+2551234567';
      expect(formatedNumber, expectedNumber);
    });

    test('should test background gradient', () {
      final LinearGradient backgroundGradient = SILMisc.backgroundGradient(
        primaryColor: 0xFF7949AF,
        primaryLinearGradientColor: 0xFF7949AF,
      );
      expect(backgroundGradient, isA<LinearGradient>());
      expect(backgroundGradient.begin, Alignment.topLeft);
      expect(backgroundGradient.end, Alignment.bottomRight);
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

        expect(SILMisc.validatePhoneNumber(kenyanNumber), true);
        expect(SILMisc.validatePhoneNumber(usNumber), true);
      });

      test('should return invalid phone number', () {
       const String testPhone = '+2123456789';

        expect(SILMisc.validatePhoneNumber(testPhone), false);
      });
    });

    group('RefreshTokenManger', () {
     final BehaviorSubject<dynamic> listen = BehaviorSubject<dynamic>();
      test('should updateExpireTime', () {
       const String time = '2021-02-01 10:15:21Z';
        RefreshTokenManger().updateExpireTime(time);
        RefreshTokenManger().updateExpireTime(time).reset();
        expect(listen.valueWrapper, null);
      });

      test('should reset 6 minutes to the expiry time', () {
       final String approachingCurrentTime =
            DateTime.now().add(const Duration(minutes: 6)).toString();

        RefreshTokenManger().checkExpireValidity(approachingCurrentTime);
        expect(RefreshTokenManger().checkExpireValidity(approachingCurrentTime),
            true);

        //Set expiry time
        RefreshTokenManger().updateExpireTime(approachingCurrentTime);
        //Reset expiry time
        RefreshTokenManger().updateExpireTime(approachingCurrentTime).reset();

        expect(listen.valueWrapper, null);
      });

      test('should reset 15 minutes to the expiry time', () {
       final String expiryTime =
            DateTime.now().add(const Duration(minutes: 15)).toString();

        //Reset expiry time
        RefreshTokenManger().updateExpireTime(expiryTime).reset();

        expect(listen.valueWrapper, null);
      });
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/sil_misc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('SILMisc', () {
    test('convertDateToString should return correctly formatted date', () {
      DateTime date = DateTime(2020, DateTime.january, 31);
      String expected = '31-01-2020';
      String formattedDate =
          SILMisc.convertDateToString(date: date, format: 'dd-MM-yyyy');

      expect(formattedDate, expected);
    });

    test('test extract name initials', () {
      expect('DD', SILMisc.extractNamesIntials(name: 'david dexter'));
      expect('MV', SILMisc.extractNamesIntials(name: 'Michuki vincent'));
      expect('dd',
          isNot(SILMisc.extractNamesIntials(name: 'david dexter mwangi')));
    });

    test('convertStringToDate should return correct date', () {
      String stringDate = '03-02-2020';
      DateTime expectedDate = DateTime(2020, DateTime.february, 3);

      DateTime convertedDate = SILMisc.convertStringToDate(
        format: 'dd-MM-yyyy',
        dateTimeString: stringDate,
      );

      expect(convertedDate, expectedDate);
    });

    test('should format currency as a integer', () {
      // setup
      final int currency = 200;
      final String expectedFormattedCurrency = '200';

      // call the actual method
      String actualFormattedCurrency = SILMisc.formatCurrency(currency);

      // verify functionality
      expect(actualFormattedCurrency, isNotNull);
      expect(actualFormattedCurrency, isA<String>());
      expect(actualFormattedCurrency, expectedFormattedCurrency);
    });

    test('should format currency as a double', () {
      // setup
      final double currency = 200.55;
      final String expectedFormattedCurrency = '201';

      // call the actual method
      String actualFormattedCurrency = SILMisc.formatCurrency(currency);

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
      final String expectedFormattedCurrency = '0';

      // call the actual method
      String actualFormattedCurrency = SILMisc.formatCurrency(currency);

      // verify functionality
      expect(actualFormattedCurrency, isNotNull);
      expect(actualFormattedCurrency, isA<String>());
      expect(actualFormattedCurrency, expectedFormattedCurrency);

      expect(actualFormattedCurrency.contains('0'), true);
    });

    test('should validate email', () {
      // setup
      final String validEmail = 'a@a.com';
      final String valiedDomainEmail = 'test@coverage.sil';
      final String invalidEmail = 'wrongemail.comn';

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
      final String validTo = '2021-08-01';
      final String formattedValidTo = SILMisc.getCoverValidityPeriod(validTo);
      expect(formattedValidTo, isA<String>());
    });

    test('should get cover validity date', () {
      final String validTo = '2021-08-01';
      final String expectedValidity = 'Till Aug 01, 2021';
      final String formattedValidTo = SILMisc.getValidityDate(validTo);
      expect(formattedValidTo, isA<String>());
      expect(formattedValidTo, expectedValidity);
    });

    test('should parse auth types', () {
      final List<String> authTypes = <String>['OTP', 'Fingerprint'];
      final String expectedAuthTypes = 'OTP & Fingerprint ';
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
      final int morningHour = 11;
      final int afternoonHour = 15;
      final int eveningHour = 20;
      final String firstName = 'coverage';

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
      final String expectedNumber = '+2541234567';
      expect(formatedNumber, expectedNumber);
    });
    test('should test if the phone number begins with +1', () {
      final String formatedNumber =
          SILMisc.formatPhoneNumber(countryCode: '+1', phoneNumber: '2345678');
      final String expectedNumber = '+12345678';
      expect(formatedNumber, expectedNumber);
    });
    test('should test if a phone number begins with 0', () {
      final String formatedNumber = SILMisc.formatPhoneNumber(
          phoneNumber: '01234567', countryCode: '254');
      final String expectedNumber = '+2541234567';
      expect(formatedNumber, expectedNumber);
    });
    test('should test other phone number', () {
      final String formatedNumber = SILMisc.formatPhoneNumber(
          phoneNumber: '1234567', countryCode: '+255');
      final String expectedNumber = '+2551234567';
      expect(formatedNumber, expectedNumber);
    });
  });
}

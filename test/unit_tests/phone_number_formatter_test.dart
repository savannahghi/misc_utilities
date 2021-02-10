import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/utils/phone_number_formatter.dart';

void main() {
  String usNumber = '+12025550163';
  String usNumberFormated = '(+1) 202-5550163';

  String keNumber = '+254776259035';
  String keNumberFormated = '(+254) 776-259035';

//Us phone test
  test('US phone format test', () {
    expect(formatPhoneNumber(usNumber), usNumberFormated);
  });

//ke phone test
  test('KE phone format test', () {
    expect(formatPhoneNumber(keNumber), keNumberFormated);
  });
}

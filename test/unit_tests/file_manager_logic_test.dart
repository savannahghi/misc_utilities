import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/src/file_manager_logic.dart';

import '../mocks.dart';

void main() {
  test('FileManagerLogic should extract file metadata as a Map', () {
    final File file = File(testPath('test_resources/test_file.png'));

    final Map<String, dynamic> fileData =
        FileManagerLogic.getFileData(file: file, fileTitle: 'Test file');

    expect(fileData, isA<Map<String, dynamic>>());
    expect(fileData.containsKey('title'), true);
    expect(fileData['title'], 'Test file');

    expect(fileData['contentType'], 'PNG');
    expect(fileData['language'], 'en');
  });
}

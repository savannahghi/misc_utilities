import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:misc_utilities/src/file_manager_logic.dart';
import 'package:misc_utilities/src/string_constant.dart';
import 'package:shared_themes/constants.dart';

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FileManagerLogic', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/image_picker');

    testWidgets(
      'should select a file and upload it successfully',
      (WidgetTester tester) async {
        final List<MethodCall> _methodCalls = <MethodCall>[];

        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          _methodCalls.add(methodCall);

          final File file = File(testPath('test_resources/test_file.png'));
          return file.path;
        });

        late File uploadedFile;
        late String uploadedUploadId;
        int wasToggleUiCalled = 0;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(builder: (BuildContext context) {
              return GestureDetector(
                onTap: () async {
                  await FileManagerLogic.selectFileFromGallery(
                    context: context,
                    uploadAndReturnIdFunction: (
                        {required BuildContext context,
                        required Map<String, dynamic> fileData}) async {
                      return 'sample-upload-id';
                    },
                    toggleUpload: () {
                      wasToggleUiCalled = wasToggleUiCalled + 1;
                    },
                    fileTitle: 'Test',
                    updateUIFunc: (File file, String uploadId) {
                      uploadedFile = file;
                      uploadedUploadId = uploadId;
                    },
                  );
                },
              );
            }),
          ),
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        expect(_methodCalls.length, 1);
        expect(
          _methodCalls.first,
          isMethodCall(
            'pickImage',
            arguments: <String, dynamic>{
              'source': 1,
              'maxWidth': null,
              'maxHeight': null,
              'imageQuality': 50,
              'cameraDevice': 0,
              'requestFullMetadata': true
            },
          ),
        );
        expect(uploadedFile.lengthSync(), 70);
        expect(uploadedUploadId, 'sample-upload-id');

        // verify UI was updated twice
        expect(wasToggleUiCalled, 2);
      },
    );

    testWidgets(
      'should show a no file selected alert when the user cancels '
      'the file selection',
      (WidgetTester tester) async {
        final List<MethodCall> _methodCalls = <MethodCall>[];

        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          _methodCalls.add(methodCall);

          return null;
        });

        int wasToggleUiCalled = 0;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(builder: (BuildContext context) {
              return GestureDetector(
                onTap: () async {
                  await FileManagerLogic.selectFileFromGallery(
                    context: context,
                    uploadAndReturnIdFunction: (
                        {required BuildContext context,
                        required Map<String, dynamic> fileData}) async {
                      return 'sample-upload-id';
                    },
                    toggleUpload: () {
                      wasToggleUiCalled = wasToggleUiCalled + 1;
                    },
                    fileTitle: 'Test',
                    updateUIFunc: (File file, String uploadId) {},
                  );
                },
              );
            }),
          ),
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        expect(_methodCalls.length, 1);
        expect(
          _methodCalls.last,
          isMethodCall(
            'pickImage',
            arguments: <String, dynamic>{
              'source': 1,
              'maxWidth': null,
              'maxHeight': null,
              'imageQuality': 50,
              'cameraDevice': 0,
              'requestFullMetadata': true
            },
          ),
        );

        // verify UI was updated twice
        expect(wasToggleUiCalled, 0);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(UserFeedBackTexts.noFileSelected), findsOneWidget);
      },
    );

    testWidgets(
      'should show an alert when the selected file fails to upload',
      (WidgetTester tester) async {
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          final File file = File(testPath('test_resources/test_file.png'));
          return file.path;
        });
        int wasToggleUiCalled = 0;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(builder: (BuildContext context) {
              return GestureDetector(
                onTap: () async {
                  await FileManagerLogic.selectFileFromGallery(
                    context: context,
                    uploadAndReturnIdFunction: (
                        {required BuildContext context,
                        required Map<String, dynamic> fileData}) async {
                      return 'err';
                    },
                    toggleUpload: () {
                      wasToggleUiCalled = wasToggleUiCalled + 1;
                    },
                    fileTitle: 'Test',
                    updateUIFunc: (File file, String uploadId) {},
                  );
                },
              );
            }),
          ),
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(UserFeedBackTexts.uploadFileFail), findsOneWidget);
      },
    );

    testWidgets(
      'should show an alert when the selected file is too large',
      (WidgetTester tester) async {
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          final File file =
              File(testPath('test_resources/very_large_test_file.jpg'));
          return file.path;
        });
        int wasToggleUiCalled = 0;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(builder: (BuildContext context) {
              return GestureDetector(
                onTap: () async {
                  await FileManagerLogic.selectFileFromGallery(
                    context: context,
                    uploadAndReturnIdFunction: (
                        {required BuildContext context,
                        required Map<String, dynamic> fileData}) async {
                      return 'err';
                    },
                    toggleUpload: () {
                      wasToggleUiCalled = wasToggleUiCalled + 1;
                    },
                    fileTitle: 'Test',
                    updateUIFunc: (File file, String uploadId) {},
                  );
                },
              );
            }),
          ),
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(tooLargeImageError), findsOneWidget);
      },
    );

    testWidgets(
      'should show an alert when image picker fails to get an image with an error',
      (WidgetTester tester) async {
        int wasToggleUiCalled = 0;

        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          throw Exception('File is not available');
        });

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(builder: (BuildContext context) {
              return GestureDetector(
                onTap: () async {
                  await FileManagerLogic.selectFileFromGallery(
                    context: context,
                    uploadAndReturnIdFunction: (
                        {required BuildContext context,
                        required Map<String, dynamic> fileData}) async {
                      return 'err';
                    },
                    toggleUpload: () {
                      wasToggleUiCalled = wasToggleUiCalled + 1;
                    },
                    fileTitle: 'Test',
                    updateUIFunc: (File file, String uploadId) {},
                  );
                },
              );
            }),
          ),
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(UserFeedBackTexts.selectFileError), findsOneWidget);
      },
    );
  });
}

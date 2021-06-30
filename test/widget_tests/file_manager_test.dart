import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:app_wrapper/app_wrapper.dart';

import 'package:misc_utilities/src/file_manager.dart';
import 'package:misc_utilities/src/file_manager_logic.dart';
import 'package:misc_utilities/src/widget_keys.dart';
import 'package:shared_themes/constants.dart';

import '../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/image_picker');

  group('FileManagerLogic', () {
    testWidgets(
      'Should upload file correctly and return the upload ID',
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
            },
          ),
        );
        expect(uploadedFile.lengthSync(), 70);
        expect(uploadedUploadId, 'sample-upload-id');

        // verify UI was updated twice
        expect(wasToggleUiCalled, 2);
      },
    );
  });

  group('SILFileManager', () {
    testWidgets(
      'should upload file correctly and clear the selection'
      ' after a successful upload',
      (WidgetTester tester) async {
        final List<MethodCall> _methodCalls = <MethodCall>[];

        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();

        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          _methodCalls.add(methodCall);

          final File file = File(testPath('test_resources/test_file.png'));
          return file.path;
        });

        late dynamic uploadedID;
        late Map<String, dynamic>? uploadedFileData;

        await tester.pumpWidget(
          SILAppWrapperBase(
            appContexts: const <AppContext>[AppContext.AppTest],
            appName: 'Test app',
            graphQLClient: mockSILGraphQlClient,
            deviceCapabilities: DeviceCapabilities(),
            child: MaterialApp(
              home: Scaffold(
                body: SILFileManager(
                  onChanged: (dynamic value) {
                    uploadedID = value;
                  },
                  fileTitle: 'name',
                  uploadAndReturnIdFunction: (
                      {BuildContext? context,
                      Map<String, dynamic>? fileData}) async {
                    uploadedFileData = fileData;
                    return 'some-upload-id';
                  },
                  platformLoader: const CircularProgressIndicator(),
                  isRequired: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final Finder galleryIcon = find.byKey(galleryImageKey);

        expect(find.byType(SILFileManager), findsOneWidget);
        expect(find.byType(DottedBorder), findsOneWidget);
        expect(find.byType(SILFileManager), findsOneWidget);
        expect(galleryIcon, findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.tap(galleryIcon);
        await tester.pumpAndSettle();

        // verify that the upload was done
        expect(uploadedID, 'some-upload-id');
        expect(uploadedFileData, isNotNull);
        expect(uploadedFileData, isA<Map<String, dynamic>>());
        expect(uploadedFileData!.containsKey('base64data'), true);
        expect(uploadedFileData!['filename'], 'test_file.png');

        // verify the required text is shown
        expect(find.text('This is required *'), findsOneWidget);

        // verify the close GestureDetector is present
        expect(find.byIcon(MdiIcons.closeCircle), findsOneWidget);
        expect(find.byKey(closeSelectedFile), findsOneWidget);

        // tap the close icon which will reset the file to none
        await tester.tap(find.byKey(closeSelectedFile));
        await tester.pump();

        // verify the file selection was cleared
        expect(find.byIcon(MdiIcons.closeCircle), findsNothing);
        expect(find.byKey(closeSelectedFile), findsNothing);

        // verify the select button is present
        expect(galleryIcon, findsOneWidget);
      },
    );

    testWidgets(
      'Image picker should show a CircularProgressIndicator when an upload is '
      'being done',
      (WidgetTester tester) async {
        final List<MethodCall> _methodCalls = <MethodCall>[];

        channel.setMockMethodCallHandler((MethodCall methodCall) async {
          _methodCalls.add(methodCall);

          final File file = File(testPath('test_resources/test_file.png'));
          return file.path;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SILFileManager(
                onChanged: (dynamic value) {},
                fileTitle: 'name',
                uploadAndReturnIdFunction: (
                    {BuildContext? context,
                    Map<String, dynamic>? fileData}) async {
                  return Future<void>.delayed(const Duration(seconds: 1))
                      .then((_) => 'some-upload-id');
                },
                platformLoader: const CircularProgressIndicator(),
                isRequired: true,
              ),
            ),
          ),
        );

        await tester.pump();

        final Finder galleryIcon = find.byKey(galleryImageKey);

        expect(find.byType(SILFileManager), findsOneWidget);
        expect(find.byType(DottedBorder), findsOneWidget);
        expect(find.byType(SILFileManager), findsOneWidget);
        expect(galleryIcon, findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.tap(galleryIcon);

        // this will delay the upload long enough for us to catch the
        // [CircularProgressIndicator] in action
        await tester.pump(const Duration(milliseconds: 200));

        // verify the select button is present
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text(UserFeedBackTexts.savingFile), findsOneWidget);

        // this will flush out any remaining timers
        await tester.pumpAndSettle();
      },
    );
  });
}

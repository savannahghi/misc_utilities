import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sil_app_wrapper/models/enums/enums.dart';
import 'package:sil_app_wrapper/sil_app_wrapper_base.dart';
import 'package:sil_misc/sil_bottom_sheet_builder.dart';
import 'package:sil_misc/sil_event_bus.dart';
import 'package:sil_misc/sil_misc.dart';
import 'package:sil_misc/sil_enums.dart';
import 'package:sil_misc/sil_mutations.dart';
import 'package:sil_themes/constants.dart';
import 'package:sil_themes/spaces.dart';

import 'package:sil_ui_components/sil_buttons.dart';
import 'package:sil_ui_components/sil_comms_setting.dart';

import '../mocks.dart';

class TestComplexBottomSheet extends SILBottomSheetBuilder {
  TestComplexBottomSheet()
      : super(
          primaryColor: Colors.amber,
          textColor: Colors.amberAccent,
          backgroundColor: Colors.black,
          action: () => true,
          message: 'test message',
          showSecondaryButton: true
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shrinkWrap: true,
        children: <Widget>[
          Align(
            child: Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          mediumVerticalSizedBox,
          Column(
            children: <Widget>[
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Theme.of(context).backgroundColor,
                child: const Icon(Icons.ac_unit),
              ),
              mediumVerticalSizedBox,
              Padding(
                padding: veryLargeHorizontalPadding,
                child: Text(
                  this.message!,
                  textAlign: TextAlign.center,
                ),
              ),
              mediumVerticalSizedBox,
              if (primaryActionCallback != null)
                Container(
                  padding: veryLargeHorizontalPadding,
                  width: double.infinity,
                  child: SILPrimaryButton(
                      buttonColor: buttonColor,
                      borderColor: borderColor,
                      customPadding: customPadding,
                      text: primaryActionText ?? 'Complete',
                      onPressed: primaryActionCallback),
                ),
              smallVerticalSizedBox,
              if (showSecondaryButton! || secondaryActionCallback != null)
                Container(
                  padding: veryLargeHorizontalPadding,
                  width: double.infinity,
                  child: SILSecondaryButton(
                    buttonColor: buttonColor,
                    borderColor: borderColor,
                    customPadding: customPadding,
                    text: secondaryActionText ?? 'Close',
                    addBorder: true,
                    textColor: buttonColor ?? Theme.of(context).accentColor,
                    onPressed: secondaryActionCallback ??
                        () {
                          Navigator.pop(context);
                        },
                  ),
                ),
              smallVerticalSizedBox,
              if (tertiaryActionCallback != null)
                Container(
                  padding: veryLargeHorizontalPadding,
                  width: double.infinity,
                  child: SILNoBorderButton(
                    text: tertiaryActionText ?? 'Complete',
                    onPressed: tertiaryActionCallback,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  group('SILMisc', () {
    testWidgets('should show snackbar and dismiss it',
        (WidgetTester tester) async {
      bool isSnackBarActionTapped = false;
      final SnackBar snackBar = snackbar(
          content: 'Sample snackbar',
          durationSeconds: 1,
          label: 'Snackbar',
          callback: () {
            isSnackBarActionTapped = true;
          });
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(builder: (BuildContext context) {
              return ElevatedButton(
                key: const Key('show_snackbar_button'),
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                },
                child: const Text('Show Snackbar'),
              );
            }),
          ),
        ),
      ));

      // check that the UI is loaded
      expect(find.byKey(const Key('show_snackbar_button')), findsOneWidget);
      expect(find.text('Show Snackbar'), findsOneWidget);

      // tap the button to show the snackbar
      await tester.tap(find.byKey(const Key('show_snackbar_button')));
      await tester.pumpAndSettle();

      // confirm the snackbar was loaded
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(SnackBarAction), findsOneWidget);

      // check that the snackbar is still available
      expect(isSnackBarActionTapped, false);

      // tap the close action on the snackbar
      await tester.tap(find.byType(SnackBarAction));
      await tester.pumpAndSettle();

      expect(isSnackBarActionTapped, true);
    });

    testWidgets('should show error snackbar', (WidgetTester tester) async {
      const Key snackbarKey = Key('show_error_snackbar');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(builder: (BuildContext context) {
              return ElevatedButton(
                  key: snackbarKey,
                  onPressed: () {
                    showErrorSnackbar(context, 'An error occured');
                  },
                  child: const SizedBox());
            }),
          ),
        ),
      ));
      expect(find.byKey(snackbarKey), findsOneWidget);
      await tester.tap(find.byKey(snackbarKey));
      await tester.pumpAndSettle();
      expect(find.text('An error occured'), findsOneWidget);
    });
    testWidgets('should show error snackbar with default error message',
        (WidgetTester tester) async {
      const Key snackbarKey = Key('show_error_snackbar');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(builder: (BuildContext context) {
              return ElevatedButton(
                  key: snackbarKey,
                  onPressed: () {
                    showErrorSnackbar(context);
                  },
                  child: const SizedBox());
            }),
          ),
        ),
      ));
      expect(find.byKey(snackbarKey), findsOneWidget);
      await tester.tap(find.byKey(snackbarKey));
      await tester.pumpAndSettle();
      expect(
          find.text('Sorry, an error occurred. Please try again,'
              ' or contact Slade 360 Be.Well Support support'
              ' on $kBewellSupportPhoneNumber'),
          findsOneWidget);
    });

    group('bottomsheet', () {
      testWidgets('should render correctly without action',
          (WidgetTester tester) async {
        const Key launchBottomSheetKey = Key('button_key');

        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            return TextButton(
              key: launchBottomSheetKey,
              onPressed: () {
                bottomSheet(
                    context: context, builder: TestComplexBottomSheet());
              },
              child: const Text('text button'),
            );
          }),
        ));

        await tester.pumpAndSettle();
        await tester.tap(find.byKey(launchBottomSheetKey));
        await tester.pumpAndSettle();

        final Finder bottomSheetClass = find.byType(ListView);
        expect(bottomSheetClass, findsOneWidget);
      });
    });

    group('SILEventBus', () {
      testWidgets('should test SILEventBus', (WidgetTester tester) async {
        final SILEventBus eventBus = SILEventBus();
        final Map<String, dynamic> eventPayload = <String, dynamic>{
          'test': 'test'
        };
        final Stream<dynamic> stream = eventBus.streamController.stream;
        eventBus.fire(TriggeredEvent('TEST_EVENT', eventPayload));
        // ignore: unawaited_futures
        expectLater(stream, emits('Here is an event'));

        eventBus.streamController.add('Here is an event');
      });
    });

    group('customRoundedPinBoxDecoration', () {
      testWidgets('should render correctly', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            return Material(
                child: Container(
              key: const Key('test'),
              decoration:
                  customRoundedPinBoxDecoration(Colors.black, Colors.black),
            ));
          }),
        ));

        await tester.pumpAndSettle();
        expect(
          tester.widget(find.byType(Container)),
          isA<Container>().having((Container t) => t.decoration, 'decoration',
              customRoundedPinBoxDecoration(Colors.black, Colors.black)),
        );
      });
    });

    group('communication settings', () {
      testWidgets('changeCommunicationSetting works correctly',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        final Map<String, bool> settings = settingsVariables;
        final Map<String, bool> _variables = <String, bool>{
          'allowEmail': settings['allowEmail']!,
          'allowWhatsApp': settings['allowWhatsApp']!,
          'allowTextSMS': settings['allowText']!,
          'allowPush': settings['allowPush']!,
        };
        dynamic commSettings(
            {required Map<String, bool> communicationSettings}) {
          return _variables;
        }

        bool? response;
        await tester.pumpWidget(Builder(
          builder: (BuildContext context) {
            return MaterialApp(
              home: SILAppWrapperBase(
                appName: 'testAppName',
                appContexts: const <AppContext>[AppContext.BewellCONSUMER],
                graphQLClient: mockSILGraphQlClient,
                deviceCapabilities: MockDeviceCapabilities(),
                child: Scaffold(
                  body: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints box) {
                    return SILPrimaryButton(
                      onPressed: () async {
                        response = await changeCommunicationSetting(
                            context: context,
                            channel: CommunicationType.allowEmail,
                            isAllowed: true,
                            settings: settings,
                            communicationSettingsFunc: commSettings);
                      },
                      text: 'Add',
                    );
                  }),
                ),
              ),
            );
          },
        ));

        await tester.pumpAndSettle();

        expect(find.byType(SILPrimaryButton), findsOneWidget);
        await tester.tap(find.byType(SILPrimaryButton));
        await tester.pumpAndSettle();

        expect(response, true);
      });
    });
    group('set up user experiment', () {
      testWidgets('should add user as experiment participant',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        bool response = false;
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              appName: '',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              deviceCapabilities: MockDeviceCapabilities(),
              child: Builder(builder: (BuildContext context) {
                return Center(
                  child: SILPrimaryButton(
                    buttonKey: const Key('add_experiment_participant'),
                    onPressed: () async {
                      response = (await setupAsExperimentParticipant(
                          context: context, participate: true))!;
                    },
                  ),
                );
              }),
            ),
          ),
        ));

        expect(find.byType(SILAppWrapperBase), findsOneWidget);
        expect(find.byType(SILPrimaryButton), findsOneWidget);

        expect(find.byKey(const Key('add_experiment_participant')),
            findsOneWidget);
        expect(response, false);

        // tap the button to show the toast
        await tester.tap(find.byKey(const Key('add_experiment_participant')));

        expect(response, true);
      });

      testWidgets('should remove user as experiment participant',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        bool response = false;
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              appName: '',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              deviceCapabilities: MockDeviceCapabilities(),
              graphQLClient: mockSILGraphQlClient,
              child: Builder(builder: (BuildContext context) {
                return Center(
                  child: SILPrimaryButton(
                    buttonKey: const Key('add_experiment_participant'),
                    onPressed: () async {
                      response = (await setupAsExperimentParticipant(
                        context: context,
                      ))!;
                    },
                  ),
                );
              }),
            ),
          ),
        ));

        expect(find.byType(SILAppWrapperBase), findsOneWidget);
        expect(find.byType(SILPrimaryButton), findsOneWidget);

        expect(find.byKey(const Key('add_experiment_participant')),
            findsOneWidget);
        expect(response, false);

        // tap the button to show the toast
        await tester.tap(find.byKey(const Key('add_experiment_participant')));
        expect(response, true);
      });
    });

    group('upload ID', () {
      testWidgets('should getUploadId and return a string',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        String uploadID = 'YHBDhbkGHGFzgh';
        final Map<String, dynamic> fileData = <String, dynamic>{
          'contentType': 'jpg',
          'title': 'test',
          'base64data': 'test'
        };
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('get_upload_id'),
                      onPressed: () async {
                        uploadID = (await getUploadId(
                          fileData: fileData,
                          context: context,
                        ))!;
                      });
                }),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('get_upload_id')));
        await tester.pumpAndSettle();
        expect(uploadID, 'uploadID');
      });
    });

    group('generic fetch function', () {
      testWidgets('should get data', (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        final StreamController<dynamic> _streamController =
            StreamController<dynamic>.broadcast();
        final Map<String, bool> variables = <String, bool>{
          'participate': false
        };

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('fetch_data'),
                      onPressed: () async {
                        await genericFetchFunction(
                            streamController: _streamController,
                            context: context,
                            queryString: setupUserAsExperimentParticipant,
                            variables: variables,
                            logTitle: 'logTitle');
                      });
                }),
              ),
            ),
          ),
        ));
        await tester.pump();

        await tester.pumpAndSettle();

        await tester.tap(find.byType(SILPrimaryButton));
        await tester.pumpAndSettle();

        await _streamController.close();
      });

      testWidgets('should add error to streamcontroller when statuscode= 408',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        final StreamController<dynamic> _streamControllers =
            StreamController<dynamic>.broadcast();
        final Map<String, bool> userData = <String, bool>{
          'allowWhatsApp': true,
          'allowPush': false,
          'allowEmail': true,
          'allowTextSMS': true
        };

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('fetch_data'),
                      onPressed: () async {
                        await genericFetchFunction(
                            streamController: _streamControllers,
                            context: context,
                            queryString: updateUserData,
                            variables: userData,
                            logTitle: 'logTitle');
                      });
                }),
              ),
            ),
          ),
        ));
        await tester.pump();

        await tester.pumpAndSettle();

        await tester.tap(find.byType(SILPrimaryButton));
        await tester.pumpAndSettle();

        await _streamControllers.close();
      });

      testWidgets('should add error to streamcontroller when there is an error',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        final StreamController<dynamic> _controller =
            StreamController<dynamic>.broadcast();
        final Map<String, bool> userProfile = <String, bool>{
          'allowWhatsApp': true,
          'allowPush': false,
          'allowEmail': true,
          'allowTextSMS': true
        };

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('fetch_data'),
                      onPressed: () async {
                        await genericFetchFunction(
                            streamController: _controller,
                            context: context,
                            queryString: updateUserProfile,
                            variables: userProfile,
                            logTitle: 'logTitle');
                      });
                }),
              ),
            ),
          ),
        ));
        await tester.pump();

        await tester.pumpAndSettle();

        await tester.tap(find.byType(SILPrimaryButton));
        await tester.pumpAndSettle();

        await _controller.close();
      });
    });

    group('launch whatsapp', () {
      testWidgets('should launch whatsapp', (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        const String phone = '0710000000';
        const String message = 'hi';

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () async {
                        (await launchWhatsApp(phone: phone, message: message))!;
                      });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();
      });

      testWidgets('should not launch whatsapp', (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        const String phone = '';
        const String message = '';

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () async {
                        (await launchWhatsApp(phone: phone, message: message))!;
                      });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();
      });
    });

    group('User inactivity status ', () {
      testWidgets('shoul be okey when inActivitySetInTime is null',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();

        const String inActivitySetInTime = '';
        const String expiresAt = '';

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () => <UserInactivityStatus>{
                            (checkInactivityTime(
                                inActivitySetInTime, expiresAt))
                          });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();

        expect(UserInactivityStatus.okey, UserInactivityStatus.okey);
      });

      testWidgets('should be requires login when lastActivityTime is null',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();

        const String inActivitySetInTime = ' 20:18:04Z:1969-07-20';
        const String expiresAt = '';

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () => <UserInactivityStatus>{
                            (checkInactivityTime(
                                inActivitySetInTime, expiresAt))
                          });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();

        expect(UserInactivityStatus.requiresLogin,
            UserInactivityStatus.requiresLogin);
      });

      testWidgets('should be requires login when lastActivityTime is null',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();

        const String inActivitySetInTime = ' 20:18:04Z:1969-07-20';
        const String expiresAt = '';

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () => <UserInactivityStatus>{
                            (checkInactivityTime(
                                inActivitySetInTime, expiresAt))
                          });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();

        expect(UserInactivityStatus.requiresLogin,
            UserInactivityStatus.requiresLogin);
      });

      testWidgets('should be requiresPin when tokenAge <-5',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();

        final String inActivitySetInTime = DateTime.now().toString();
        final String expiresAt = DateTime.now().toString();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () => <UserInactivityStatus>{
                            (checkInactivityTime(
                                inActivitySetInTime, expiresAt))
                          });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();

        expect(
            UserInactivityStatus.requiresPin, UserInactivityStatus.requiresPin);
      });

      testWidgets('should be okey when tokenAge >-5',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        final DateTime tokenAge = DateTime.now().subtract(const Duration(
          minutes: 5,
        ));
        final String inActivitySetInTime = DateTime.now().toString();
        final String expiresAt = tokenAge.toString();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () => <UserInactivityStatus>{
                            (checkInactivityTime(
                                inActivitySetInTime, expiresAt))
                          });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();

        expect(UserInactivityStatus.okey, UserInactivityStatus.okey);
      });

      testWidgets('should be requiresPin when timeDiff >12',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        final DateTime timeDiff =
            DateTime.now().subtract(const Duration(minutes: 5, days: 5));
        final String inActivitySetInTime = timeDiff.toString();
        const String expiresAt = '';

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () => <UserInactivityStatus>{
                            (checkInactivityTime(
                                inActivitySetInTime, expiresAt))
                          });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();

        expect(UserInactivityStatus.requiresLogin,
            UserInactivityStatus.requiresLogin);
      });

      testWidgets('should be requiresPin when timeDiff >1 and <12',
          (WidgetTester tester) async {
        final MockSILGraphQlClient mockSILGraphQlClient =
            MockSILGraphQlClient();
        final DateTime timeDiff =
            DateTime.now().subtract(const Duration(minutes: 5, hours: 5));
        final String inActivitySetInTime = timeDiff.toString();
        const String expiresAt = '';

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SILAppWrapperBase(
              deviceCapabilities: MockDeviceCapabilities(),
              appName: 'testAppName',
              appContexts: const <AppContext>[AppContext.BewellCONSUMER],
              graphQLClient: mockSILGraphQlClient,
              child: Center(
                child: Builder(builder: (BuildContext context) {
                  return SILPrimaryButton(
                      buttonKey: const Key('launch'),
                      onPressed: () => <UserInactivityStatus>{
                            (checkInactivityTime(
                                inActivitySetInTime, expiresAt))
                          });
                }),
              ),
            ),
          ),
        ));

        await tester.pump();

        await tester.tap(find.byKey(const Key('launch')));
        await tester.pumpAndSettle();

        expect(
            UserInactivityStatus.requiresPin, UserInactivityStatus.requiresPin);
      });

      testWidgets('should show dismiss snackbar', (WidgetTester tester) async {
        const Key snackbarKey = Key('show_dismiss_snackbar');
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(builder: (BuildContext context) {
                return ElevatedButton(
                    key: snackbarKey,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('done'),
                          action: dismissSnackBar(
                              'An error occured', Colors.amber, context)));
                    },
                    child: const SizedBox());
              }),
            ),
          ),
        ));
        expect(find.byKey(snackbarKey), findsOneWidget);

        await tester.tap(find.byKey(snackbarKey));
        await tester.pumpAndSettle();
        expect(find.text('done'), findsOneWidget);
        expect(find.text('An error occured'), findsOneWidget);
        expect(find.byType(SnackBarAction), findsOneWidget);

        await tester.tap(find.byType(SnackBarAction));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBarAction), findsNothing);
      });
    });

    group('DeviceType', () {
      testWidgets('should return Tablet', (WidgetTester tester) async {
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        tester.binding.window.physicalSizeTestValue = tabletLandscape;

        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            expect(getDeviceType(context), DeviceScreensType.Tablet);

            return Material(child: Container());
          }),
        ));

        addTearDown(() {
          tester.binding.window.clearPhysicalSizeTestValue();
          tester.binding.window.clearDevicePixelRatioTestValue();
        });
      });

      testWidgets('should return Mobile', (WidgetTester tester) async {
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        tester.binding.window.physicalSizeTestValue =
            typicalPhoneScreenSizePortrait;

        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            expect(getDeviceType(context), DeviceScreensType.Mobile);

            return Material(child: Container());
          }),
        ));

        addTearDown(() {
          tester.binding.window.clearPhysicalSizeTestValue();
          tester.binding.window.clearDevicePixelRatioTestValue();
        });
      });
    });
  });
}

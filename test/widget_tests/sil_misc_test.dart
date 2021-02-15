import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/sil_misc.dart';
import 'package:sil_misc/utils/widget_keys.dart';

void main() {
  group('SILMisc', () {
    testWidgets('should show snackbar and dismiss it',
        (WidgetTester tester) async {
      bool isSnackBarActionTapped = false;
      SnackBar snackBar = SILMisc.snackbar(
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
              return RaisedButton(
                key: Key('show_snackbar_button'),
                onPressed: () {
                  Scaffold.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                },
                child: Text('Show Snackbar'),
              );
            }),
          ),
        ),
      ));

      // check that the UI is loaded
      expect(find.byKey(Key('show_snackbar_button')), findsOneWidget);
      expect(find.text('Show Snackbar'), findsOneWidget);

      // tap the button to show the snackbar
      await tester.tap(find.byKey(Key('show_snackbar_button')));
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
              return RaisedButton(
                key: snackbarKey,
                onPressed: () {
                  SILMisc.showErr(context, 'An error occured');
                },
              );
            }),
          ),
        ),
      ));
      expect(find.byKey(snackbarKey), findsOneWidget);
      await tester.tap(find.byKey(snackbarKey));
      await tester.pumpAndSettle();
      expect(find.text('An error occured'), findsOneWidget);
    });

    group('bottomsheet', () {
      testWidgets('should render correctly without action',
          (WidgetTester tester) async {
        const Key launchBottomSheetKey = Key('button_key');
        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            return FlatButton(
              key: launchBottomSheetKey,
              child: Text('text button'),
              onPressed: () {
                SILMisc.bottomSheet(
                    action: null,
                    backgroundColor: Theme.of(context).backgroundColor,
                    context: context,
                    message: 'Show bottom sheet',
                    primaryColor: Theme.of(context).primaryColor,
                    textColor: Colors.black);
              },
            );
          }),
        ));

        await tester.pumpAndSettle();
        await tester.tap(find.byKey(launchBottomSheetKey));
        await tester.pumpAndSettle();

        Finder bottomSheetContainer = await find.byKey(containerKey);
        expect(bottomSheetContainer, findsOneWidget);

        Finder bottomSheetColumn = await find.byKey(columnKey);
        expect(bottomSheetColumn, findsOneWidget);
      });

      testWidgets('should render correctly with action',
          (WidgetTester tester) async {
        bool isActionTapped = false;

        const Key launchBottomSheetKey = Key('button_key');
        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            return FlatButton(
              key: launchBottomSheetKey,
              child: Text('text button'),
              onPressed: () {
                SILMisc.bottomSheet(
                    action: () {
                      isActionTapped = true;
                    },
                    backgroundColor: Theme.of(context).backgroundColor,
                    context: context,
                    message: 'Show bottom sheet',
                    primaryColor: Theme.of(context).primaryColor,
                    textColor: Colors.black);
              },
            );
          }),
        ));

        await tester.pumpAndSettle();
        await tester.tap(find.byKey(launchBottomSheetKey));
        await tester.pumpAndSettle();

        Finder bottomSheetContainer = await find.byKey(containerKey);
        expect(bottomSheetContainer, findsOneWidget);

        Finder okButton = await find.byKey(okButtonKey);
        expect(okButton, findsOneWidget);

        await tester.tap(okButton);
        await tester.pumpAndSettle();

        expect(isActionTapped, true);
      });
    });

    group('verifyOTPErrorBottomSheet', () {
      testWidgets('should render correctly without action',
          (WidgetTester tester) async {
        const Key launchBottomSheetKey = Key('button_key');
        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            return FlatButton(
              key: launchBottomSheetKey,
              child: Text('text button'),
              onPressed: () {
                SILMisc.verifyOTPErrorBottomSheet(
                    actionEnterCode: null,
                    context: context,
                    message: 'Show bottom sheet',
                    primaryColor: Theme.of(context).primaryColor,
                    textColor: Colors.black);
              },
            );
          }),
        ));

        await tester.pumpAndSettle();
        await tester.tap(find.byKey(launchBottomSheetKey));
        await tester.pumpAndSettle();

        Finder bottomSheetContainer = await find.byKey(containerKey);
        expect(bottomSheetContainer, findsOneWidget);

        Finder bottomSheetColumn = await find.byKey(columnKey);
        expect(bottomSheetColumn, findsOneWidget);
      });

      testWidgets('should render correctly with action',
          (WidgetTester tester) async {
        bool isActionTapped = false;

        const Key launchBottomSheetKey = Key('button_key');
        await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (BuildContext context) {
            return FlatButton(
              key: launchBottomSheetKey,
              child: Text('text button'),
              onPressed: () {
                SILMisc.verifyOTPErrorBottomSheet(
                    actionEnterCode: () {
                      isActionTapped = true;
                    },
                    context: context,
                    message: 'Show bottom sheet',
                    primaryColor: Theme.of(context).primaryColor,
                    textColor: Colors.black);
              },
            );
          }),
        ));

        await tester.pumpAndSettle();
        await tester.tap(find.byKey(launchBottomSheetKey));
        await tester.pumpAndSettle();

        Finder bottomSheetContainer = await find.byKey(containerKey);
        expect(bottomSheetContainer, findsOneWidget);

        Finder reenterCodeButton = await find.byKey(reenterCodeButtonKey);
        expect(reenterCodeButton, findsOneWidget);

        await tester.tap(reenterCodeButton);
        await tester.pumpAndSettle();

        expect(isActionTapped, true);
      });
    });

    group('SILEventBus', () {
      testWidgets('should test SILEventBus', (WidgetTester tester) async {
        final SILEventBus eventBus = SILEventBus();
        final Map<String, dynamic> eventPayload = <String, dynamic>{
          'test': 'test'
        };
        Stream<dynamic> stream = eventBus.streamController.stream;
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
              key: Key('test'),
              decoration: SILMisc.customRoundedPinBoxDecoration(
                  Colors.black, Colors.black),
            ));
          }),
        ));

        await tester.pumpAndSettle();
        expect(
          tester.widget(find.byType(Container)),
          isA<Container>().having(
              (Container t) => t.decoration,
              'decoration',
              SILMisc.customRoundedPinBoxDecoration(
                  Colors.black, Colors.black)),
        );
      });
    });
  });
}

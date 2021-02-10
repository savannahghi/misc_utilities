import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/responsive_widget.dart';

import '../test_utils/test_utils.dart';

void main() {
  group('ResponsiveWidget tests', () {
    final Text smallScreen = Text('small screen');
    final Text largeScreen = Text('large screen');

    testWidgets('draws smallScreen when screen is small',
        (WidgetTester tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue =
          typicalPhoneScreenSizePortrait;

      await _buildResponsiveWidget(
        tester,
        smallScreen: smallScreen,
        largeScreen: largeScreen,
      );
      await tester.pumpAndSettle();

      expect(find.byWidget(smallScreen), findsOneWidget);
      expect(find.byWidget(largeScreen), findsNothing);

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    testWidgets('draws largeScreen when screen is large',
        (WidgetTester tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue = tabletLandscape;

      await _buildResponsiveWidget(
        tester,
        smallScreen: smallScreen,
        largeScreen: largeScreen,
      );
      await tester.pumpAndSettle();

      expect(find.byWidget(smallScreen), findsNothing);
      expect(find.byWidget(largeScreen), findsOneWidget);

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    testWidgets('isLargeScreen returns true for large screen',
        (WidgetTester tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue = tabletLandscape;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (BuildContext context) {
            bool isSmallScreen = ResponsiveWidget.isSmallScreen(context);
            bool isLargeScreen = ResponsiveWidget.isLargeScreen(context);

            expect(isSmallScreen, isFalse);
            expect(isLargeScreen, isTrue);

            return Placeholder();
          }),
        ),
      );

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    testWidgets('isSmallScreen returns true for small screen',
        (WidgetTester tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue =
          typicalPhoneScreenSizePortrait;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (BuildContext context) {
            bool isSmallScreen = ResponsiveWidget.isSmallScreen(context);
            bool isLargeScreen = ResponsiveWidget.isLargeScreen(context);

            expect(isSmallScreen, isTrue);
            expect(isLargeScreen, isFalse);

            return Placeholder();
          }),
        ),
      );

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });
  });
}

Future<void> _buildResponsiveWidget(
  WidgetTester tester, {
  Widget smallScreen,
  Widget mediumScreen,
  Widget largeScreen,
}) async {
  return tester.pumpWidget(
    MaterialApp(
      home: ResponsiveWidget(
        smallScreen: smallScreen,
        mediumScreen: mediumScreen,
        largeScreen: largeScreen,
      ),
    ),
  );
}

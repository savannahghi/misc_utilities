import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:sil_misc/sil_misc.dart';

import 'package:sil_misc/src/small_appbar.dart';

import '../mocks.dart';

void main() {
  group('SILSmallAppbar', () {
    testWidgets('should render a normal appbar correctly',
        (WidgetTester tester) async {
      const String appbarTitle = 'small appbar';
      final String expectedAppbarTitle = titleCase(appbarTitle);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: SILSmallAppBar(title: appbarTitle)),
        ),
      );

      // check for the necessary items in the appbar
      expect(find.text(expectedAppbarTitle), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(PreferredSize), findsNothing);
    });

    testWidgets('should render an appbar with tabs',
        (WidgetTester tester) async {
      const String appbarTitle = 'small appbar';
      final List<String> tabtitles = <String>['Test', 'Coverage', '100%'];
      final String expectedAppbarTitle = titleCase(appbarTitle);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            appBar: SILSmallAppBar(
          title: appbarTitle,
          tabTitles: tabtitles,
        )),
      ));

      // check for the necessary items in the appbar
      expect(find.text(expectedAppbarTitle), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(PreferredSize), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(tabtitles.length));
    });

    testWidgets('should navigate to back route when provided',
        (WidgetTester tester) async {
      final MockNavigatorObserver navigatorObserver = MockNavigatorObserver();
      await tester.pumpWidget(MaterialApp(
        initialRoute: MockRoutes.route2,
        onGenerateRoute: MockRouteGenerator.generateRoute,
        navigatorObservers: <NavigatorObserver>[navigatorObserver],
      ));

      // check for the necessary items in the appbar
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // tap the back button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.byType(SILSmallAppBar), findsOneWidget);
    });

    testWidgets('should pop when back route is not provided',
        (WidgetTester tester) async {
      final MockNavigatorObserver navigatorObserver = MockNavigatorObserver();
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: MockRouteGenerator.generateRoute,
        navigatorObservers: <NavigatorObserver>[navigatorObserver],
      ));

      // check for the necessary items in the appbar
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // tap the back button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
    });

    testWidgets('should back route is not provided',
        (WidgetTester tester) async {
      final MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: MockRoutes.route2,
          onGenerateRoute: MockRouteGenerator.generateRoute,
          navigatorObservers: <NavigatorObserver>[navigatorObserver],
          home: const Scaffold(
            appBar: SILSmallAppBar(
              title: 'home',
            ),
          ),
        ),
      );

      // check for the necessary items in the appbar
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // tap the back button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
    });
  });
}

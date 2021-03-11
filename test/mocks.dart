import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:sil_misc/sil_small_appbar.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoutes {
  static const String route1 = 'route1';
  static const String route2 = 'route2';
}

// these mocks are used to test the back button of silsmallappbar
class MockRouteGenerator {
  /// gets the current route based on the [RouteSettings]
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // the root route config

      case MockRoutes.route1:
        return MaterialPageRoute<MaterialApp>(
          builder: (_) => const MaterialApp(
            home: Scaffold(
              appBar: SILSmallAppBar(title: MockRoutes.route1),
            ),
          ),
        );

      case MockRoutes.route2:
        return MaterialPageRoute<MaterialApp>(
          builder: (_) => MaterialApp(
            home: Scaffold(
              appBar: SILSmallAppBar(
                title: MockRoutes.route2,
                backRoute: MockRoutes.route1,
                backRouteNavigationFunction: () {},
              ),
            ),
          ),
        );
    }

    return MaterialPageRoute<MaterialApp>(
      builder: (_) =>const MaterialApp(
        home: Scaffold(
          appBar: SILSmallAppBar(title: 'Default route'),
        ),
      ),
    );
  }
}

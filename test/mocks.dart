import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:sil_misc/src/small_appbar.dart';

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
      builder: (_) => const MaterialApp(
        home: Scaffold(
          appBar: SILSmallAppBar(title: 'Default route'),
        ),
      ),
    );
  }
}

class MockSize extends Size {
  MockSize(double width, double height) : super(width, height);
}

class MockLandscapeMediaQueryData extends MediaQueryData {
  const MockLandscapeMediaQueryData(Size size) : super(size: size);
  @override
  Orientation get orientation => Orientation.landscape;
}

class MockPortraitMediaQueryData extends MediaQueryData {
  const MockPortraitMediaQueryData(Size size) : super(size: size);
  @override
  Orientation get orientation => Orientation.portrait;
}

/// Please refer to:
///
///  https://developer.android.com/training/multiscreen/screendensities#dips-pels

const Size typicalPhoneScreenSizePortrait = Size(320, 480);
const Size typicalPhoneScreenSizeLandscape = Size(480, 320);

const Size mediumSizedTabletPortrait = Size(600, 1024);
const Size mediumSizedTabletLandscape = Size(1024, 600);

const Size tabletPortrait = Size(720, 1280);
const Size tabletLandscape = Size(1280, 720);
const Size typicalLargePhoneScreenSizePortrait = Size(300, 800);

const Size typicalDesktop = Size(0, 1080);

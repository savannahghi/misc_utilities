import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:sil_app_wrapper/device_capabilities.dart';
import 'package:sil_graphql_client/graph_client.dart';
import 'package:sil_misc/src/small_appbar.dart';
import 'package:http/http.dart' as http;

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockDeviceCapabilities extends IDeviceCapabilities {}

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
final Map<String, bool> settingsVariables = <String, bool>{
  'allowEmail': true,
  'allowText': true,
  'allowWhatsApp': true,
  'allowPush': true,
};

// ignore: subtype_of_sealed_class
class MockSILGraphQlClient extends Mock implements SILGraphQlClient {
  String setupUserAsExperimentorVariables =
      json.encode(<String, bool>{'participate': true});
  String removeUserAsExperimentorVariables =
      json.encode(<String, bool>{'participate': false});

  @override
  Future<http.Response> query(
      String queryString, Map<String, dynamic> variables,
      [ContentType contentType = ContentType.json]) {
    if (json.encode(variables) == setupUserAsExperimentorVariables) {
      return Future<http.Response>.value(
        http.Response(
            json.encode(<String, dynamic>{
              'data': <String, dynamic>{'setupAsExperimentParticipant': true}
            }),
            200),
      );
    }

    if (json.encode(variables) == removeUserAsExperimentorVariables) {
      return Future<http.Response>.value(
        http.Response(
            json.encode(<String, dynamic>{
              'data': <String, dynamic>{'setupAsExperimentParticipant': true}
            }),
            200),
      );
    }
    if (queryString.contains('setUserCommunicationsSettings')) {
      return Future<http.Response>.value(
        http.Response(
            json.encode(<String, dynamic>{
              'data': <String, dynamic>{
                'setUserCommunicationsSettings': <String, dynamic>{
                  'allowWhatsApp': true,
                  'allowPush': false,
                  'allowEmail': true,
                  'allowTextSMS': true
                }
              }
            }),
            201),
      );
    }
    if (queryString.contains('Trace')) {
      /// return fake data here
      return Future<http.Response>.value(
        http.Response(
            json.encode(
              <String, dynamic>{
                'data': <String, dynamic>{'logDebugInfo': true}
              },
            ),
            201),
      );
    }
    if (queryString.contains('upload')) {
      return Future<http.Response>.value(
        http.Response(
            json.encode(<String, dynamic>{
              'data': <String, dynamic>{
                'upload': <String, dynamic>{
                  'id': 'uploadID',
                },
              }
            }),
            201),
      );
    }


    if (queryString.contains('UpdateUserProfile')) {
      return Future<http.Response>.value(
        http.Response(json.encode(<String, dynamic>{'error': 'error'}), 201),
      );
    }
    return Future<http.Response>.value();
  }

  @override
  Map<String, dynamic> toMap(Response? response) {
    if (response == null) return <String, dynamic>{};
    final dynamic _res = json.decode(response.body);
    if (_res is List<dynamic>) return _res[0] as Map<String, dynamic>;
    return _res as Map<String, dynamic>;
  }
}

String updateUserData = r'''
mutation UpdateUserData($allowWhatsApp: Boolean, $allowTextSMS: Boolean, $allowPush: Boolean, $allowEmail: Boolean) {
  UpdateUserData(allowWhatsApp: $allowWhatsApp, allowTextSMS: $allowTextSMS, allowPush: $allowPush, allowEmail: $allowEmail){
    allowWhatsApp
    allowPush
    allowEmail
    allowTextSMS
  }
}
 ''';
String updateUserProfile = r'''
mutation UpdateUserProfile($allowWhatsApp: Boolean, $allowTextSMS: Boolean, $allowPush: Boolean, $allowEmail: Boolean) {
  UpdateUserProfile(allowWhatsApp: $allowWhatsApp, allowTextSMS: $allowTextSMS, allowPush: $allowPush, allowEmail: $allowEmail){
    allowWhatsApp
    allowPush
    allowEmail
    allowTextSMS
  }
}
 ''';

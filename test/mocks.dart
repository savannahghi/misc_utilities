import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:app_wrapper/app_wrapper.dart';
import 'package:flutter_graphql_client/graph_client.dart';
import 'package:http/http.dart' as http;

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockDeviceCapabilities extends IDeviceCapabilities {}

class MockRoutes {
  static const String route1 = 'route1';
  static const String route2 = 'route2';
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
class MockGraphQlClient extends Mock implements GraphQlClient {
  String setupUserAsExperimenterVariables =
      json.encode(<String, bool>{'participate': true});
  String removeUserAsExperimenterVariables =
      json.encode(<String, bool>{'participate': false});

  @override
  Future<http.Response> query(
      String queryString, Map<String, dynamic> variables,
      [ContentType contentType = ContentType.json]) {
    if (json.encode(variables) == setupUserAsExperimenterVariables) {
      return Future<http.Response>.value(
        http.Response(
            json.encode(<String, dynamic>{
              'data': <String, dynamic>{'setupAsExperimentParticipant': true}
            }),
            200),
      );
    }

    if (json.encode(variables) == removeUserAsExperimenterVariables) {
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

    if (queryString.contains('FakeQuery')) {
      /// return fake data here
      return Future<http.Response>.value(
        http.Response(
            json.encode(
              <String, dynamic>{
                'errors': <Map<String, dynamic>>[
                  <String, String>{'message': 'generic list error occurred'}
                ]
              },
            ),
            200),
      );
    }

    if (queryString.contains('TooQueryFake')) {
      /// return fake data here
      return Future<http.Response>.value(
        http.Response(
            json.encode(
              <String, dynamic>{'data': null},
            ),
            200),
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

// intentional ignore
// ignore: unnecessary_raw_strings
String fakeQuery = r'''
  query FakeQuery() {
  fake() {
    id    
  }
}
''';

// intentional ignore
// ignore: unnecessary_raw_strings
String fakeQueryTwo = r'''
  query TooQueryFake() {
  fake() {
    id    
  }
}
''';

/// to avoid side effects of https://github.com/flutter/flutter/issues/20907
String testPath(String relativePath) {
  final Directory current = Directory.current;
  final String path =
      current.path.endsWith('/test') ? current.path : '${current.path}/test';

  return '$path/$relativePath';
}

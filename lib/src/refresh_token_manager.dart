import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// [SILRefreshTokenManger] is responsible for when to fetch a brand new
/// id-token just before the expiry of the current one.
/// The [updateExpireTime] is triggered in two scenarios;
///
/// 1 . Just after successful login. Ideally this will always be the first call
/// 2 . When the app boots-up.  The scenario here is app is removed from stack by
///     user or during development. The app will retrieve the appropriate expiry time,
///     do some time math and determine whether its the right time to call for a
///     a fresh id-token
class SILRefreshTokenManger {
  factory SILRefreshTokenManger() {
    return _singleton;
  }

  SILRefreshTokenManger._internal();

  static final SILRefreshTokenManger _singleton =
      SILRefreshTokenManger._internal();

  //ignore: close_sinks
  BehaviorSubject<dynamic> listen = BehaviorSubject<dynamic>();

  final BehaviorSubject<String> _expireTime = BehaviorSubject<String>();

  SILRefreshTokenManger updateExpireTime(String expire) {
    _expireTime.add(expire);
    this.listen.add(null);
    return this;
  }

  bool _ifAfterCurrentTime(DateTime parsed) {
    final Duration _afterCurrentTime = parsed.difference(DateTime.now());
    if (_afterCurrentTime.inSeconds <= 0) {
      return true;
    }
    return false;
  }

  bool _ifApproachingCurrentTime(DateTime parsed) {
    final Duration _closeToCurrentTime = DateTime.now().difference(parsed);
    if (_closeToCurrentTime.inSeconds >= (10 * 60)) {
      return true;
    }
    return false;
  }

  /// [checkExpireValidity] for checking whether the expire time is valid.
  /// Recommended to be called just before the app draws its first widget in main.dart
  bool checkExpireValidity(String? expireAt) {
    try {
      final DateTime _parsed = DateTime.parse(expireAt!);
      if (this._ifAfterCurrentTime(_parsed) == true ||
          this._ifApproachingCurrentTime(_parsed) == true) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// [reset] is responsible for resetting the timeout clock and notifying the listener [listen]
  /// when fetch a new token
  void reset() {
    try {
      if (this._expireTime.value != null) {
        // this is the time from login or retrieved from state store as string
        final DateTime _parsed = DateTime.parse(this._expireTime.value!);
        // determine if the parsed time is after the current time
        if (this._ifAfterCurrentTime(_parsed)) {
          this.listen.add(true);
          return;
        }

        // determine if the parse time is 7 minutes to the current time
        if (this._ifApproachingCurrentTime(_parsed)) {
          this.listen.add(true);
          return;
        }

        // refresh 15 minutes before token expires
        final DateTime _threshold =
            _parsed.subtract(const Duration(minutes: 15));
        final Duration _duration = _threshold.difference(DateTime.now());
        if (_duration.inSeconds <= 0) {
          final Duration _duration = _parsed.difference(DateTime.now());
          Timer(Duration(seconds: _duration.inSeconds), () {
            this.listen.add(true);
          });
        } else {
          Timer(Duration(seconds: _duration.inSeconds), () {
            this.listen.add(true);
          });
        }

        return;
      }
    } catch (e) {
      return;
    }

    return;
  }
}

import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// [RefreshTokenManger] is responsible for when to fetch a brand new
/// id-token just before the expiry of the current one.
/// The [updateExpireTime] is triggered in two scenarios;
///
/// 1 . Just after successful login. Ideally this will always be the first call
/// 2 . When the app boots-up.  The scenario here is app is removed from stack by
///     user or during development. The app will retrieve the appropriate expiry time,
///     do some time math and determine whether its the right time to call for a
///     a fresh id-token
class RefreshTokenManger {
  factory RefreshTokenManger() {
    return _singleton;
  }

  RefreshTokenManger._internal();

  static final RefreshTokenManger _singleton = RefreshTokenManger._internal();

  BehaviorSubject<bool> listen = BehaviorSubject<bool>.seeded(false);

  final BehaviorSubject<String> _expireTime = BehaviorSubject<String>();

  // this will be used to refer to the timer and close it
  late Timer timer;

  RefreshTokenManger updateExpireTime(String expire) {
    _expireTime.add(expire);
    this.listen.add(false);
    return this;
  }

  ///if user logs in after expiry return true
  bool ifTokenIsAfterExpiry(DateTime parsed) {
    final Duration _afterCurrentTime = parsed.difference(DateTime.now());
    if (_afterCurrentTime.inSeconds <= 0) {
      return true;
    }
    return false;
  }

  ///if user logs in when token is <= 10minutes to expiry return true
  bool ifTokenIsApproachingExpiry(DateTime parsed) {
    final Duration _closeToCurrentTime = DateTime.now().difference(parsed);
    // ten minutes (600 seconds)
    if (_closeToCurrentTime.inSeconds >= -600) {
      return true;
    }
    return false;
  }

  /// [checkExpireValidity] for checking whether the expire time is valid.
  /// Recommended to be called just before the app draws its first widget in main.dart
  bool checkExpireValidity(String? expireAt) {
    final DateTime _parsed = DateTime.parse(expireAt!);
    if (this.ifTokenIsAfterExpiry(_parsed) == true ||
        this.ifTokenIsApproachingExpiry(_parsed) == true) {
      return false;
    }
    return true;
  }

  /// [reset] is responsible for resetting the timeout clock and notifying the listener [listen]
  /// when fetch a new token
  void reset() {
    try {
      // this is the time from login or retrieved from state store as string
      final DateTime _expireTime = DateTime.parse(this._expireTime.value);
      // determine if the parse time is 10 minutes to the expiry time
      if (this.ifTokenIsApproachingExpiry(_expireTime)) {
        return this.listen.add(true);
      }
      return;
    } catch (e) {
      return;
    }
  }
}

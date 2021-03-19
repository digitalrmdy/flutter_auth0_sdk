import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Auth0Sdk {
  static const MethodChannel _channel = const MethodChannel('auth0_sdk');

  static Future<void> init(
      {@required String clientId, @required String domain}) async {
    try {
      await _channel.invokeMethod<bool>('init', <String, dynamic>{
        'clientId': clientId,
        'domain': domain,
      });
    } on PlatformException catch (e) {
      developer.log('Error during init: ${e.code} - ${e.message}',
          name: 'auth0_sdk');
      rethrow;
    }
  }

  static Future<LoginResult> loginUsernamePassword(
      {@required String username, @required String password}) async {
    try {
      Map<dynamic, dynamic> result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(
              'loginUsernamePassword', <String, dynamic>{
        'username': username,
        'password': password,
      });
      return LoginResult(
          idToken: result['idToken'],
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken']);
    } on PlatformException catch (e) {
      developer.log('Error during login: ${e.code} - ${e.message}',
          name: 'auth0_sdk');
      rethrow;
    }
  }

  static Future<LoginResult> loginWithSocial(
      {@required String accessToken}) async {
    try {
      Map<dynamic, dynamic> result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(
              'loginWithSocial', <String, dynamic>{
        'accessToken': accessToken,
      });
      return LoginResult(
          idToken: result['idToken'],
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken']);
    } on PlatformException catch (e) {
      developer.log('Error during login: ${e.code} - ${e.message}',
          name: 'auth0_sdk');
      rethrow;
    }
  }

  static Future<LoginResult> loginWithGoogle(
      {@required String accessToken}) async {
    try {
      Map<dynamic, dynamic> result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(
              'loginWithGoogle', <String, dynamic>{});
      return LoginResult(
          idToken: result['idToken'],
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken']);
    } on PlatformException catch (e) {
      developer.log('Error during login: ${e.code} - ${e.message}',
          name: 'auth0_sdk');
      rethrow;
    }
  }
}

class LoginResult {
  final String idToken;
  final String refreshToken;
  final String accessToken;

  LoginResult(
      {@required this.idToken,
      @required this.accessToken,
      @required this.refreshToken});
}

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

  static Future<LoginResult> loginWithEmailAndPassword(
      {@required String email, @required String password}) async {
    try {
      Map<dynamic, dynamic> result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(
              'loginWithEmailAndPassword', <String, dynamic>{
        'email': email,
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

  static Future<RegisterResult> registerWithEmailAndPassword(
      {@required String email,
      @required String password,
      @required String name}) async {
    try {
      Map<dynamic, dynamic> result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(
              'registerWithEmailAndPassword', <String, dynamic>{
        'email': email,
        'password': password,
        'name': name
      });
      return RegisterResult(
          email: result['email'],
          username: result['username'],
          emailVerified: result['emailVerified'] == "true" ? true : false);
    } on PlatformException catch (e) {
      developer.log('Error during register: ${e.code} - ${e.message}',
          name: 'auth0_sdk');
      rethrow;
    }
  }

  static Future<LoginResult> authWithGoogle() async {
    return _authWithSocialProvider('authWithGoogle');
  }

  static Future<LoginResult> authWithApple() async {
    return _authWithSocialProvider('authWithApple');
  }

  static Future<LoginResult> _authWithSocialProvider(String connection) async {
    try {
      Map<dynamic, dynamic> result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(connection, <String, dynamic>{});
      return LoginResult(
          idToken: result['idToken'],
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken']);
    } on PlatformException catch (e) {
      developer.log('Error during $connection: ${e.code} - ${e.message}',
          name: 'auth0_sdk');
      rethrow;
    }
  }

  static Future<LoginResult> refreshAccessToken(String refreshToken) async {
    try {
      Map<dynamic, dynamic> result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('refreshAccessToken',
              <String, dynamic>{'refreshToken': refreshToken});
      return LoginResult(
          idToken: result['idToken'],
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken']);
    } on PlatformException catch (e) {
      developer.log('Error during refresh: ${e.code} - ${e.message}',
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

class RegisterResult {
  final String email;
  final String username;
  final bool emailVerified;

  RegisterResult(
      {@required this.email,
      @required this.username,
      @required this.emailVerified});
}

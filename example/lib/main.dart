import 'dart:async';
import 'dart:convert';

import 'package:auth0_sdk/auth0_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(Auth0App());
}

class Auth0App extends StatefulWidget {
  @override
  _Auth0AppState createState() => _Auth0AppState();
}

class _Auth0AppState extends State<Auth0App> {
  String _initState = 'Unknown';
  String _label = "";
  String _accessToken = "-";

  String _email = "";
  String _pw = "";
  bool _create = false;
  String _refreshToken;

  @override
  void initState() {
    super.initState();
    initAuth0();
  }

  Future<void> _handleAuthWithEmailAndPassword() async {
    if (_create) {
      try {
        RegisterResult registerResult =
            await Auth0Sdk.registerWithEmailAndPassword(
                email: _email, password: _pw);
        if (registerResult.emailVerified) {
          setState(() {
            _create = false;
          });
          _handleAuthWithEmailAndPassword();
        } else {
          setState(() {
            _label = "verify email";
            _accessToken = "-";
            _refreshToken = null;
          });
        }
      } on PlatformException catch (e) {
        setState(() {
          _label = "${e.code} - ${e.message}";
          _accessToken = "-";
          _refreshToken = null;
        });
      }
    } else {
      try {
        LoginResult socialResult = await Auth0Sdk.loginWithEmailAndPassword(
            email: _email, password: _pw);
        _handleResult(socialResult);
      } on PlatformException catch (e) {
        setState(() {
          _label = "${e.code} - ${e.message}";
          _accessToken = "-";
          _refreshToken = null;
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    if (_email.isNotEmpty) {
      try {
        final bool result = await Auth0Sdk.resetPassword(email: _email);
        setState(() => _resetPassword = result);
      } on PlatformException catch (e) {
        setState(() {
          _label = "${e.code} - ${e.message}";
        });
      }
    }
  }

  Future<void> _handleAuthWithGoogle() async {
    try {
      LoginResult socialResult = await Auth0Sdk.authWithGoogle();
      _handleResult(socialResult);
    } on PlatformException catch (e) {
      setState(() {
        _label = "${e.code} - ${e.message}";
        _accessToken = "-";
        _refreshToken = null;
      });
    }
  }

  Future<void> _handleAuthWithApple() async {
    try {
      LoginResult socialResult = await Auth0Sdk.authWithApple();
      _handleResult(socialResult);
    } on PlatformException catch (e) {
      setState(() {
        _label = "${e.code} - ${e.message}";
        _accessToken = "-";
        _refreshToken = null;
      });
    }
  }

  Future<void> _handleRefreshAccessToken() async {
    try {
      if (_refreshToken != null) {
        LoginResult socialResult =
            await Auth0Sdk.refreshAccessToken(_refreshToken);
        _handleResult(socialResult);
      }
    } on PlatformException catch (e) {
      setState(() {
        _label = "${e.code} - ${e.message}";
        _accessToken = "-";
        _refreshToken = null;
      });
    }
  }

  void _handleResult(LoginResult loginResult) {
    final idToken = _parseAuthZeroIdToken(loginResult.idToken);
    final completeSub = idToken['sub'] as String;
    final platform = completeSub.substring(0, completeSub.indexOf("|"));
    final email = idToken['email'] as String;
    setState(() {
      _label = "$platform - $email";
      _accessToken = loginResult.accessToken.substring(0, 20);
      _refreshToken = loginResult.refreshToken;
    });
    return;
  }

  Map<String, dynamic> _parseAuthZeroIdToken(String idToken) {
    final parts = idToken.split('.');
    assert(parts.length == 3);

    return jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
        as Map<String, dynamic>;
  }

  Future<void> initAuth0() async {
    String initState = "Checking";

    try {
      Auth0Sdk.init(
          clientId: "UM0fB5NVy7eKQ2nmNjpvV260L6eWTX4a",
          domain: "ltdev.eu.auth0.com");
      initState = "Initialised!";
    } on Exception {
      initState = "Error while initialising!";
    }

    if (!mounted) return;

    setState(() {
      _initState = initState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: ListView(
              children: [
                Text('SDK status? $_initState\n'),
                Text('Result: $_label\n'),
                Text('AccessToken: $_accessToken\n'),
                SizedBox(
                  height: 50,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Email"),
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Password"),
                  onChanged: (value) {
                    setState(() {
                      _pw = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Create user?"),
                    Checkbox(
                        value: _create,
                        onChanged: (value) {
                          setState(() {
                            _create = value;
                          });
                        }),
                    TextButton(
                      onPressed: () {
                        _handleAuthWithEmailAndPassword();
                      },
                      child: Text("Auth with email/pw"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                TextButton(
                  onPressed: () {
                    _handleAuthWithGoogle();
                  },
                  child: Text("Auth with Google"),
                ),
                SizedBox(
                  height: 25,
                ),
                TextButton(
                  onPressed: () {
                    _handleAuthWithApple();
                  },
                  child: Text("Auth with Apple"),
                ),
                SizedBox(
                  height: 25,
                ),
                if (_refreshToken != null)
                  TextButton(
                    onPressed: () {
                      _handleRefreshAccessToken();
                    },
                    child: Text("Refresh Access Token"),
                  ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () => _handleResetPassword(),
                  child: Text("Reset password"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

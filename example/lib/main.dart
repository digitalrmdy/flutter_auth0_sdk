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
  String _token = "";

  @override
  void initState() {
    super.initState();
    initAuth0();
  }

  Future<void> _handleSignIn() async {
    try {
      try {
        LoginResult socialResult = await Auth0Sdk.loginWithGoogle();
        final idToken = _parseAuthZeroIdToken(socialResult.idToken);
        print("!!!!!!!! ${idToken}");
        setState(() {
          _token = socialResult.idToken;
        });
      } on PlatformException catch (e) {
        setState(() {
          _token = e.code;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  Map<String, dynamic> _parseAuthZeroIdToken(String idToken) {
    final parts = idToken.split('.');
    assert(parts.length == 3);

    return jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
        as Map<String, dynamic>;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAuth0() async {
    String initState = "Checking";

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Auth0Sdk.init(
          clientId: "UM0fB5NVy7eKQ2nmNjpvV260L6eWTX4a",
          domain: "ltdev.eu.auth0.com");
      initState = "Initialised!";
      /*Future.delayed(Duration(seconds: 5), () async {
        try {
          LoginResult result = await Auth0Sdk.loginUsernamePassword(
              username: "yannick.vangodtsenhoven+auth@gmail.com",
              password: "Wachtwoord1,");
          setState(() {
            _token = result.idToken;
          });
        } on PlatformException catch (e) {
          setState(() {
            _token = e.code;
          });
        }
      });*/
    } on Exception {
      initState = "Error while initialising!";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
          child: Column(
            children: [
              Text('Initstate: $_initState\n'),
              Text('Token: $_token\n'),
              SizedBox(
                height: 100,
              ),
              FlatButton(
                  onPressed: () {
                    _handleSignIn();
                  },
                  child: Text("Sign in with Google"))
            ],
          ),
        ),
      ),
    );
  }
}

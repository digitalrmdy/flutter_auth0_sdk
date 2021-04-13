import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auth0_sdk/auth0_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('auth0_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Auth0Sdk.platformVersion, '42');
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelTnkFlutterRwd platform = MethodChannelTnkFlutterRwd();
  const MethodChannel channel = MethodChannel('tnk_flutter_rwd');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

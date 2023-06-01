//import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd_method_channel.dart';

void main() {
  MethodChannelTnkFlutterRwd platform = MethodChannelTnkFlutterRwd();
  //const MethodChannel channel = MethodChannel('tnk_flutter_rwd');

  TestWidgetsFlutterBinding.ensureInitialized();

  // setUp(() {
  //   channel.setMockMethodCallHandler((MethodCall methodCall) async {
  //     return '42';
  //   });
  // });
  //
  // tearDown(() {
  //   channel.setMockMethodCallHandler(null);
  // });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

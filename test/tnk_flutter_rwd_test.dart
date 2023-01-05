import 'package:flutter_test/flutter_test.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd_platform_interface.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTnkFlutterRwdPlatform
    with MockPlatformInterfaceMixin
    implements TnkFlutterRwdPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> showAdList() => Future.value('onShow');
  @override
  Future<String?> setUserName(String user_name) => Future.value('onShow');
  @override
  Future<String?> setCOPPA(bool coppa) => Future.value('onShow');
}

void main() {
  final TnkFlutterRwdPlatform initialPlatform = TnkFlutterRwdPlatform.instance;

  test('$MethodChannelTnkFlutterRwd is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTnkFlutterRwd>());
  });

  test('getPlatformVersion', () async {
    TnkFlutterRwd tnkFlutterRwdPlugin = TnkFlutterRwd();
    MockTnkFlutterRwdPlatform fakePlatform = MockTnkFlutterRwdPlatform();
    TnkFlutterRwdPlatform.instance = fakePlatform;

    expect(await tnkFlutterRwdPlugin.getPlatformVersion(), '42');
  });
}

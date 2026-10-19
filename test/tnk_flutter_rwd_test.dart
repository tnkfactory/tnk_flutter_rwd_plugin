import 'dart:collection';

import 'package:flutter/services.dart';
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
  Future<String?> showAdList(String title, [int appId = 0]) => Future.value('onShow');
  @override
  Future<String?> setUserName(String userName) => Future.value('onShow');
  @override
  Future<String?> setCOPPA(bool coppa) => Future.value('onShow');
  @override
  Future<String?> applicationStarted() => Future.value('success');
  @override
  Future<String?> showATTPopup() => Future.value('onShow');
  @override
  Future<int?> getEarnPoint() => Future.value();
  @override
  Future<String?> setNoUsePrivacyAlert() {
    throw UnimplementedError();
  }

  @override
  Future<int?> getQueryPoint() {
    throw UnimplementedError();
  }

  @override
  Future<String?> purchaseItem(String itemId, int cost) {
    throw UnimplementedError();
  }

  @override
  Future<String?> setNoUsePointIcon() {
    throw UnimplementedError();
  }

  @override
  Future<String?> withdrawPoints(String description) {
    throw UnimplementedError();
  }

  @override
  Future<String?> setCustomUI(HashMap<String, String> colorMap) {
    throw UnimplementedError();
  }

  @override
  Future<String> getOfferWallEvent(MethodCall methodCall) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getPlacementJsonData(String placementId) {
    throw UnimplementedError();
  }

  @override
  Future<String?> onItemClick(String app_id) {
    throw UnimplementedError();
  }
  @override
  Future<String?> setUseTermsPopup(bool bUse) {
    throw UnimplementedError();
  }
  @override
  Future<String?> setUserTermsAgree(bool agree) {
    throw UnimplementedError();
  }

  @override
  Future<String?> setCustomUnitIcon(HashMap<String, String> map) {
    throw UnimplementedError();
  }
  @override
  Future<String?> closeAdDetail() {
    throw UnimplementedError();
  }

  @override
  Future<String?> closeAllView() {
    throw UnimplementedError();
  }
  @override
  Future<String?> closeOfferwall() {
    throw UnimplementedError();
  }

  @override
  Future<String?> setCustomUIDefault(HashMap<String, String> map) {
    throw UnimplementedError();
  }

  @override
  Future<String?> setCategoryAndFilter(int category, int filter) {
    throw UnimplementedError();
  }

  @override
  Future<String?> presentAdDetailView(int appId, [int actionId = 0]) {
    throw UnimplementedError();
  }

  @override
  Future<String?> adAction(int appId, [int actionId = 0]) {
    throw UnimplementedError();
  }

  @override
  Future<String?> adJoin(int appId,
      [int actionId = 0,
      bool useTopViewController = false,
      bool fullscreen = false]) {
    throw UnimplementedError();
  }

  @override
  Future<String?> openEventWebView(int eventId) {
    throw UnimplementedError();
  }

  @override
  Future<String?> showCustomTapActivity(String url, String deep_link) {
    throw UnimplementedError();
  }

  @override
  Future<String?> setPubCustomUi([int type = 0]) {
    throw UnimplementedError();
  }

  @override
  Future<String?> showEventWebPage(HashMap<String, String> map) {
    throw UnimplementedError();
  }

  @override
  Future<String?> showMyEarnPointList(HashMap<String, dynamic>? map) {
    throw UnimplementedError();
  }

  @override
  Future<String?> nativeTnkEventScheme(String url) {
    throw UnimplementedError();
  }

  @override
  Future<String?> showAdListWithPlacement(String placementId, int categoryId, int filterId) {
    throw UnimplementedError();
  }

  @override
  Future<bool?> isUserTermsAgree() {
    throw UnimplementedError();
  }

  String themeValue = 'unspecified';

  @override
  Future<String?> setOfferwallTheme(String theme) {
    themeValue = theme;
    return Future.value('success');
  }

  @override
  Future<String?> getOfferwallTheme() => Future.value(themeValue);

  @override
  Future<String?> setPrivacyAgreementListener({VoidCallback? onAgreed, VoidCallback? onRevoked}) {
    privacyAgreed = onAgreed;
    privacyRevoked = onRevoked;
    return Future.value('success');
  }

  VoidCallback? privacyAgreed;
  VoidCallback? privacyRevoked;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  group('offerwall theme', () {
    test('normalizeOfferwallTheme maps known values and falls back to unspecified', () {
      expect(TnkFlutterRwd.normalizeOfferwallTheme('light'), 'light');
      expect(TnkFlutterRwd.normalizeOfferwallTheme('DARK'), 'dark');
      expect(TnkFlutterRwd.normalizeOfferwallTheme(' System '), 'system');
      expect(TnkFlutterRwd.normalizeOfferwallTheme('unspecified'), 'unspecified');
      expect(TnkFlutterRwd.normalizeOfferwallTheme('sepia'), 'unspecified');
      expect(TnkFlutterRwd.normalizeOfferwallTheme(''), 'unspecified');
      expect(TnkFlutterRwd.normalizeOfferwallTheme(null), 'unspecified');
    });

    test('setOfferwallTheme passes a normalized value to the platform', () async {
      final fake = MockTnkFlutterRwdPlatform();
      TnkFlutterRwdPlatform.instance = fake;
      final plugin = TnkFlutterRwd();

      expect(await plugin.setOfferwallTheme('Dark'), 'success');
      expect(fake.themeValue, 'dark');
      expect(await plugin.getOfferwallTheme(), 'dark');

      await plugin.setOfferwallTheme('nonsense');
      expect(await plugin.getOfferwallTheme(), 'unspecified');
    });
  });

  group('method channel', () {
    const channel = MethodChannel('tnk_flutter_rwd');
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return call.method == 'getOfferwallTheme' ? 'light' : 'success';
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('setOfferwallTheme / getOfferwallTheme use the expected channel calls', () async {
      final platform = MethodChannelTnkFlutterRwd();
      expect(await platform.setOfferwallTheme('dark'), 'success');
      expect(calls.single.method, 'setOfferwallTheme');
      expect(calls.single.arguments, {'theme': 'dark'});

      expect(await platform.getOfferwallTheme(), 'light');
      expect(calls.last.method, 'getOfferwallTheme');
    });
  });

  group('privacy agreement listener', () {
    const channel = MethodChannel('tnk_flutter_rwd');
    const privacy = MethodChannel('tnk_flutter_rwd/privacy');
    final calls = <MethodCall>[];

    // 네이티브가 이벤트를 보내는 것을 흉내낸다.
    Future<void> emit(String method) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(privacy.name,
              const StandardMethodCodec().encodeMethodCall(MethodCall(method)), (_) {});
    }

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return 'success';
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      privacy.setMethodCallHandler(null);
    });

    test('registers natively and dispatches agreed / revoked to the callbacks', () async {
      final platform = MethodChannelTnkFlutterRwd();
      var agreed = 0, revoked = 0;
      expect(await platform.setPrivacyAgreementListener(onAgreed: () => agreed++, onRevoked: () => revoked++), 'success');
      expect(calls.single.method, 'setPrivacyAgreementListener');
      expect(calls.single.arguments, {'enabled': true});

      await emit('onPrivacyAgreementAgreed');
      expect([agreed, revoked], [1, 0]);
      await emit('onPrivacyAgreementRevoked');
      expect([agreed, revoked], [1, 1]);
    });

    test('works with only one callback; the other event is ignored without error', () async {
      final platform = MethodChannelTnkFlutterRwd();
      var revoked = 0;
      await platform.setPrivacyAgreementListener(onRevoked: () => revoked++);
      await emit('onPrivacyAgreementAgreed');
      await emit('onPrivacyAgreementRevoked');
      expect(revoked, 1);
    });

    test('null callbacks unregister natively and events are then ignored', () async {
      final platform = MethodChannelTnkFlutterRwd();
      var agreed = 0;
      await platform.setPrivacyAgreementListener(onAgreed: () => agreed++);
      await platform.setPrivacyAgreementListener();
      expect(calls.last.arguments, {'enabled': false});
      await emit('onPrivacyAgreementAgreed');
      expect(agreed, 0);
    });

    test('a later registration replaces the earlier one', () async {
      final platform = MethodChannelTnkFlutterRwd();
      var first = 0, second = 0;
      await platform.setPrivacyAgreementListener(onAgreed: () => first++);
      await platform.setPrivacyAgreementListener(onAgreed: () => second++);
      await emit('onPrivacyAgreementAgreed');
      expect([first, second], [0, 1]);
    });

    test('TnkFlutterRwd forwards the callbacks to the platform', () async {
      final fake = MockTnkFlutterRwdPlatform();
      TnkFlutterRwdPlatform.instance = fake;
      void a() {}
      void r() {}
      await TnkFlutterRwd().setPrivacyAgreementListener(onAgreed: a, onRevoked: r);
      expect(fake.privacyAgreed, a);
      expect(fake.privacyRevoked, r);
    });
  });
}

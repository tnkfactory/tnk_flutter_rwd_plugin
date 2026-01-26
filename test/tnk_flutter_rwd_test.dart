import 'dart:collection';

import 'package:flutter/src/services/message_codec.dart';
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
  Future<String?> adJoin(int appId, [int actionId = 0]) {
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

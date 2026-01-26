

import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tnk_flutter_rwd_method_channel.dart';

abstract class TnkFlutterRwdPlatform extends PlatformInterface {
  /// Constructs a TnkFlutterRwdPlatform.
  TnkFlutterRwdPlatform() : super(token: _token);

  static final Object _token = Object();

  static TnkFlutterRwdPlatform _instance = MethodChannelTnkFlutterRwd();

  /// The default instance of [TnkFlutterRwdPlatform] to use.
  ///
  /// Defaults to [MethodChannelTnkFlutterRwd].
  static TnkFlutterRwdPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TnkFlutterRwdPlatform] when
  /// they register themselves.
  static set instance(TnkFlutterRwdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> setCategoryAndFilter(int category, int filter) {
    throw UnimplementedError('setCategoryAndFilter() has not been implemented.');
  }
  Future<String?> showCustomTapActivity(String url, String deep_link) {
    throw UnimplementedError('setCategoryAndFilter() has not been implemented.');
  }
  Future<String?> openEventWebView(int eventId) {
    throw UnimplementedError('openEventWebView() has not been implemented.');
  }
  Future<String?> showAdList(String title, [int appId = 0]) {
    throw UnimplementedError('showAdList() has not been implemented.');
  }

  Future<String?> setUserName(String userName) {
    throw UnimplementedError('showAdList() has not been implemented.');
  }
  Future<String?> setCOPPA(bool coppa) {
    throw UnimplementedError('showAdList() has not been implemented.');
  }
  Future<String?> showATTPopup() {
    throw UnimplementedError('showATTPopup() has not been implemented.');
  }
  Future<int?> getEarnPoint() {
    throw UnimplementedError('getEarnPoint() has not been implemented.');
  }
  Future<String?> setNoUsePointIcon() {
    throw UnimplementedError('setNoUsePointIcon() has not been implemented.');
  }
  Future<String?> setNoUsePrivacyAlert() {
    throw UnimplementedError('setNoUsePrivacyAlert() has not been implemented.');
  }
  Future<int?> getQueryPoint() {
    throw UnimplementedError('getQueryPoint() has not been implemented.');
  }
  Future<String?>purchaseItem(String itemId, int cost) {
    throw UnimplementedError('purchaseItem() has not been implemented');
  }
  Future<String?> withdrawPoints(String description) {
    throw UnimplementedError('withdrawPoints() has not been implemented');
  }
  Future<String?> setCustomUI(HashMap<String,String>colorMap) {
    throw UnimplementedError('setCustomUI has not benn implemented');
  }
  Future<String?> getOfferWallEvent(MethodCall methodCall) {
    throw UnimplementedError('getOfferWallEvent has not benn implemented');
  }
  Future<String?> getPlacementJsonData(String placementId) {
    throw UnimplementedError('getPlacementJsonData has not benn implemented');
  }
  Future<String?> onItemClick(String app_id) {
    throw UnimplementedError('onItemClick has not benn implemented');
  }
  Future<String?> setUseTermsPopup(bool isUse) {
    throw UnimplementedError('setUseTermsPopup has not benn implemented');
  }
  Future<String?> setCustomUnitIcon(HashMap<String,String>map) {
    throw UnimplementedError('setCustomUnitIcon has not benn implemented');
  }
  Future<String?> setCustomUIDefault(HashMap<String,String>map) {
    throw UnimplementedError('setCustomUIDefault has not benn implemented');
  }
  Future<String?> closeAdDetail() {
    throw UnimplementedError('closeAdDetail has not benn implemented');
  }
  Future<String?> closeAllView() {
    throw UnimplementedError('closeAllView has not benn implemented');
  }
  Future<String?> closeOfferwall() {
    throw UnimplementedError('closeOfferwall has not benn implemented');
  }
  Future<String?> presentAdDetailView(int appId, [int actionId = 0]) {
    throw UnimplementedError('presentAdDetailView has not benn implemented');
  }
  Future<String?> adJoin(int appId, [int actionId = 0]) {
    throw UnimplementedError('adJoin has not benn implemented');
  }

  Future<String?> adAction(int appId, [int actionId = 0]) {
    throw UnimplementedError('adAction has not benn implemented');
  }

  Future<String?> setPubCustomUi([int type = 0]) {
    throw UnimplementedError('setPubCustomUi has not benn implemented');
  }

  Future<String?> showEventWebPage(HashMap<String,String> map) {
    throw UnimplementedError('showEventWebPage has not benn implemented');

  }


}

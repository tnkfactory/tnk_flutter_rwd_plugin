import 'dart:collection';

import 'package:flutter/services.dart';

import 'tnk_flutter_rwd_platform_interface.dart';

class TnkFlutterRwd {
  Future<String?> getPlatformVersion() {
    return TnkFlutterRwdPlatform.instance.getPlatformVersion();
  }

  Future<String?> setCategoryAndFilter(int category, int filter) {
    return TnkFlutterRwdPlatform.instance.setCategoryAndFilter(category, filter);
  }
  Future<String?> showAdList(String title, [int appId = 0]) {
    return TnkFlutterRwdPlatform.instance.showAdList(title, appId);
  }

  Future<String?> setUserName(String userName) {
    return TnkFlutterRwdPlatform.instance.setUserName(userName);
  }

  Future<String?> setCOPPA(bool coppa) {
    return TnkFlutterRwdPlatform.instance.setCOPPA(coppa);
  }

  Future<String?> showATTPopup() {
    return TnkFlutterRwdPlatform.instance.showATTPopup();
  }

  Future<int?> getEarnPoint() {
    return TnkFlutterRwdPlatform.instance.getEarnPoint();
  }

  Future<String?> setNoUsePointIcon() {
    return TnkFlutterRwdPlatform.instance.setNoUsePointIcon();
  }

  Future<String?> setNoUsePrivacyAlert() {
    return TnkFlutterRwdPlatform.instance.setNoUsePrivacyAlert();
  }

  Future<int?> getQueryPoint() {
    return TnkFlutterRwdPlatform.instance.getQueryPoint();
  }

  Future<String?> purchaseItem(String itemId, int cost) {
    return TnkFlutterRwdPlatform.instance.purchaseItem(itemId, cost);
  }

  Future<String?> withdrawPoints(String description) {
    return TnkFlutterRwdPlatform.instance.withdrawPoints(description);
  }

  Future<String?> setCustomUI(HashMap<String, String> colorMap) {
    return TnkFlutterRwdPlatform.instance.setCustomUI(colorMap);
  }

  // 오퍼월 close 콜백 메소드
  Future<String?> getOfferWallEvent(MethodCall methodCall) {
    return TnkFlutterRwdPlatform.instance.getOfferWallEvent(methodCall);
  }

  Future<String?> getPlacementJsonData(String placementId) {
    return TnkFlutterRwdPlatform.instance.getPlacementJsonData(placementId);
  }

  Future<String?> onItemClick(String app_id) {
    return TnkFlutterRwdPlatform.instance.onItemClick(app_id);
  }
  Future<String?> setUseTermsPopup(bool isUse) {
    return TnkFlutterRwdPlatform.instance.setUseTermsPopup(isUse);
  }

  Future<String?> setCustomUnitIcon(HashMap<String, String> map) {
    return TnkFlutterRwdPlatform.instance.setCustomUnitIcon(map);
  }
  Future<String?> closeAllView() {
    return TnkFlutterRwdPlatform.instance.closeAllView();
  }
  Future<String?> closeOfferwall() {
    return TnkFlutterRwdPlatform.instance.closeOfferwall();
  }
  Future<String?> closeAdDetail() {
    return TnkFlutterRwdPlatform.instance.closeAdDetail();
  }

  Future<String?> setCustomUIDefault(HashMap<String, String> map) {
    return TnkFlutterRwdPlatform.instance.setCustomUIDefault(map);
  }

  Future<String?> presentAdDetailView(int appId) {
    return TnkFlutterRwdPlatform.instance.presentAdDetailView(appId);
  }
}

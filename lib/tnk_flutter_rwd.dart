import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'tnk_flutter_rwd_platform_interface.dart';

class TnkFlutterRwd {
  Future<String?> getPlatformVersion() {
    return TnkFlutterRwdPlatform.instance.getPlatformVersion();
  }

  Future<String?> setCategoryAndFilter(int category, int filter) {
    return TnkFlutterRwdPlatform.instance.setCategoryAndFilter(category, filter);
  }

  Future<String?> openEventWebView(int eventId) {
    return TnkFlutterRwdPlatform.instance.openEventWebView(eventId);
  }

  Future<String?> showCustomTapActivity(String url, String deep_link) {
    return TnkFlutterRwdPlatform.instance.showCustomTapActivity(url, deep_link);
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

  Future<String?> setUserTermsAgree(bool agree) {
    return TnkFlutterRwdPlatform.instance.setUserTermsAgree(agree);
  }
  Future<bool?> isUserTermsAgree() {
    return TnkFlutterRwdPlatform.instance.isUserTermsAgree();
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

  Future<String?> presentAdDetailView(int appId, [int actionId = 0]) {
    return TnkFlutterRwdPlatform.instance.presentAdDetailView(appId, actionId);
  }

  /// 광고에 참여한다.
  ///
  /// [useTopViewController] 는 iOS 에서만 의미가 있다.
  /// - `false` (기본): 기존 동작. 광고 화면을 rootViewController 위에 띄운다.
  /// - `true`: 현재 최상단에 present 된 화면 위에 띄운다.
  ///
  /// 럭키이벤트 웹뷰의 `ad_join` 스킴 콜백처럼 **다른 화면이 이미 present 된 상태**에서
  /// 호출하면 rootViewController 의 view 가 window 계층에서 빠져 있어
  /// `Attempt to present ... whose view is not in the window hierarchy` 로 표시에 실패한다.
  /// 이때도 콜백은 성공으로 떨어지므로 호출부에서는 실패를 알 수 없다.
  /// 그런 경로에서는 `true` 를 넘길 것.
  /// [fullscreen] 는 iOS 전용. 광고 화면의 모달 표시 방식을 결정한다.
  /// - `false` (기본): `pageSheet`. 아래에서 올라오는 바텀시트 형태로 표시된다.
  /// - `true`: `overFullScreen`. 화면 전체를 덮는다.
  Future<String?> adJoin(int appId,
      [int actionId = 0,
      bool useTopViewController = false,
      bool fullscreen = false]) {
    return TnkFlutterRwdPlatform.instance
        .adJoin(appId, actionId, useTopViewController, fullscreen);
  }

  Future<String?> adAction(int appId, [int actionId = 0]) {
    return TnkFlutterRwdPlatform.instance.adAction(appId, actionId);
  }

  Future<String?> setPubCustomUi([int type = 0]) {
    return TnkFlutterRwdPlatform.instance.setPubCustomUi(type);
  }

  Future<String?> showEventWebPage(HashMap<String, String> map) {
    return TnkFlutterRwdPlatform.instance.showEventWebPage(map);
  }

  Future<String?> showMyEarnPointList(HashMap<String, dynamic>? map) {
    return TnkFlutterRwdPlatform.instance.showMyEarnPointList(map);
  }

  Future<String?> nativeTnkEventScheme(String url) {
    return TnkFlutterRwdPlatform.instance.nativeTnkEventScheme(url);
  }

  Future<String?> openTnkEventScheme(String url) async {
    if (url.startsWith("tnkscheme://")) {
      if (url.contains("offerwall")) {
        Uri uri = Uri.parse(url);
        String title = uri.queryParameters['title'] ?? "무료충전소";
        showAdList(title);
        return "success";
      }
      return TnkFlutterRwdPlatform.instance.nativeTnkEventScheme(url);
    } else {
      return "fail";
    }
  }

  final methodChannel = const MethodChannel('tnk_flutter_rwd');

  Future<String?> openTnkEventScheme2(String url) async {
    if (url.startsWith("tnkscheme://")) {
      if (url.contains("offerwall")) {
        Uri uri = Uri.parse(url);
        String title = uri.queryParameters['title'] ?? "무료충전소";
        showAdList(title);
        return "success";
      } else if (Uri.parse(url).host == "analytics") {
        Uri uri = Uri.parse(url);
        Map<String, String> properties = Map.from(uri.queryParameters);
        jsonEncode(properties);
        methodChannel.invokeMethod("tnk_flutter_rwd", jsonEncode(properties));
      }

      return TnkFlutterRwdPlatform.instance.nativeTnkEventScheme(url);
    } else {
      return "fail";
    }
  }

  Future<String?> showAdListWithPlacement(String placementId, int categoryId, int filterId) {
    return TnkFlutterRwdPlatform.instance.showAdListWithPlacement(placementId, categoryId, filterId);
  }
}

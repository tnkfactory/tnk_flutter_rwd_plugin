

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tnk_flutter_rwd_platform_interface.dart';

/// An implementation of [TnkFlutterRwdPlatform] that uses method channels.
class MethodChannelTnkFlutterRwd extends TnkFlutterRwdPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tnk_flutter_rwd');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  @override
  Future<String?> showAdList(String title, [int appId = 0]) async {
    final version = await methodChannel.invokeMethod<String>('showAdList', <String, dynamic>{ "title": title, "app_id": appId });
    return version;
  }
  @override
  Future<String?> openEventWebView(int eventId) async {
    final version = await methodChannel.invokeMethod<String>('openEventWebView', <String, dynamic>{"eventId" :eventId});
    return version;
  }
  @override
  Future<String?> showCustomTapActivity(String url, String deep_link) async {
    final version = await methodChannel.invokeMethod<String>('showCustomTapActivity', <String, dynamic>{ "url": url, "deep_link": deep_link });
    return version;
  }
  @override
  Future<String?> setCategoryAndFilter(int category, int filter) async {
    final version = await methodChannel.invokeMethod<String>('setCategoryAndFilter', <String, dynamic>{ "category": category, "filter": filter });
    return version;
  }
  @override
  Future<String?> setUserName(String userName) async {

    // if( userName == null || userName.isEmpty ) {
    //   print( "User name cannot be null or empty.. your userName = $userName" );
    //   // throw ArgumentError("User name cannot be null or empty");
    //   final version = await methodChannel.invokeMethod<String>('setUserName', <String, dynamic>{"user_name":userName});
    // } else {
    //   final version = await methodChannel.invokeMethod<String>('setUserName', <String, dynamic>{"user_name":userName});
    //   return version;
    // }

    final version = await methodChannel.invokeMethod<String>('setUserName', <String, dynamic>{"user_name":userName});
    return version;


  }
  @override
  Future<String?> setCOPPA(bool coppa) async {
    final version = await methodChannel.invokeMethod<String>('setCOPPA', <String, dynamic>{"coppa":coppa});
    return version;
  }
  @override
  Future<String?> showATTPopup() async {
    final version = await methodChannel.invokeMethod<String>('showATTPopup', <String, dynamic>{"att show":"att show"});
    return version;
  }
  @override
  Future<int?> getEarnPoint() async{
    final point = await methodChannel.invokeMethod<int>('getEarnPoint', <int, dynamic>{});
    return point;
  }
  @override
  Future<String?>setNoUsePointIcon () async {
    final version = await methodChannel.invokeMethod<String>('setNoUsePointIcon', <String, dynamic>{});
    return version;
  }
  @override
  Future<String?>setNoUsePrivacyAlert() async {
    final version = await methodChannel.invokeMethod<String>('setNoUsePrivacyAlert', <String,dynamic>{});
    return version;
  }
  @override
  Future<int?>getQueryPoint() async {
    final point = await methodChannel.invokeMethod<int>('getQueryPoint', <int,dynamic>{});
    return point;
  }
  @override
  Future<String?>purchaseItem(String itemId, int cost) async {
    final version =  await methodChannel.invokeMethod<String>('purchaseItem', <String, dynamic>{"item_id" : itemId, "cost" : cost});
    return version;
  }
  @override
  Future<String?>withdrawPoints(String description) async {
    final version = await methodChannel.invokeMethod<String>('withdrawPoints', <String, dynamic>{"description" :description});
    return version;
  }
  @override
  Future<String?>setCustomUI(HashMap<String,String> colorMap) async {
    final version = await methodChannel.invokeMethod<String>('setCustomUI', <String, dynamic>{"map" :colorMap});
    return version;
  }

  @override
  Future<String?> getPlacementJsonData(String placementId) async {
    final version = await methodChannel.invokeMethod<String>('getPlacementJsonData', <String, dynamic>{"placement_id":placementId});
    return version;
  }
  @override
  Future<String?> onItemClick(String app_id) async {
    final version = await methodChannel.invokeMethod<String>('onItemClick', <String, dynamic>{"app_id":app_id});
    return version;
  }
  @override
  Future<String?> setUseTermsPopup(bool isUse) async {
    final version = await methodChannel.invokeMethod<String>('setUseTermsPopup', <String, dynamic>{"is_use":isUse});
    return version;
  }

  @override
  Future<String?>setCustomUnitIcon(HashMap<String,String> map) async {
    final version = await methodChannel.invokeMethod<String>('setCustomUnitIcon', <String, dynamic>{"map" :map});
    return version;
  }
  @override
  Future<String?>closeAllView() async {
    final version = await methodChannel.invokeMethod<String>('closeAllView');
    return version;
  }
  @override
  Future<String?>closeOfferwall() async {
    final version = await methodChannel.invokeMethod<String>('closeOfferwall');
    return version;
  }
  @override
  Future<String?>closeAdDetail() async {
    final version = await methodChannel.invokeMethod<String>('closeAdDetail');
    return version;
  }

  @override
  Future<String?>setCustomUIDefault(HashMap<String,String> map) async {
    final version = await methodChannel.invokeMethod<String>('setCustomUIDefault', <String, dynamic>{"map" :map});
    return version;
  }

  @override
  Future<String?> presentAdDetailView(int appId, [int actionId = 0]) async {
    final version = await methodChannel.invokeMethod<String>('presentAdDetailView', <String, dynamic>{"app_id": appId, "action_id": actionId});
    return version;
  }

  @override
  Future<String?> adJoin(int appId, [int actionId = 0]) async {
    final version = await methodChannel.invokeMethod<String>('adJoin', <String, dynamic>{"app_id": appId, "action_id": actionId});
    return version;
  }

  @override
  Future<String?> adAction(int appId, [int actionId = 0]) async {
    final version = await methodChannel.invokeMethod<String>('adAction', <String, dynamic>{"app_id": appId, "action_id": actionId});
    return version;
  }

  @override
  Future<String?> setPubCustomUi([int type = 0]) async {
    final version = await methodChannel.invokeMethod<String>('setPubCustomUi', <String, dynamic>{"type": type});
    return version;
  }

}

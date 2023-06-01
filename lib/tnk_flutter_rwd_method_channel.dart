

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
  Future<String?> showAdList(String title) async {
    final version = await methodChannel.invokeMethod<String>('showAdList', <String, dynamic>{ "title": title });
    return version;
  }
  @override
  Future<String?> setUserName(String userName) async {
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
  Future<String?>setNoUseUsePointIcon () {
    final version = methodChannel.invokeMethod<String>('setNoUseUsePointIcon', <String, dynamic>{});
    return version;
  }
  @override
  Future<String?>setNoUsePrivacyAlert() {
    final version = methodChannel.invokeMethod<String>('setNoUsePrivacyAlert', <String,dynamic>{});
    return version;
  }
}



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

  Future<String?> showAdList(String title) {
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
}

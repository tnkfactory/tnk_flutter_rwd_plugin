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
  Future<String?> showAdList() {
    throw UnimplementedError('showAdList() has not been implemented.');
  }
}

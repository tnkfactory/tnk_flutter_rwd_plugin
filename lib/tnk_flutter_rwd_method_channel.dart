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
  Future<String?> showAdList() async {
    final version = await methodChannel.invokeMethod<String>('showAdList');
    return version;
  }
}


import 'tnk_flutter_rwd_platform_interface.dart';

class TnkFlutterRwd {
  Future<String?> getPlatformVersion() {
    return TnkFlutterRwdPlatform.instance.getPlatformVersion();
  }
  Future<String?> showAdList() {
    return TnkFlutterRwdPlatform.instance.showAdList();
  }
}

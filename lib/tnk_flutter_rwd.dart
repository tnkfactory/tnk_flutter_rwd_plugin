
import 'tnk_flutter_rwd_platform_interface.dart';

class TnkFlutterRwd {
  Future<String?> getPlatformVersion() {
    return TnkFlutterRwdPlatform.instance.getPlatformVersion();
  }
  Future<String?> showAdList(String title) {
    return TnkFlutterRwdPlatform.instance.showAdList(title);
  }
  Future<String?> setUserName(String user_name) {
    return TnkFlutterRwdPlatform.instance.setUserName(user_name);
  }
  Future<String?> setCOPPA(bool coppa) {
    return TnkFlutterRwdPlatform.instance.setCOPPA(coppa);
  }
}

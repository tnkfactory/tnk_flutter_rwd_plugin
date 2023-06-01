


import 'tnk_flutter_rwd_platform_interface.dart';

class TnkFlutterRwd {
  Future<String?> getPlatformVersion() {
    return TnkFlutterRwdPlatform.instance.getPlatformVersion();
  }
  Future<String?> showAdList(String title) {
    return TnkFlutterRwdPlatform.instance.showAdList(title);
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
  Future<String?> setNoUseUsePointIcon() {
    return TnkFlutterRwdPlatform.instance.setNoUseUsePointIcon();
  }
  Future<String?> setNoUsePrivacyAlert() {
    return TnkFlutterRwdPlatform.instance.setNoUsePrivacyAlert();
  }

}

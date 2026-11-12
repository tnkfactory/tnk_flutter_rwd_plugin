import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'package:tnk_flutter_rwd/tnk_placement_model.dart';

class OfferwallItem extends StatefulWidget {
  const OfferwallItem({super.key});

  @override
  State<StatefulWidget> createState() => _OfferwallItem();
}

class _OfferwallItem extends State<OfferwallItem> with WidgetsBindingObserver {
  final _tnkFlutterRwdPlugin = TnkFlutterRwd();
  // final _tnkRwdNVadPlugin = TnkRwdNVad();

  final String _itemId = "item.0001";
  final int _cost = 2;

  int _myPoint = 0;
  int _queryPoint = 0;

  String _tnkResult = 'Unknown';
  // 오퍼월 화면 설정 (오퍼월을 열기 전에 지정하면 다음 표시부터 반영된다)
  String _theme = 'system'; // 'system' | 'light' | 'dark'
  bool _opaqueBar = true; // 불투명 앱바 (iOS 전용). SDK 기본값(불투명)과 맞춘다
  String? _barColor; // null = 기본색(목록 배경색), 아니면 '#RRGGBB'

  List<TnkPlacementAdItem> adList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // showAdList();
    showATTPopup();
    loadOfferwallTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 12),
                _buildScreenSettingsCard(),
                const SizedBox(height: 16),
                _buildButtonSections(),
              ],
            ),
          ),
          _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('결과', _tnkResult),
            const Divider(),
            _buildInfoRow('적립 가능한 포인트', '$_myPoint'),
            const Divider(),
            _buildInfoRow('내 포인트', '$_queryPoint'),
          ],
        ),
      ),
    );
  }

  /// 오퍼월 화면 설정 카드: 불투명 앱바(iOS 전용) 스위치 / 앱바 색 / 테마.
  Widget _buildScreenSettingsCard() {
    const color = Colors.teal;
    final isIOS = Platform.isIOS;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오퍼월 화면 설정',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(isIOS ? '불투명 앱바 (iOS)' : '불투명 앱바 (iOS 전용)'),
              subtitle: isIOS ? null : const Text('Android 에서는 적용되지 않습니다'),
              value: _opaqueBar,
              onChanged: (on) => setOpaqueNavBar(on, color: _barColor),
            ),
            Row(
              children: [
                const Text('앱바 색  '),
                Expanded(
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'default', label: Text('기본')),
                      ButtonSegment(value: '#FFF3E0', label: Text('#FFF3E0')),
                    ],
                    selected: {_barColor ?? 'default'},
                    // 불투명이 꺼져 있으면 색은 쓰이지 않으므로 비활성
                    onSelectionChanged: _opaqueBar
                        ? (v) => setOpaqueNavBar(true, color: v.first == 'default' ? null : v.first)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('테마  '),
                Expanded(
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'system', label: Text('시스템')),
                      ButtonSegment(value: 'light', label: Text('라이트')),
                      ButtonSegment(value: 'dark', label: Text('다크')),
                    ],
                    selected: {_theme},
                    onSelectionChanged: (v) => setOfferwallTheme(v.first),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildButtonSections() {
    return Column(
      children: [
        _buildSection('포인트 조회', Colors.blue, [
          {'label': '내 포인트', 'onPressed': getQueryPoint},
          {'label': '적립가능한 포인트', 'onPressed': getEarnPoint},
          {'label': '적립내역', 'onPressed': showMyEarnPoint},
        ]),
        const SizedBox(height: 16),
        _buildSection('포인트 사용', Colors.red, [
          {'label': '테스트구매', 'onPressed': () => purchaseItem(_itemId, _cost)},
          {'label': '테스트인출', 'onPressed': () => withdrawPoints("테스트 인출")},
          {'label': '광고상세 진입', 'onPressed': () => presentAdDetailView(809977)},
          {'label': 'ATT', 'onPressed': showATTPopup},
        ]),
        const SizedBox(height: 16),
        _buildSection('광고 이벤트', Colors.purple, [
          {'label': 'Ad Join', 'onPressed': () => adJoin(227796)},
          {'label': 'Ad Action', 'onPressed': () => adAction(227796)},
          {'label': 'Custom UI', 'onPressed': () => setPubCustomUi(1)},
          {'label': 'Show Event', 'onPressed': () {
            final eventId = Platform.isIOS ? "908671" : "908670";
            showEventPage(eventId);
          }},
          {'label': 'No Privacy Alert', 'onPressed': setNoUsePrivacyAlert},
        ]),
        const SizedBox(height: 16),
        _buildSection('기타', Colors.green, [
          {'label': 'RV Event Call', 'onPressed': openEventWebView},
        ]),
      ],
    );
  }

  Widget _buildSection(
    String title,
    Color color,
    List<Map<String, dynamic>> buttons,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: buttons
                  .map((btn) => _buildButton(
                        btn['label'] as String,
                        btn['onPressed'] as VoidCallback,
                        color,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildFloatingButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton.extended(
        // 기본 오퍼월을 연다. 매체 전용 UI(iOS setPubCustomUi)를 보려면 '광고 이벤트 > Custom UI' 를 누른 뒤 이 버튼을 누른다.
        // (iOS 는 Custom UI 설정이 앱을 다시 시작할 때까지 유지된다. 전용 UI 를 한 번에 여는 예제는 setCustomUiAndShowOfferwall)
        onPressed: showAdList,
        // onPressed: showAdListWithPlacement,
        icon: const Icon(Icons.tv),
        label: const Text('오퍼월'),
      ),
    );
  }


  /// 오퍼월 테마를 지정하고, 실제로 적용된 값을 읽어 화면에 반영한다.
  Future<void> setOfferwallTheme(String theme) async {
    try {
      await _tnkFlutterRwdPlugin.setOfferwallTheme(theme);
      await loadOfferwallTheme();
      _showResult('테마: $theme');
    } on PlatformException catch (e) {
      _showResult('테마 오류: $e');
    }
  }

  /// 오퍼월 앱바 불투명 옵션과 색을 지정한다. (iOS 전용, Android 는 아무 일도 하지 않는다)
  Future<void> setOpaqueNavBar(bool opaque, {String? color}) async {
    try {
      await _tnkFlutterRwdPlugin.setOfferwallOpaqueNavigationBar(opaque, color: color);
      if (!mounted) return;
      setState(() {
        _opaqueBar = opaque;
        _barColor = color;
      });
      _showResult('불투명 앱바: ${opaque ? '켬 ${color ?? '(기본색)'}' : '끔'}');
    } on PlatformException catch (e) {
      _showResult('앱바 오류: $e');
    }
  }

  void _showResult(String text) {
    if (!mounted) return;
    setState(() {
      _tnkResult = text;
    });
  }

  Future<void> loadOfferwallTheme() async {
    try {
      final theme = await _tnkFlutterRwdPlugin.getOfferwallTheme() ?? 'unspecified';
      if (!mounted) return;
      setState(() {
        // iOS 에서 unspecified 는 system 과 똑같이 동작하므로 '시스템'으로 표시한다.
        _theme = theme == 'unspecified' ? 'system' : theme;
      });
    } on PlatformException catch (e) {
      _showResult('테마 오류: $e');
    }
  }

  Future<void> showAdListWithPlacement() async {
    try {

      String? result = await _tnkFlutterRwdPlugin.showAdListWithPlacement("cps_only",4, 509); // 카테고리 영역 없이 filter -> 제휴몰 노출
      // String? result = await _tnkFlutterRwdPlugin.showAdListWithPlacement("",0, 0);  // 카테고리 영역과 filter 모두 노출
      print(result);

    } on Exception catch(e) {
      print(e);
      return;
    }
  }

  /**
   * 오퍼월 커스텀 UI 설정 후 호출 예제
   */
  Future<void> setCustomUiAndShowOfferwall() async {

    try {

      await _tnkFlutterRwdPlugin.setNoUsePrivacyAlert(); // 개인정보 수집 동의 팝업 제거
      await _tnkFlutterRwdPlugin.setPubCustomUi(1); // 매체 커스텀 UI 설정
      await _tnkFlutterRwdPlugin.setCOPPA(false); // COPPA 설정
      await _tnkFlutterRwdPlugin.setUserName("skt_air_test_user"); // user name 설정

      // _tnkFlutterRwdPlugin.setCategoryAndFilter(2, 0);
      String? result = await _tnkFlutterRwdPlugin.showAdList("오퍼월상단타이틀"); // 오퍼월 호출

      print(result);

    } on Exception catch (e) {
      print(e);
      return;
    }

  }


  /**
   * 특정 이벤트 페이지 호출 예제
   */
  Future<void> showEventPage(String eventId) async {
    try {
      HashMap<String, String> paramMap = HashMap();
      paramMap.addAll({
        "event_id": eventId,
      });
      String? result = await _tnkFlutterRwdPlugin.showEventWebPage(paramMap);
      print(result);

    } on Exception {
      return;
    }

  }



  Future<void> setNoUsePrivacyAlert() async {
    try {
      await _tnkFlutterRwdPlugin.setNoUsePrivacyAlert();
    } on Exception {
      return;
    }
  }









  Future<void> showAdList() async {
    String platformVersion;

    try {
      await _tnkFlutterRwdPlugin.setUserName("testUser"); // 매체의 사용자 식별값을 넣는다
      await _tnkFlutterRwdPlugin.setCOPPA(false);

      // _tnkFlutterRwdPlugin.setUseTermsPopup(true);
      // 특정 탭으로 열려면 오퍼월을 열기 전에 지정한다. 예) 쇼핑 탭: setCategoryAndFilter(4, 0)
      platformVersion = await _tnkFlutterRwdPlugin.showAdList("미션 수행하기") ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // sleepAndClose();
    if (!mounted) return;

    setState(() {
      _tnkResult = platformVersion;
    });
  }

  Future<void> getQueryPoint() async {
    int point;
    try {
      point = await _tnkFlutterRwdPlugin.getQueryPoint() ?? 0;
    } on PlatformException {
      point = 0;
    }
    print("getQueryPoint : $point");

    setState(() {
      _queryPoint = point;
    });
  }

  Future<void> getEarnPoint() async {
    int point;
    try {
      point = await _tnkFlutterRwdPlugin.getEarnPoint() ?? 0;
    } on PlatformException {
      point = 0;
    }

    setState(() {
      _myPoint = point;
    });
  }

  Future<void> showMyEarnPoint() async {
    try {

      await _tnkFlutterRwdPlugin.setUserName("skt_air_test_user"); // user name 설정 필요
      HashMap<String,dynamic> paramMap = HashMap();
      paramMap.addAll({
        "type": 1
      });

      String? result = await _tnkFlutterRwdPlugin.showMyEarnPointList(paramMap);
      print(result);
    } on PlatformException {
      return;
    }
  }

  Future<void> onAdItemClick(String appId) async {
    try {
      await _tnkFlutterRwdPlugin.onItemClick(appId);
      // sleep(const Duration(seconds:5));
      // _tnkFlutterRwdPlugin.closeAdDetail();

      // sleep(const Duration(seconds: 10));
      // 화면 닫기는 iOS 전용이다(Android 는 "fail" 을 반환한다)
      if (Platform.isIOS) {
        _tnkFlutterRwdPlugin.closeAdDetail();
        _tnkFlutterRwdPlugin.closeOfferwall();
      }
    } on Exception {
      return;
    }
  }

  Future<void> getJsonAdList() async {
    try {
      String? placementData =
      await _tnkFlutterRwdPlugin.getPlacementJsonData("offer_nor");
      // _tnkFlutterRwdPlugin.setUseTermsPopup(false);

      if (placementData != null) {
        Map<String, dynamic> jsonObject = jsonDecode(placementData);
        String resCode = jsonObject["res_code"];
        // String resMessage = jsonObject["res_message"];

        if (resCode == "1") {
          List<TnkPlacementAdItem> adList =
          praserJsonToTnkPlacementAdItem(jsonObject["ad_list"]);

          setState(() {
            this.adList.addAll(adList);
            // _tnkResult = placementData ?? "null";
          });
        } else {
          // 광고 로드 실패
        }
      }
    } on PlatformException catch (e) {
      print(e.stacktrace);
      setState(() {
        _tnkResult = "excetpion";
      });
      return;
    }
  }

  Future<void> purchaseItem(String itemId, int cost) async {
    try {
      await _tnkFlutterRwdPlugin.purchaseItem(itemId, cost);
    } on Exception {
      return;
    }
  }

  Future<void> withdrawPoints(String description) async {
    try {
      await _tnkFlutterRwdPlugin.withdrawPoints(description);
    } on Exception {
      return;
    }
  }


  Future<void> presentAdDetailView(int appId) async {
    try {
      await _tnkFlutterRwdPlugin.setUserName("dongyoon");
      String? result = await _tnkFlutterRwdPlugin.presentAdDetailView(appId);
      print("jameson result : " + result!);
    } on Exception {
      return;
    }
  }

  Future<void> adJoin(int appId) async {
    try {
      await _tnkFlutterRwdPlugin.setUserName("dongyoon");
      String? result = await _tnkFlutterRwdPlugin.adJoin(appId);
      print("jameson result : " + result!);
    } on Exception {
      return;
    }
  }

  Future<void> adAction(int appId) async {
    try {
      await _tnkFlutterRwdPlugin.setUserName("dongyoon");
      String? result = await _tnkFlutterRwdPlugin.adAction(appId);
      print("jameson result : " + result!);
    } on Exception {
      return;
    }
  }


  Future<void> showATTPopup() async {
    try {
      await _tnkFlutterRwdPlugin.showATTPopup();
    } on Exception {
      return;
    }
  }

  Future<void> setUserName() async {
    try {
      String? result = await _tnkFlutterRwdPlugin.setUserName("newTestUser");
      print(result);
    } on Exception {
      return;
    }
  }


  Future<void> setPubCustomUi([int type = 0]) async {
    try {
      String? result = await _tnkFlutterRwdPlugin.setPubCustomUi(type);
      print(result);
    } on Exception {
      return;
    }
  }


  Future<void> openEventWebView() async {
    _tnkFlutterRwdPlugin.setCOPPA(false);
    _tnkFlutterRwdPlugin.setUserName("testUser");
    _tnkFlutterRwdPlugin.openEventWebView(1234);
    // _tnkFlutterRwdPlugin.setUserTermsAgree(true);
  }

}

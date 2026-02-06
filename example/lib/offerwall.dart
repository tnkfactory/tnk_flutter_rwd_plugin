import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'package:tnk_flutter_rwd/tnk_placement_model.dart';
// import 'package:tnk_rwd_n_vad/tnk_rwd_n_vad.dart';

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

  List<TnkPlacementAdItem> adList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    // showAdList();
    showATTPopup();
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
                const SizedBox(height: 24),
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
            final eventId = Platform.isIOS ? "814278" : "814139";
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
        onPressed: setCustomUiAndShowOfferwall,
        icon: const Icon(Icons.tv),
        label: const Text('오퍼월'),
      ),
    );
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
      // await _tnkFlutterRwdPlugin.setUserName("jameson");
      await _tnkFlutterRwdPlugin.setCOPPA(false);

      // _tnkFlutterRwdPlugin.setUseTermsPopup(true);
      // _tnkFlutterRwdPlugin.setCategoryAndFilter(4, 0);
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

  Future<void> onAdItemClick(String appId) async {
    try {
      await _tnkFlutterRwdPlugin.onItemClick(appId);
      // sleep(const Duration(seconds:5));
      // _tnkFlutterRwdPlugin.closeAdDetail();

      // sleep(const Duration(seconds: 10));
      _tnkFlutterRwdPlugin.closeAdDetail();
      _tnkFlutterRwdPlugin.closeOfferwall();
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
        String resMessage = jsonObject["res_message"];

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
    // _tnkRwdNVadPlugin.setCOPPA(false);
    // _tnkRwdNVadPlugin.setUserName("tnk_test");
    // _tnkRwdNVadPlugin.openEventWebView(1234,"asdf");
  }

}

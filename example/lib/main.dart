import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'package:tnk_flutter_rwd_example/tnk_flutter_rwd_point_effect.dart';
import 'tnk_flutter_rwd_analytics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver // 앱 상태변화를 감지하기 위한 observer 사용
{
  final _tnkFlutterRwdPlugin = TnkFlutterRwd();

  @override
  void initState() {
    MethodChannel channel = const MethodChannel('tnk_flutter_rwd');
    channel.setMethodCallHandler(getOfferWallEvent);

    WidgetsBinding.instance.addObserver(this);// 앱 상태변화를 감지하기 위한 observer 등록
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);// 앱 상태변화를 감지하기 위한 observer 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.resumed) {
      // 앱이 활성화 될때
      print('앱이 활성화 될때');
      _tnkFlutterRwdPlugin.closeAdDetail();
      _tnkFlutterRwdPlugin.closeOfferwall();
    } else if (state == AppLifecycleState.inactive) {
      // 앱이 비활성화 될때
      print('앱이 비활성화 될때');
    } else if (state == AppLifecycleState.paused) {
      // 앱이 일시정지 될때
      print('앱이 일시정지 될때');
    } else if (state == AppLifecycleState.detached) {
      // 앱이 종료될때
      print('앱이 종료될때');
    }
  }


  String _tnkResult = 'Unknown';
  int _myPoint = 0;
  int _queryPoint = 0;
  final String _itemId = "item.0001";
  final int _cost = 2;

  int _selectedIndex = 0;


  Future<void> getOfferWallEvent(MethodCall methodCall) async {
    if (TnkMethodChannelEvent.didOfferwallRemoved(methodCall)) {
      // TODO 오퍼월 close callback
      print("offer window closed");


    }

    setState(() {
      _tnkResult = methodCall.arguments;
    });
  }

  Future<void> showAdList() async {
    String platformVersion;

    try {
      await _tnkFlutterRwdPlugin.setUserName("testUser");
      await _tnkFlutterRwdPlugin.setCOPPA(false);

      _tnkFlutterRwdPlugin.setUseTermsPopup(false);
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

  Future<void> sleepAndClose() async {
    sleep(const Duration(seconds: 10));
    _tnkFlutterRwdPlugin.closeAdDetail();
    _tnkFlutterRwdPlugin.closeOfferwall();
  }

  Future<void> showATTPopup() async {
    try {
      await _tnkFlutterRwdPlugin.showATTPopup();
    } on Exception {
      return;
    }
  }

  Future<void> getEarnPoint() async {
    int point;
    try {
      point = await _tnkFlutterRwdPlugin.getEarnPoint() ?? 0;
    } on PlatformException {
      point = 0;
    }

    // setState(() {
    //   _myPoint = point;
    // });
  }

  Future<void> test() async {
    try {
      String? placementData =
          await _tnkFlutterRwdPlugin.getPlacementJsonData("offer_nor");
      _tnkFlutterRwdPlugin.setUseTermsPopup(false);

      if (placementData != null) {
        Map<String, dynamic> jsonObject = jsonDecode(placementData);
        String resCode = jsonObject["res_code"];
        String resMessage = jsonObject["res_message"];
        List<TnkPlacementAdItem> adList =
            praserJsonToTnkPlacementAdItem(jsonObject["ad_list"]);

        setState(() {
          this.adList.addAll(adList);
          // _tnkResult = placementData ?? "null";
        });
      }
    } on PlatformException {
      setState(() {
        _tnkResult = "excetpion";
      });
      return;
    }
  }

  // praser json to List<TnkPlacementAdItem>
  List<TnkPlacementAdItem> praserJsonToTnkPlacementAdItem(
      List<dynamic> adList) {
    List<TnkPlacementAdItem> tnkPlacementAdItemList = [];
    for (var adItem in adList) {
      TnkPlacementAdItem tnkPlacementAdItem = TnkPlacementAdItem();
      tnkPlacementAdItem.app_id = adItem["app_id"];
      tnkPlacementAdItem.app_nm = adItem["app_nm"];
      tnkPlacementAdItem.img_url = adItem["img_url"];
      tnkPlacementAdItem.pnt_amt = adItem["pnt_amt"];
      tnkPlacementAdItem.org_amt = adItem["org_amt"];
      tnkPlacementAdItem.pnt_unit = adItem["pnt_unit"];
      tnkPlacementAdItem.prd_price = adItem["prd_price"];
      tnkPlacementAdItem.org_prd_price = adItem["org_prd_price"];
      tnkPlacementAdItem.sale_dc_rate = adItem["sale_dc_rate"];
      tnkPlacementAdItem.multi_yn = adItem["multi_yn"];
      tnkPlacementAdItem.cmpn_type = adItem["cmpn_type"];
      tnkPlacementAdItem.cmpn_type_name = adItem["cmpn_type_name"];
      tnkPlacementAdItem.like_yn = adItem["like_yn"];

      tnkPlacementAdItemList.add(tnkPlacementAdItem);
    }

    return tnkPlacementAdItemList;
  }
  Future<void> onAdItemClick(String appId) async {
    try {
      await _tnkFlutterRwdPlugin.onItemClick(appId);
      // sleep(const Duration(seconds:5));
      // _tnkFlutterRwdPlugin.closeAdDetail();

      sleep(const Duration(seconds: 10));
      _tnkFlutterRwdPlugin.closeAdDetail();
      _tnkFlutterRwdPlugin.closeOfferwall();
    } on Exception {
      return;
    }
  }
  Future<void> setNoUsePointIcon() async {
    try {
      await _tnkFlutterRwdPlugin.setNoUsePointIcon();
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

  Future<void> getQueryPoint() async {
    int point;
    try {
      point = await _tnkFlutterRwdPlugin.getQueryPoint() ?? 0;
    } on PlatformException {
      point = 0;
    }

    // setState(() {
    //   _queryPoint = point;
    // });
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

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return const AlertDialog(
            title: Text("abc"),
            content: Text(' 항목을 선택했습니다.'),
          );
        });
  }

  Future<void> setCustomUI() async {
    try {
      HashMap<String, String> paramMap = HashMap();
      //0xff252542
      paramMap.addAll({
        // 카테고리 컬러
        "category_select_font": "#26DACA",
        // 선택된 필터 배경색
        "filter_select_background": "#26DACA",
        // 선택된 필터 폰트 컬러
        "filter_select_font": "#FFFFFF",
        // 선택안한 필터 폰트 컬러
        "filter_not_select_font": "#515151",
        // 선택안한 필터 배경색
        "filter_not_select_background": "#FFFFFF",
        // 광고상세페이지 광고타이틀 폰트 컬러
        "adinfo_title_font": "#161A1B",
        // 광고상세페이지 광고액션 폰트 컬러
        "adinfo_desc_font": "#26DACA",
        // 광고상세페이지 포인트 단위 컬러
        "adinfo_point_unit_font": "#26DACA",
        // 광고상세페이지 포인트 액수 폰트 컬러
        "adinfo_point_amount_font": "#26DACA",
        // 광고상세페이지 버튼 백그라운드 컬러
        "adinfo_button_background": "#26DACA",
        // 광고상세페이지 버튼 폰트 컬러
        "adinfo_button_title_font": "#FFFFFF",
        // 광고상세페이지 버튼 백그라운드 컬러
        "adinfo_button_desc_font": "#FFFFFF",
        "adinfo_button_gradient_option": "L",
        // 광고리스트 광고타이틀 폰트 컬러
        "adlist_title_font":"#161A1B",
        // 광고리스트 광고액션 폰트 컬러
        "adlist_desc_font":"#515151",
        // 광고리스트 포인트 단위 폰트 컬러
        "adlist_point_unit_font":"##26DACA",
        // 광고리스트 포인트 액수 폰트 컬러
        "adlist_point_amount_font":"##26DACA",


        // 1 - 재화 아이콘, 단위 둘다 표시
        // 2 - 재화 아이콘만 표시
        // 3 - 재화 단위만 표시
        // 4 - 둘다 표시 안함
        "option":"1",

        // 포인트 아이콘 이미지 이름
        "point_icon_name":"star_icon",
        "point_icon_name_sub":"star_icon_white"

      });
      await _tnkFlutterRwdPlugin.setCustomUIDefault(paramMap);
    } on Exception {
      return;
    }
  }

  Future<void> useCustomIcon() async {
    return setCustomUnitIcon(TnkFlutterRwdPointEffectType.ICON);
  }
  Future<void> useCustomIconAndUnit() async {
    return setCustomUnitIcon(TnkFlutterRwdPointEffectType.ICON_N_UNIT);
  }
  Future<void> useUnit() async {
    return setCustomUnitIcon(TnkFlutterRwdPointEffectType.UNIT);
  }
  Future<void> useEffectNone() async {
    return setCustomUnitIcon(TnkFlutterRwdPointEffectType.NONE);
  }



  Future<void> setCustomUnitIcon(String type) async {
    try {
      HashMap<String, String> paramMap = HashMap();
      paramMap.addAll({

        // 1 - 재화 아이콘, 단위 둘다 표시
        // 2 - 재화 아이콘만 표시
        // 3 - 재화 단위만 표시
        // 4 - 둘다 표시 안함
        "option":"2",


        // 포인트 아이콘 이미지 이름
        // "point_icon_name":"star_icon",
        // "point_icon_name_sub":"star_icon_white"
      });
      await _tnkFlutterRwdPlugin.setCustomUnitIcon(paramMap);

    } on Exception {
      return;
    }
  }






  var datas = {1, 2, 3};
  List<TnkPlacementAdItem> adList = [];

  @override
  Widget build(BuildContext context) {
    List<DataRow> cells = [];
    cells = adList
        .map((e) => DataRow(cells: [
              DataCell(Container(
                  width: 70, //SET width
                  child: Image(image: NetworkImage(e.img_url), width: 70,)), onLongPress: () {
                onAdItemClick(e.app_id.toString());
              },),
              DataCell(Text(e.app_nm,),),
              DataCell(Text(e.pnt_amt.toString())),
            ]))
        .toList();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter RWD Plugin'),
          actions: [
            IconButton(
                onPressed: () {
                  // setNoUsePointIcon();
                  setCustomUI();
                },
                icon: const Icon(Icons.dashboard_customize))
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                ),
                accountName: Text("tnkfactory"),
                accountEmail: Text('flutter@tnkfactory.com'),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0))),
              ),
              ListTile(
                leading: const Icon(
                  Icons.tv,
                  color: Colors.blueGrey,
                ),
                title: const Text('OfferWall'),
                onTap: () => "aaa",
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                DataTable(
                  columns: const [
                    DataColumn(label: Text('img')),
                    DataColumn(label: Text('title')),
                    DataColumn(label: Text('point')),
                  ],
                  rows: cells,
                  // rows: [
                  //   DataRow(cells: [
                  //     DataCell(Text(_tnkResult)),
                  //     DataCell(Text('$_myPoint')),
                  //     DataCell(Text('$_queryPoint')),
                  //   ]),
                  // ],
                ),
              ]),
              ButtonBar(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () { test();},
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                            shadowColor: Colors.redAccent,
                            elevation: 5),
                        child: const Text("TEST"),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            test();
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                              shadowColor: Colors.blueAccent,
                              elevation: 10),
                          child: const Text('적립가능한 포인트')),
                      ElevatedButton(
                          onPressed: () {
                            getQueryPoint();
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                              shadowColor: Colors.blueAccent,
                              elevation: 10),
                          child: const Text('사용가능한 포인트')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            purchaseItem(_itemId, _cost);
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                              shadowColor: Colors.redAccent,
                              elevation: 10),
                          child: const Text('테스트구매')),
                      ElevatedButton(
                          onPressed: () {
                            withdrawPoints("테스트 인출");
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                              shadowColor: Colors.redAccent,
                              elevation: 10),
                          child: const Text('테스트인출')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: showATTPopup,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              shadowColor: Colors.grey,
                              elevation: 10),
                          child: const Text('ATT Popup')),
                      ElevatedButton(
                          onPressed: setNoUsePointIcon,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              shadowColor: Colors.grey,
                              elevation: 10),
                          child: const Text('포인트아이콘 사용안함')),
                      ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.amberAccent,
                              shadowColor: Colors.amberAccent,
                              elevation: 10),
                          child: const Text("abc"))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: useCustomIcon,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              shadowColor: Colors.grey,
                              elevation: 10),
                          child: const Text('커스텀아이콘')),
                      ElevatedButton(
                          onPressed: useCustomIconAndUnit,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              shadowColor: Colors.grey,
                              elevation: 10),
                          child: const Text('커스텀아이콘+유닛')),
                      ElevatedButton(
                          onPressed: useUnit,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              shadowColor: Colors.grey,
                              elevation: 10),
                          child: const Text('유닛')),
                      ElevatedButton(
                          onPressed: useEffectNone,
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              shadowColor: Colors.grey,
                              elevation: 10),
                          child: const Text('숫자만')),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          unselectedItemColor: Colors.blueGrey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Offerwall'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: '알림'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 1) {
      showAdList();
    }
  }
}

class TnkPlacementAdItem {
  int app_id = 0; // Int 광고 고유 식별값
  String app_nm = ""; // String 광고 제목
  String img_url = ""; // String 이미지 url
  int pnt_amt = 0; // Int 지급 포인트 (이벤트 진행시 이벤트 배율 적용된 포인트)
  int org_amt = 0; // Int 배율 이벤트 진행 시 원래의 포인트(이벤트 기간 아닐경우 0)
  String pnt_unit = ""; // String 포인트 재화 단위
  int prd_price = 0; // Int CPS상품 가격
  int org_prd_price = 0; // Int CPS상품 할인 전 가격
  int sale_dc_rate = 0; // Int CPS 상품 할인율
  bool multi_yn = false; // Bool 멀티 미션 광고 여부
  int cmpn_type = 0; // Int 광고 유형코드
  String cmpn_type_name = ""; // String 광고 유형 이름
  String like_yn = ""; // String 즐겨찾기 상품 여부
}

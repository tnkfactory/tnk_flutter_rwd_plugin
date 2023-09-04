

import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _tnkFlutterRwdPlugin = TnkFlutterRwd();

  String _tnkResult = 'Unknown';
  int _myPoint = 0;
  int _queryPoint = 0;
  final String _itemId = "item.0001";
  final int _cost = 2;



  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
  }


  Future<void> showAdList() async {

    String platformVersion;

    try {
      await _tnkFlutterRwdPlugin.setUserName("testUser");
      await _tnkFlutterRwdPlugin.setCOPPA(false);
      platformVersion =
          await _tnkFlutterRwdPlugin.showAdList("타이틀") ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _tnkResult = platformVersion;
    });
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
      point = await _tnkFlutterRwdPlugin.getEarnPoint() ?? 0 ;
    } on PlatformException {
      point = 0;
    }

    setState(() {
      _myPoint = point;
    });
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
      point = await _tnkFlutterRwdPlugin.getQueryPoint() ?? 0 ;
    } on PlatformException {
      point = 0;
    }

    setState(() {
      _queryPoint = point;
    });
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
            title:Text("abc"),
            content: Text(' 항목을 선택했습니다.'),
          );
        }
    );
  }

  Future<void> setCustomUI() async {
    try {
      HashMap<String,String> paramMap = HashMap();
      //0xff252542
      paramMap.addAll({
            "category_select_font":"#495057", // 카테고리 폰트 컬러
            "filter_select_background":"#495057", // 선택된 필터 배경색
            "filter_select_font":"#FFFFFF", // 선택된 필터 폰트 컬러
            "filter_not_select_font":"#495057", // 선택안한 필터 폰트 컬러
            "filter_not_select_background":"#FFFFFF", // 선택안한 필터 배경색
            "adinfo_title_font":"#212529", // 광고상세페이지 광고타이틀 폰트 컬러
            "adinfo_desc_font":"#5F0D80", // 광고상세페이지 광고액션 폰트 컬러
            "adinfo_point_unit_font":"#5F0D80", // 광고상세페이지 포인트 단위 컬러
            "adinfo_point_amount_font":"#5F0D80", // 광고상세페이지 포인트 액수 폰트 컬러
            "adinfo_button_background":"#5F0D80", // 광고상세페이지 버튼 백그라운드 컬러
            "adinfo_button_title_font":"#FFFFFF", // 광고상세페이지 버튼 백그라운드 컬러
            "adinfo_button_desc_font":"#FFFFFF", // 광고상세페이지 버튼 백그라운드 컬러
            "adinfo_button_gradient_option":"L"

            // "adlist_title_font":"#212529", // 광고리스트 광고타이틀 폰트 컬러
            // "adlist_desc_font":"#61666A", // 광고리스트 광고액션 폰트 컬러
            // "adlist_point_unit_font":"#5F0D80", // 광고리스트 포인트 단위 폰트 컬러
            // "adlist_point_amount_font":"#5F0D80", // 광고리스트 포인트 액수 폰트 컬러
            // "point_icon_name":"", // 포인트 아이콘 이미지 이름
            // "point_icon_use_yn":"N", // 포인트 아이콘 사용여부 ( 포인트아이콘 사용시 포인트 단위는 사용못함 )

          });
      await _tnkFlutterRwdPlugin.setCustomUI( paramMap );
    } on Exception {
      return;
    }
}


  @override
  Widget build(BuildContext context) {
    Icon advIcon = const Icon(Icons.tv);
    Icon pointIcon = const Icon(Icons.paid_rounded);
    Icon moneyIcon = const Icon(Icons.attach_money);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter RWD Plugin'),
          actions: [
            IconButton(
                onPressed: (){
                  // setNoUsePointIcon();
                  setCustomUI();
                },
                icon: const Icon(Icons.dashboard_customize)
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding:EdgeInsets.zero,
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
              DataTable(
                columns: const [
                  DataColumn(label: Text('적립가능한 Point')),
                  DataColumn(label: Text('사용가능한 Point')),
                ],
                rows: [
                  DataRow(
                      cells: [
                        DataCell(Text('$_myPoint')),
                        DataCell(Text('$_queryPoint'))
                      ]
                  ),
                ],
              ),
              ButtonBar(
                children: [
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                          onPressed: () { purchaseItem(_itemId, _cost); },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, shadowColor: Colors.redAccent, ),
                          child: const Text('테스트구매')
                      ),
                      OutlinedButton(
                          onPressed: () { withdrawPoints("테스트 인출"); },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, shadowColor: Colors.redAccent),
                          child: const Text('테스트인출')
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                          onPressed: showATTPopup,
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, shadowColor: Colors.redAccent),
                          child: const Text('ATT Popup')
                      ),
                      OutlinedButton(
                          onPressed: setNoUsePointIcon,
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, shadowColor: Colors.redAccent),
                          child: const Text('포인트아이콘 사용안함')
                      ),
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
          items:const<BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.tv),
                label: 'Offerwall'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: '알림'
            ),
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

    if(_selectedIndex == 1) {
      showAdList();
    }
  }
}

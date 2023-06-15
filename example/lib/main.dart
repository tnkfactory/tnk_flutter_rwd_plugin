

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


  @override
  Widget build(BuildContext context) {
    Icon advIcon = const Icon(Icons.tv);
    Icon pointIcon = const Icon(Icons.paid_rounded);
    Icon moneyIcon = const Icon(Icons.attach_money);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Plugin Example'),
        ),
        drawer: Drawer(
          child: ListView(
            padding:EdgeInsets.zero,
            children: <Widget>[
              const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                ),
                accountName: Text("flutter"),
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
                title: const Text('OfferW==========================all'),
                onTap: () => showAdList(),
              ),
              ListTile(
                leading: const Icon(
                  Icons.store,
                  color: Colors.blueGrey,
                ),
                title: const Text('적립가능한 포인트'),
                onTap: () => getEarnPoint(),
              ),
              ListTile(
                leading: const Icon(
                  Icons.attach_money,
                  color: Colors.blueGrey,
                ),
                title: const Text('내 포인트'),
                onTap: () => getQueryPoint(),
              )

            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              // Text('result \n\n$_tnkResult\n'),
              // Text('적립가능한 Point :  $_myPoint'),
              // Text('사용가능한 Point :  $_queryPoint'),
              ButtonBar(
                children: [
                  // Row (
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     OutlinedButton.icon( onPressed: () { showAdList(); },icon: advIcon, label: const Text('adv list')),
                  //     OutlinedButton.icon(onPressed: (){getEarnPoint(); }, icon: pointIcon, label: const Text('earnPoint')),
                  //     OutlinedButton.icon(onPressed: (){getQueryPoint(); }, icon: pointIcon, label: const Text('queryPoint')),
                  //   ],
                  // ),
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon( onPressed: () { purchaseItem(_itemId, _cost); },icon: moneyIcon, label: const Text('purchase')),
                      OutlinedButton.icon( onPressed: () { withdrawPoints("테스트 인출"); },icon: moneyIcon, label: const Text('withdraw')),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(onPressed: showATTPopup, child: const Text('show att popup')),
                    ],
                  ),
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(onPressed: setNoUsePointIcon, child: const Text('No use point icon')),
                      OutlinedButton(onPressed: setNoUsePrivacyAlert, child: const Text('No use privacy alert'))
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

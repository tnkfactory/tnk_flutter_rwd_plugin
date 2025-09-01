import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'package:tnk_flutter_rwd_example/placement_data.dart';

class OfferwallItem extends StatefulWidget {
  const OfferwallItem({super.key});

  @override
  State<StatefulWidget> createState() => _OfferwallItem();
}

class _OfferwallItem extends State<OfferwallItem> with WidgetsBindingObserver {
  final _tnkFlutterRwdPlugin = TnkFlutterRwd();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('결과')),
                      DataColumn(label: Text('적립 가능한 포인트')),
                      DataColumn(label: Text('내 포인트')),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(_tnkResult)),
                        DataCell(Text('$_myPoint')),
                        DataCell(Text('$_queryPoint')),
                      ]),
                    ],
                  ),
                ]),
                OverflowBar(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ElevatedButton(
                        //   onPressed: () {
                        //     getJsonAdList();
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //       foregroundColor: Colors.white,
                        //       backgroundColor: Colors.redAccent,
                        //       shadowColor: Colors.redAccent,
                        //       elevation: 5),
                        //   child: const Text("TEST"),
                        // ),
                        ElevatedButton(
                            onPressed: () {
                              getQueryPoint();
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueAccent,
                                shadowColor: Colors.blueAccent,
                                elevation: 10),
                            child: const Text('내 포인트')),
                        ElevatedButton(
                            onPressed: () {
                              getEarnPoint();
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueAccent,
                                shadowColor: Colors.blueAccent,
                                elevation: 10),
                            child: const Text('적립가능한 포인트')),
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
                            onPressed: () {
                              presentAdDetailView(227796);

                              // onAdItemClick("726941");
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.redAccent,
                                shadowColor: Colors.redAccent,
                                elevation: 10),
                            child: const Text('광고상세 진입')),

                        ElevatedButton(
                            onPressed: () {
                              setUserName();
                              // onAdItemClick("726941");
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.redAccent,
                                shadowColor: Colors.redAccent,
                                elevation: 10),
                            child: const Text('set username')),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              adJoin(227796);

                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.purpleAccent,
                                shadowColor: Colors.purpleAccent,
                                elevation: 10),
                            child: const Text('Ad Join')),

                        ElevatedButton(
                            onPressed: () {
                              adAction(227796);
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.purpleAccent,
                                shadowColor: Colors.purpleAccent,
                                elevation: 10),
                            child: const Text('Ad Action')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // 원하는 동작 작성
                showAdList();
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tv, size: 20),
                  SizedBox(height: 4),
                  Text(
                    "오퍼월",
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showAdList() async {
    String platformVersion;

    try {
      // await _tnkFlutterRwdPlugin.setUserName("jameson");
      await _tnkFlutterRwdPlugin.setCOPPA(false);

      _tnkFlutterRwdPlugin.setUseTermsPopup(false);
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
    _tnkFlutterRwdPlugin.openEventWebView(103169);
    // int point;
    // try {
    //   point = await _tnkFlutterRwdPlugin.getQueryPoint() ?? 0;
    // } on PlatformException {
    //   point = 0;
    // }
    // print("getQueryPoint : $point");
    //
    // setState(() {
    //   _queryPoint = point;
    // });
  }

  Future<void> getEarnPoint() async {
    _tnkFlutterRwdPlugin.showCustomTapActivity(
        "https://api3.tnkfactory.com/tnk/offerwall.web.main?md_user_nm={md_user_nm}&app_id={pub_id_hex}&oid=b55a60139f342553ed1a2011905a491c&adid={adid}&t=4",
        "689593");
    // int point;
    // try {
    //   point = await _tnkFlutterRwdPlugin.getEarnPoint() ?? 0;
    // } on PlatformException {
    //   point = 0;
    // }
    //
    // setState(() {
    //   _myPoint = point;
    // });
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
      _tnkFlutterRwdPlugin.setUseTermsPopup(false);

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
    } on PlatformException catch(e){
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
      String? result = await _tnkFlutterRwdPlugin.presentAdDetailView(appId) ;
      print("jameson result : " + result!);
    } on Exception {
      return;
    }
  }

  Future<void> adJoin(int appId) async {
    try {
      await _tnkFlutterRwdPlugin.setUserName("dongyoon");
      String? result = await _tnkFlutterRwdPlugin.adJoin(appId) ;
      print("jameson result : " + result!);
    } on Exception {
      return;
    }
  }

  Future<void> adAction(int appId) async {
    try {
      await _tnkFlutterRwdPlugin.setUserName("dongyoon");
      String? result = await _tnkFlutterRwdPlugin.adAction(appId) ;
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

}



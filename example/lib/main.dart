

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
  String _tnkResult = 'Unknown';
  int _myPoint = 0;
  final _tnkFlutterRwdPlugin = TnkFlutterRwd();

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> showAdList() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await _tnkFlutterRwdPlugin.setUserName("testUser");
      await _tnkFlutterRwdPlugin.setCOPPA(false);
      platformVersion =
          await _tnkFlutterRwdPlugin.showAdList("타이틀") ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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

  Future<void> setNoUseUsePointIcon() async {
    try {
      await _tnkFlutterRwdPlugin.setNoUseUsePointIcon();
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


  @override
  Widget build(BuildContext context) {
    Icon advIcon = const Icon(Icons.tv);
    Icon pointIcon = const Icon(Icons.currency_bitcoin);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('result \n\n$_tnkResult\n'),
              Text('적립가능한 Point :  $_myPoint'),
              ButtonBar(
                children: [
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon( onPressed: () { showAdList(); },icon: advIcon, label: const Text('adv list')),
                      OutlinedButton.icon(onPressed: (){getEarnPoint(); }, icon: pointIcon, label: const Text('get earn point')),
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
                      OutlinedButton(onPressed: setNoUseUsePointIcon, child: const Text('No use point icon')),
                      OutlinedButton(onPressed: setNoUsePrivacyAlert, child: const Text('No use privacy alert'))
                    ],
                  ),
                ],
              ),
              // OutlinedButton(
              //   onPressed: (){ showAdList(); },
              //   style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              //   child: const Text('show adlist'),
              // ),
              // OutlinedButton(
              //   onPressed: (){ showATTPopup(); },
              //   style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              //   child: const Text('show attPopup'),
              // ),
              // OutlinedButton(
              //   onPressed: (){ getEarnPoint(); },
              //   style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              //   child: const Text('get point limit'),
              // ),
              // OutlinedButton(
              //   onPressed: (){ setNoUseUsePointIcon(); },
              //   style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              //   child: const Text('set no use pointIcon'),
              // ),
              // OutlinedButton(
              //   onPressed: (){ setNoUsePrivacyAlert(); },
              //   style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              //   child: const Text('set no use privacyAlert'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

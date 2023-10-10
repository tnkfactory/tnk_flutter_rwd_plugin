
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/services.dart';

class TnkRwdAnalyticsEvent {                              // 이벤트명              // 파라미터(item_id, item_name)
  static const String SELECT_CATEGORY = "tnk_ev_category";       // 카테고리 선택          // 카테고리 아이디, 카테고리명
  static const String SELECT_FILTER = "tnk_ev_filter";           // 필터 선택            // 필터 아이디, 필터명
  static const String CLICK_MENU = "tnk_ev_menu";                // 메뉴 선택            // 메뉴 이름, 메뉴 이름(cps_search, cps_my, offerwall_my)
  static const String SEARCH_CPS = "tnk_ev_search_cps";          // cps 검색            // "cps_search", 검색 키워드
  static const String CLICK_BANNER = "tnk_ev_banner_click";      // 배너 클릭            // app id, app name(광고명)
  static const String CLICK_AD = "tnk_ev_ad_click";              // 광고 클릭            // app id, app name(광고명)
  static const String JOIN_AD = "tnk_ev_ad_join";                // 광고 상세에서 참여 클릭  // app id, app name(광고명)
  static const String ACTIVITY_FINISH = "activity_finish";       // 오퍼월 액티비티 종료됨
}

class TnkRwdAnalyticsParam {
  static const String ITEM_ID = "item_id";
  static const String ITEM_NAME = "item_name";
}


class TnkMethodChannelEvent {

  static bool didOfferwallRemoved(MethodCall methodCall){
    switch (methodCall.method) {
      // android rwd event
      case "tnkAnalytics":
        Map<String, dynamic> JSonObj = jsonDecode(methodCall.arguments);
        // finish event
        if (JSonObj["event"] == TnkRwdAnalyticsEvent.ACTIVITY_FINISH) {
          return true;
        }
        break;
      case "didOfferwallRemoved":
        return true;
    }
    return false;
  }
}



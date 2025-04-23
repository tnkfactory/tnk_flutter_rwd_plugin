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


class PlacementPubInfo {
  int ad_type =
  0; //	지면에 설정되어 있는 광고 유형(0 : 보상형, 1 : CPS, 2 : 제휴몰, 3 : 뉴스, 4 : 이벤트)
  String title = ""; //	지면 타이틀
  String more_lbl = ""; //	더보기 라벨
  String cust_data = ""; //	매체 설정값
  String ctype_surl =
      ""; //	캠페인타입 정보 URL (해당 URL 호출시 json 반환) {list_count:int, list:[{cmpn_type:int, cmpn_type_nm:string},….]}
  String pnt_unit = ""; //	매체 포인트 명칭
  String plcmt_id = ""; //	매체 설정 지면 ID
}

List<TnkPlacementAdItem> praserJsonToTnkPlacementAdItem(List<dynamic> adList) {
  List<TnkPlacementAdItem> tnkPlacementAdItemList = [];
  for (var item in adList) {
    TnkPlacementAdItem adItem = TnkPlacementAdItem();
    adItem.app_id = item["app_id"];
    adItem.app_nm = item["app_nm"];
    adItem.img_url = item["img_url"];
    adItem.pnt_amt = item["pnt_amt"];
    adItem.org_amt = item["org_amt"];
    adItem.pnt_unit = item["pnt_unit"];
    adItem.prd_price = item["prd_price"];
    adItem.org_prd_price = item["org_prd_price"];
    adItem.sale_dc_rate = item["sale_dc_rate"];
    adItem.multi_yn = item["multi_yn"];
    adItem.cmpn_type = item["cmpn_type"];
    adItem.cmpn_type_name = item["cmpn_type_name"];
    adItem.like_yn = item["like_yn"];

    tnkPlacementAdItemList.add(adItem);
  }

  return tnkPlacementAdItemList;
}

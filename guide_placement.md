# Placement View 적용 가이드


Tnk의 SDK를 적용하여 placement 광고를 구현하는 방법에 대하여 설명합니다.

1) Tnk 사이트에서 앱 등록 및 매체 정보 등록
2) placement ID 설정
3) placement 광고 호출 및 노출

## 앱 등록 및 매체 정보 등록

다음 절차에 따라 회원 가입 후 광고 매체를 등록합니다.

[1. 회원가입](https://tnkfactory.github.io/docs/join)

[2. 매체 등록 및 app id발급방법](https://tnkfactory.github.io/incentive/APP%20ID)


## Installation

프로젝트의 IDE루트 경로에서 터미널을 열고 다음과 같이 실행하여 플러그인을 설치합니다.

```
flutter pub add tnk_flutter_rwd
```


### 가. Placement View 띄우기

다음과 같이 호출하여 placement광고를 출력 하실 수 있습니다.
  1. placement 광고 데이터 파싱을 위한 모델 클래스 생성
  2. placement 광고 호출 및 노출 ( view 구현 )

```dart
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
  int ad_type = 0; //	지면에 설정되어 있는 광고 유형(0 : 보상형, 1 : CPS, 2 : 제휴몰, 3 : 뉴스, 4 : 이벤트)
  String title = ""; //	지면 타이틀
  String more_lbl = ""; //	더보기 라벨
  String cust_data = ""; //	매체 설정값
  String ctype_surl = ""; //	캠페인타입 정보 URL (해당 URL 호출시 json 반환) {list_count:int, list:[{cmpn_type:int, cmpn_type_nm:string},….]}
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
```


```dart
// tnk rwd sdk를  import 합니다.
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'placement_data.dart';

const DEFAULT_VIEW = 1; // default view
const CPS_VIEW = 2; // cps view

class _PlacementViewItem extends State<PlacementViewItem>
    with WidgetsBindingObserver {
  late int _type;
  final _tnkFlutterRwdPlugin = TnkFlutterRwd();
  List<TnkPlacementAdItem> adList = [];
  PlacementPubInfo pubInfo = PlacementPubInfo();
  String _tnkResult = 'Unknown';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _type = widget.type;
    getAdList(); // 광고 리스트 호출
  }

  @override
  Widget build(BuildContext context) {
    // container height _type 이 DEFAULT_VIEW 일때 194, 2일때 219
    double height = _type == DEFAULT_VIEW ? 194 : 219;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "placement view",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xff353535),
          ),
        ),
        actions: [],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Column 내 정렬
          children: [
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // 왼쪽 & 오른쪽 정렬
                children: [
                  Text(
                    pubInfo.title,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      showAdList(); // 더보기 클릭시 오퍼월 페이지로 이동
                    },
                    child: const Text(
                      "더 보기",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left:8.0, right: 8.0),
                  height: height,
                  color: const Color(0xFFFFFFFF),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: adList.length,
                    itemBuilder: (context, index) {
                      return buildDefaultPlacementView(adList[index]);
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.only(left:8.0, right: 8.0),
                  height: height,
                  color: const Color(0xFFFFFFFF),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: adList.length,
                    itemBuilder: (context, index) {
                      return buildCpsPlacementView(adList[index]);
                    },
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }

  // ATT 팝업 호출
  Future<void> showATTPopup() async {
    try {
      await _tnkFlutterRwdPlugin.showATTPopup();
    } on Exception {
      return;
    }
  }

  // 광고 리스트 호출
  Future<void> getAdList() async {
    try {
      await _tnkFlutterRwdPlugin.setUserName("jameson");
      await _tnkFlutterRwdPlugin.setCOPPA(false);

      String? placementData = await _tnkFlutterRwdPlugin.getPlacementJsonData(
        "offer_nor",
      ); // 발급받은 placement id 입력 
      _tnkFlutterRwdPlugin.setUseTermsPopup(false);

      if (placementData != null) {
        Map<String, dynamic> jsonObject = jsonDecode(placementData);
        String resCode = jsonObject["res_code"];
        String resMessage = jsonObject["res_message"];

        if (resCode == "1") {
          List<TnkPlacementAdItem> adList = praserJsonToTnkPlacementAdItem(
            jsonObject["ad_list"],
          ); // 광고 리스트 파싱

          setState(() {
            this.adList.addAll(adList);
            Map<String, dynamic> pubInfoMap = jsonObject["pub_info"];

            pubInfo.ad_type = pubInfoMap["ad_type"];
            pubInfo.title = pubInfoMap["title"];
            pubInfo.more_lbl = pubInfoMap["more_lbl"];
            pubInfo.cust_data = pubInfoMap["cust_data"];
            pubInfo.ctype_surl = pubInfoMap["ctype_surl"];
            pubInfo.pnt_unit = pubInfoMap["pnt_unit"];
            pubInfo.plcmt_id = pubInfoMap["plcmt_id"];

            pubInfo.plcmt_id = pubInfoMap["plcmt_id"];
            pubInfo.title = pubInfoMap["title"];

            _tnkResult = placementData ?? "null";
          });
        } else {
          // 광고 로드 실패
          print("광고 로드 실패");
        }
      }
    } on PlatformException {
      setState(() {
        _tnkResult = "excetpion";
      });
      return;
    }
  }

  // 광고 클릭 이벤트 ( 상세페이지 이동 )
  Future<void> onAdItemClick(String appId) async {
    try {
      String? adDetail = await _tnkFlutterRwdPlugin.onItemClick(appId);
      if (adDetail != null) {
        Map<String, dynamic> jsonObject = jsonDecode(adDetail);
        String resCode = jsonObject["res_code"];
        String resMessage = jsonObject["res_message"];

        if (resCode == "1") {
          print(resMessage);
        } else {
          print(resMessage);
        }
      } else {
        print("adDetail is null");
      }
    } on Exception {
      print("onAdItemClick Exception");
      return;
    }
  }

  // placement view 설정
  // Widget setPlacementView(TnkPlacementAdItem adItem) {
  //   return _type == CPS_VIEW ? buildCpsPlacementView(adItem) : buildDefaultPlacementView(adItem);
  // }

  // placement view 구현하는 메소드 ( 기본 )
  Widget buildDefaultPlacementView(TnkPlacementAdItem adItem) {
    return Container(
      width: 216,
      height: 194,
      margin: const EdgeInsets.only(right: 10),
      child:
      // onTap 이벤트 추가
      GestureDetector(
        onTap: () => onAdItemClick(adItem.app_id.toString()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 216,
              height: 107,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(adItem.img_url),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 5),

            Text(
              adItem.app_nm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
            ),
            const SizedBox(height: 5),
            Text(
              adItem.cmpn_type_name,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff4572EF),
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Image(
                  image: AssetImage('assets/images/ic_point.png'),
                  width: 12,
                  height: 12,
                ),
                const SizedBox(width: 5),
                Text(
                  adItem.pnt_amt.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff4572EF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCpsPlacementView(TnkPlacementAdItem adItem) {
    return GestureDetector(
      onTap: () => onAdItemClick(adItem.app_id.toString()),
      child: SizedBox(
        width: 110,
        height: 219,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(adItem.img_url)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // padding 8dp
            Text(
              adItem.app_nm,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff666666),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  adItem.org_prd_price.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${adItem.sale_dc_rate}%",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff4572EF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  adItem.cmpn_type_name,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xff4572EF).withValues(alpha: (0.5*255)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // assets 경로
                const Image(
                  image: AssetImage('assets/images/ic_point.png'),
                  width: 12,
                  height: 12,
                ),
                const SizedBox(width: 3),
                Text(
                  adItem.pnt_amt.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff4572EF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Positioned.fill(child: Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Future<void> showAdList() async {
    String platformVersion;

    try {
      await _tnkFlutterRwdPlugin.setUserName("testUser");
      await _tnkFlutterRwdPlugin.setCOPPA(false);

      _tnkFlutterRwdPlugin.setUseTermsPopup(false);
      platformVersion =
          await _tnkFlutterRwdPlugin.showAdList("미션 수행하기") ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _tnkResult = platformVersion;
    });
  }
}
```

##### Method

- String getPlacementJsonData()
##### Description

광고데이터를 Json 형태로 반환합니다.

##### Parameters

| 파라메터 명칭 | 내용                                                         |
| ------------- | ------------------------------------------------------------ |
| -      | - |



##### Method

- String setUserName(String user_name)

##### Description

앱이 실행되면 우선 앱 내에서 사용자를 식별하는 고유한 ID를 아래의 API를 사용하시어 Tnk SDK에 설정하시기 바랍니다.

사용자 식별 값으로는 게임의 로그인 ID 등을 사용하시면 되며, 적당한 값이 없으신 경우에는 Device ID 값 등을 사용할 수 있습니다.

(유저 식별 값이 Device ID 나 전화번호, 이메일 등 개인 정보에 해당되는 경우에는 암호화하여 설정해주시기 바랍니다.)

유저 식별 값을 설정하셔야 이후 사용자가 적립한 포인트를 개발사의 서버로 전달하는 callback 호출 시에  같이 전달받으실 수 있습니다.

##### Parameters

| 파라메터 명칭 | 내용                                                         |
| ------------- | ------------------------------------------------------------ |
| user_name      | 앱에서 사용자를 식별하기 위하여 사용하는 고유 ID 값 (로그인 ID 등)<br/>길이는 256 bytes 이하입니다. |



##### Method

- String showAdList(String title)

##### Description

자신의 앱에서 광고 목록을 띄우기 위하여 TnkSession 객체의 showAdListAsModel:title 또는 showAdListNavigation:title 함수를 사용합니다.
모달뷰 형태로 광고 목록을 띄워주거나 네비게이션 컨트롤러 방식으로 목록을 띄워줍니다.

##### Parameters

| 파라메터 명칭  | 내용                          |
| -------------- | ----------------------------- |
| title          | 광고 리스트의 타이틀을 지정함 |






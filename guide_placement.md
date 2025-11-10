# Placement View 적용 가이드


Tnk의 SDK를 적용하여 placement 광고를 구현하는 방법에 대하여 설명합니다.

1) placement 광고 호출 및 노출


### 가. Placement View 띄우기

다음과 같이 호출하여 placement광고를 출력 하실 수 있습니다.
  1. placement 광고 데이터 파싱을 위한 모델 클래스 생성
  2. placement 광고 호출 및 노출 ( view 구현 )



```dart
// tnk rwd sdk를  import 합니다.
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'package:tnk_flutter_rwd/tnk_placement_model.dart';

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

- List<TnkPlacementAdItem> praserJsonToTnkPlacementAdItem(List<dynamic> jsonAdList)

##### Description

getPlacementJsonData() 메소드로 받아온 jsonObject["ad_list"] 데이터를 TnkPlacementAdItem 모델 클래스 형태로 파싱합니다.

##### Parameters

| 파라메터 명칭    | 내용                  |
|------------|---------------------|
| jsonAdList | jsonObject["ad_list" |



##### Method

- String showAdList(String title)

##### Description

자신의 앱에서 광고 목록을 띄우기 위하여 TnkSession 객체의 showAdListAsModel:title 또는 showAdListNavigation:title 함수를 사용합니다.
모달뷰 형태로 광고 목록을 띄워주거나 네비게이션 컨트롤러 방식으로 목록을 띄워줍니다.

##### Parameters

| 파라메터 명칭  | 내용                          |
| -------------- | ----------------------------- |
| title          | 광고 리스트의 타이틀을 지정함 |






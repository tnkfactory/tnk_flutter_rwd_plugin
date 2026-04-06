
# tnk flutter plugin 설치 안내

Tnk의 SDK를 적용하여 게시앱을 구현하는 것은 크게 3단계로 이루어집니다.

1) Tnk 사이트에서 앱 등록 및 매체 정보 등록

2) 앱 내에 Tnk 충전소로 이동하는 버튼 구현

3) 사용자가 충전한 포인트 조회 및 사용

## 앱 등록 및 매체 정보 등록

다음 절차에 따라 회원 가입 후 광고 매체를 등록합니다.

[1. 회원가입](https://tnkfactory.github.io/docs/join)

[2. 매체 등록 및 app id발급방법](https://tnkfactory.github.io/incentive/APP%20ID)


## Installation

프로젝트의 IDE루트 경로에서 터미널을 열고 다음과 같이 실행하여 플러그인을 설치합니다.

```
flutter pub add tnk_flutter_rwd
```


### Manifest 설정하기

android 프로젝트의 manifest파일에 다음과 같은 설정이 필요합니다.

#### 권한 설정

아래와 같이 권한 사용을 추가합니다.
```xml
<!-- 인터넷 -->
<uses-permission android:name="android.permission.INTERNET" />
<!-- 동영상 광고 재생을 위한 wifi접근 -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<!-- 광고 아이디 획득 -->
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

#### Application ID 설정하기

Tnk 사이트에서 앱 등록하면 상단에 App ID 가 나타납니다. 이를 AndroidMenifest.xml 파일의 application tag 안에 아래와 같이 설정합니다.
(*your-application-id-from-tnk-site* 부분을 실제 App ID 값으로 변경하세요.)

```xml
<application>

    <meta-data android:name="tnkad_app_id" android:value="your-application-id-from-tnk-site" />

</application>
```


#### 적용 예제 샘플입니다.
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.tnkfactory.tnkofferer">
   <application
        android:label="yyyy"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
       <meta-data android:name="tnkad_app_id" android:value="3040807040519322223915040708030f" />
    </application>
</manifest>
```


### 라이브러리 등록

TNK SDK(`com.tnkfactory:rwd:8.09.10`)는 TNK Maven 저장소에서 제공됩니다.

프로젝트 파일 내에 `{projectroot}/android/build.gradle` 파일에 아래와 같이 저장소를 추가합니다.

**예시**
```gradle
buildscript {
    ext.kotlin_version = '2.1.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.1.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://jitpack.io" }
        maven { url "https://repository.tnkad.net:8443/repository/public/" }
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

### Proguard 사용

Proguard를 사용하실 경우 Proguard 설정내에 아래 내용을 반드시 넣어주세요.

```
-keep class com.tnkfactory.** { *;}
```


---

## API 가이드

### 가. 기본 설정

#### setUserName

앱에서 사용자를 식별하는 고유 ID를 설정합니다. 이 값은 포인트 적립 콜백 시 함께 전달됩니다.
개인정보(전화번호, 이메일 등)에 해당하는 경우 암호화하여 설정해주세요.

##### Method

```dart
Future<String?> setUserName(String userName)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| userName | 앱에서 사용자를 식별하기 위한 고유 ID (로그인 ID 등). 최대 256 bytes |

##### 적용예시

```dart
await TnkFlutterRwd().setUserName("my_user_id");
```

---

#### setCOPPA

아동 온라인 개인정보보호법(COPPA) 대상 여부를 설정합니다.

##### Method

```dart
Future<String?> setCOPPA(bool coppa)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| coppa | true: 아동 사용자, false: 일반 사용자 |

##### 적용예시

```dart
await TnkFlutterRwd().setCOPPA(false);
```

---

#### showATTPopup

iOS 전용 ATT(App Tracking Transparency) 팝업을 표시합니다.  
**Android에서는 아무 동작도 하지 않습니다.** iOS 대응을 위해 오퍼월 호출 전에 함께 호출해주세요.

##### Method

```dart
Future<String?> showATTPopup()
```

##### 적용예시

```dart
await TnkFlutterRwd().showATTPopup();
```

---

### 나. 오퍼월 표시

<u>테스트 상태에서는 테스트하는 장비를 개발 장비로 등록하셔야 광고목록이 정상적으로 나타납니다.</u>

[테스트 단말기 등록하는 방법](https://tnkfactory.github.io/incentive/reg_test_device)

#### showAdList

오퍼월 광고 목록 화면을 표시합니다.

##### Method

```dart
Future<String?> showAdList(String title, [int appId = 0])
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| title | 오퍼월 상단에 표시할 타이틀 |
| appId | (선택) 특정 앱 ID. 기본값 0 |

##### 적용예시

```dart
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';

Future<void> showOfferwall() async {
    await TnkFlutterRwd().showATTPopup();           // iOS ATT 팝업 (Android에서는 무시됨)
    await TnkFlutterRwd().setUserName("my_user");
    await TnkFlutterRwd().showAdList("무료 충전소");
}
```

---

#### showAdListWithPlacement

플레이스먼트 설정을 적용하여 오퍼월을 표시합니다. 카테고리/필터 노출 여부를 제어할 수 있습니다.

##### Method

```dart
Future<String?> showAdListWithPlacement(String placementId, int categoryId, int filterId)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| placementId | 플레이스먼트 ID (예: `"cps_only"`, `"offer_nor"`) |
| categoryId | 카테고리 ID. 0이면 카테고리 영역 없이 표시 |
| filterId | 필터 ID. 0이면 전체 필터 표시 |

##### 적용예시

```dart
// 카테고리 영역 없이 제휴몰 필터만 노출
await TnkFlutterRwd().showAdListWithPlacement("cps_only", 4, 509);

// 카테고리와 필터 모두 노출
await TnkFlutterRwd().showAdListWithPlacement("", 0, 0);
```

---

#### setCategoryAndFilter

오퍼월 호출 전 카테고리와 필터 초기값을 설정합니다. `showAdList()` 호출 전에 사용합니다.

##### Method

```dart
Future<String?> setCategoryAndFilter(int category, int filter)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| category | 카테고리 ID |
| filter | 필터 ID |

##### 적용예시

```dart
await TnkFlutterRwd().setCategoryAndFilter(4, 0);
await TnkFlutterRwd().showAdList("미션 수행하기");
```

---

### 다. 광고 상세 / 참여

#### presentAdDetailView

광고 상세 화면을 표시합니다. 상세 페이지가 없는 광고 타입도 상세 화면으로 이동합니다.

##### Method

```dart
Future<String?> presentAdDetailView(int appId, [int actionId = 0])
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| appId | 광고 ID |
| actionId | (선택) 액션 ID. 기본값 0 |

##### 적용예시

```dart
await TnkFlutterRwd().setUserName("my_user");
await TnkFlutterRwd().presentAdDetailView(809977);
```

---

#### adJoin

광고 상세 화면의 참여 버튼과 동일한 효과를 수행합니다.

##### Method

```dart
Future<String?> adJoin(int appId, [int actionId = 0])
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| appId | 광고 ID |
| actionId | (선택) 액션 ID. 기본값 0 |

##### 적용예시

```dart
await TnkFlutterRwd().setUserName("my_user");
await TnkFlutterRwd().adJoin(227796);
```

---

#### adAction

광고 타입에 따라 참여(adJoin) 또는 상세(presentAdDetailView)를 자동으로 호출합니다.

##### Method

```dart
Future<String?> adAction(int appId, [int actionId = 0])
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| appId | 광고 ID |
| actionId | (선택) 액션 ID. 기본값 0 |

##### 적용예시

```dart
await TnkFlutterRwd().setUserName("my_user");
await TnkFlutterRwd().adAction(227796);
```

---

### 라. 포인트 조회 및 인출

사용자가 광고참여를 통하여 획득한 포인트는 Tnk 서버에서 관리되거나 앱의 자체서버에서 관리될 수 있습니다.
포인트가 Tnk 서버에서 관리되는 경우에는 다음의 포인트 조회 및 인출 API를 사용하시어 필요한 아이템 구매 기능을 구현하실 수 있습니다.

#### getEarnPoint

사용자가 참여 가능한 모든 광고의 적립 가능한 총 포인트 값을 조회합니다.

##### Method

```dart
Future<int?> getEarnPoint()
```

##### 적용예시

```dart
int point = await TnkFlutterRwd().getEarnPoint() ?? 0;
```

---

#### getQueryPoint

Tnk 서버에 적립되어 있는 사용자 포인트 값을 조회합니다.

##### Method

```dart
Future<int?> getQueryPoint()
```

##### 적용예시

```dart
int point = await TnkFlutterRwd().getQueryPoint() ?? 0;
```

---

#### purchaseItem

Tnk 서버에 적립되어 있는 사용자 포인트를 차감합니다.

##### Method

```dart
Future<String?> purchaseItem(String itemId, int cost)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| itemId | 구매할 아이템의 고유 ID (게시앱에서 직접 정의). Tnk 사이트 보고서에서 확인 가능 |
| cost | 차감할 포인트 수 |

##### 적용예시

```dart
await TnkFlutterRwd().purchaseItem("item.0001", 10);
```

---

#### withdrawPoints

Tnk 서버에 적립되어 있는 사용자의 모든 포인트를 차감합니다.

##### Method

```dart
Future<String?> withdrawPoints(String description)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| description | 인출과 관련된 설명. Tnk 사이트 보고서에서 함께 표시됨 |

##### 적용예시

```dart
await TnkFlutterRwd().withdrawPoints("포인트 전체 인출");
```

---

#### showMyEarnPointList

포인트 적립 내역 화면을 표시합니다.

##### Method

```dart
Future<String?> showMyEarnPointList(HashMap<String, dynamic>? map)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| map | `"type"` (int) 키로 표시 타입 지정 |

##### 적용예시

```dart
await TnkFlutterRwd().setUserName("my_user");

HashMap<String, dynamic> paramMap = HashMap();
paramMap["type"] = 1;
await TnkFlutterRwd().showMyEarnPointList(paramMap);
```

---

### 마. 오퍼월 커스터마이징

#### setNoUsePrivacyAlert

오퍼월 진입 시 개인정보 수집 동의 모달창을 비활성화합니다.  
`showAdList()` 호출 전에 사용합니다.

##### Method

```dart
Future<String?> setNoUsePrivacyAlert()
```

##### 적용예시

```dart
await TnkFlutterRwd().setNoUsePrivacyAlert();
await TnkFlutterRwd().showAdList("무료 충전소");
```

---

#### setNoUsePointIcon

오퍼월에서 노출되는 포인트 아이콘을 비활성화합니다.  
`showAdList()` 호출 전에 사용합니다.

##### Method

```dart
Future<String?> setNoUsePointIcon()
```

##### 적용예시

```dart
await TnkFlutterRwd().setNoUsePointIcon();
await TnkFlutterRwd().showAdList("무료 충전소");
```

---

#### setUseTermsPopup

약관 동의 팝업 표시 여부를 설정합니다.

##### Method

```dart
Future<String?> setUseTermsPopup(bool isUse)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| isUse | true: 약관 팝업 표시, false: 약관 팝업 비표시 |

##### 적용예시

```dart
await TnkFlutterRwd().setUseTermsPopup(false);
```

---

#### setCustomUIDefault

오퍼월 UI 색상을 커스터마이징합니다.

##### Method

```dart
Future<String?> setCustomUIDefault(HashMap<String, String> map)
```

##### 색상 키 목록

| 키 | 적용 영역 |
| -- | --------- |
| `category_select_font` | 선택된 카테고리 폰트 색상 |
| `filter_select_background` | 선택된 필터 배경색 |
| `filter_select_font` | 선택된 필터 폰트 색상 |
| `filter_not_select_background` | 미선택 필터 배경색 |
| `filter_not_select_font` | 미선택 필터 폰트 색상 |
| `app_main_color` | 앱 메인 색상 |
| `adlist_title_font` | 광고 리스트 타이틀 폰트 색상 |
| `adlist_desc_font` | 광고 리스트 설명 폰트 색상 |
| `adlist_point_unit_font` | 광고 리스트 포인트 단위 색상 |
| `adlist_point_amount_font` | 광고 리스트 포인트 액수 색상 |
| `adinfo_title_font` | 광고 상세 타이틀 폰트 색상 |
| `adinfo_desc_font` | 광고 상세 설명 폰트 색상 |
| `adinfo_point_unit_font` | 광고 상세 포인트 단위 색상 |
| `adinfo_point_amount_font` | 광고 상세 포인트 액수 색상 |
| `adinfo_button_background` | 광고 상세 버튼 배경색 |
| `adinfo_button_title_font` | 광고 상세 버튼 타이틀 색상 |
| `adinfo_button_desc_font` | 광고 상세 버튼 설명 색상 |
| `adinfo_button_gradient_option` | 버튼 그라데이션: `"L"` (라이트), `"D"` (다크) |
| `option` | 포인트 표시 방식: `"1"` (아이콘+단위), `"2"` (아이콘만), `"3"` (단위만), `"4"` (없음) |
| `point_icon_name` | 포인트 아이콘 이미지 이름 (앱 번들) |
| `point_icon_name_sub` | 포인트 보조 아이콘 이미지 이름 (앱 번들) |

##### 적용예시

```dart
HashMap<String, String> paramMap = HashMap();
paramMap.addAll({
  "category_select_font": "#26DACA",
  "filter_select_background": "#26DACA",
  "filter_select_font": "#FFFFFF",
  "filter_not_select_font": "#515151",
  "filter_not_select_background": "#FFFFFF",
  "adinfo_title_font": "#161A1B",
  "adinfo_desc_font": "#26DACA",
  "adinfo_point_unit_font": "#26DACA",
  "adinfo_point_amount_font": "#26DACA",
  "adinfo_button_background": "#26DACA",
  "adinfo_button_title_font": "#FFFFFF",
  "adinfo_button_desc_font": "#FFFFFF",
  "adinfo_button_gradient_option": "L",
  "adlist_title_font": "#161A1B",
  "adlist_desc_font": "#515151",
  "adlist_point_unit_font": "#26DACA",
  "adlist_point_amount_font": "#26DACA",
  "app_main_color": "#26DACA",
  "option": "1",
  "point_icon_name": "star_icon",
  "point_icon_name_sub": "star_icon_white",
});
await TnkFlutterRwd().setCustomUIDefault(paramMap);
```

---

#### setCustomUnitIcon

포인트 아이콘 및 단위 표시 방식을 설정합니다.

##### Method

```dart
Future<String?> setCustomUnitIcon(HashMap<String, String> map)
```

##### Parameters

| 키 | 내용 |
| -- | ---- |
| `option` | `"1"` (아이콘+단위), `"2"` (아이콘만), `"3"` (단위만), `"4"` (없음) |
| `point_icon_name` | (선택) 포인트 아이콘 이미지 이름 |
| `point_icon_name_sub` | (선택) 포인트 보조 아이콘 이미지 이름 |

##### 적용예시

```dart
HashMap<String, String> paramMap = HashMap();
paramMap["option"] = "2"; // 아이콘만 표시
await TnkFlutterRwd().setCustomUnitIcon(paramMap);
```

---

#### setPubCustomUi

매체 커스텀 UI 타입을 설정합니다. iOS에서 SktAir 커스텀 UI(`SktAirRwdPlus`) 사용 시 적용합니다.

##### Method

```dart
Future<String?> setPubCustomUi([int type = 0])
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| type | `1`: SktAir 커스텀 UI 사용, `0`: 기본 UI |

##### 적용예시

```dart
await TnkFlutterRwd().setPubCustomUi(1);
```

---

### 바. 이벤트 및 웹페이지

#### showEventWebPage

이벤트 웹페이지를 표시합니다. iOS와 Android의 event_id 값이 다릅니다.

##### Method

```dart
Future<String?> showEventWebPage(HashMap<String, String> map)
```

##### Parameters

| 키 | 내용 |
| -- | ---- |
| `event_id` | 이벤트 ID (String). iOS/Android 별도 값 사용 |

##### 적용예시

```dart
import 'dart:io';

String eventId = Platform.isIOS ? "814278" : "814139";

HashMap<String, String> paramMap = HashMap();
paramMap["event_id"] = eventId;
await TnkFlutterRwd().showEventWebPage(paramMap);
```

---

#### openTnkEventScheme

`tnkscheme://` 형식의 딥링크 URL을 처리합니다. `tnkscheme://offerwall`은 Flutter에서 오퍼월을 바로 열고, 그 외 scheme은 네이티브로 전달합니다.

##### Method

```dart
Future<String?> openTnkEventScheme(String url)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| url | `tnkscheme://` 로 시작하는 URL |

##### 적용예시

```dart
// 오퍼월 열기
await TnkFlutterRwd().openTnkEventScheme("tnkscheme://offerwall?title=무료충전소");

// 그 외 scheme은 네이티브로 전달
await TnkFlutterRwd().openTnkEventScheme("tnkscheme://some_other_action");
```

---

### 사. 뷰 닫기

#### closeOfferwall / closeAdDetail / closeAllView

오퍼월 또는 광고 상세 화면을 코드로 닫습니다.

##### Methods

```dart
Future<String?> closeOfferwall()
Future<String?> closeAdDetail()
Future<String?> closeAllView()
```

##### 적용예시

```dart
await TnkFlutterRwd().closeAdDetail();
await TnkFlutterRwd().closeOfferwall();
await TnkFlutterRwd().closeAllView();
```

앱 생명주기에 따라 자동으로 닫는 패턴:

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _plugin = TnkFlutterRwd();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _plugin.closeAdDetail();
      _plugin.closeOfferwall();
    }
  }
}
```

---

### 아. 오퍼월 이벤트 수신

#### getOfferWallEvent

오퍼월에서 발생하는 Analytics 이벤트를 수신합니다. `initState`에서 MethodChannel 핸들러를 등록합니다.

##### Analytics 이벤트 상수 (TnkRwdAnalyticsEvent)

| 상수 | 값 | 설명 | 지원 플랫폼 |
| ---- | -- | ---- | ----------- |
| `ACTIVITY_FINISH` | `"activity_finish"` | 오퍼월 액티비티 종료 | Android |
| `CLICK_AD` | `"tnk_ev_ad_click"` | 광고 클릭 | Android / iOS |
| `JOIN_AD` | `"tnk_ev_ad_join"` | 광고 상세에서 참여 클릭 | Android / iOS |
| `CLICK_BANNER` | `"tnk_ev_banner_click"` | 배너 클릭 | Android / iOS |
| `SELECT_CATEGORY` | `"tnk_ev_category"` | 카테고리 선택 | Android only |
| `SELECT_FILTER` | `"tnk_ev_filter"` | 필터 선택 | Android only |
| `CLICK_MENU` | `"tnk_ev_menu"` | 메뉴 선택 | Android / iOS |
| `SEARCH_CPS` | `"tnk_ev_search_cps"` | CPS 검색 | Android / iOS |

##### Analytics 파라미터 상수 (TnkRwdAnalyticsParam)

| 상수 | 값 |
| ---- | -- |
| `ITEM_ID` | `"item_id"` |
| `ITEM_NAME` | `"item_name"` |
| `ITEM_DATA` | `"item_data"` |

> **주의**: Android에서는 params가 HashMap 순서로 전달되므로, 인덱스로 접근할 때 반드시 key를 확인하세요.

##### 오퍼월 닫힘 이벤트 처리

- Android: `"tnkAnalytics"` 메서드 + `event == "activity_finish"`
- iOS: `"didOfferwallRemoved"` 메서드

두 플랫폼을 통합 처리하려면 `TnkMethodChannelEvent.didOfferwallRemoved(methodCall)` 유틸리티를 사용합니다.

```dart
// example/lib/tnk_flutter_rwd_analytics.dart 에 정의됨
bool isClosed = TnkMethodChannelEvent.didOfferwallRemoved(methodCall);
```

##### 적용예시

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'tnk_flutter_rwd_analytics.dart'; // TnkRwdAnalyticsEvent, TnkRwdAnalyticsParam

@override
void initState() {
  super.initState();
  MethodChannel channel = const MethodChannel('tnk_flutter_rwd');
  channel.setMethodCallHandler(getOfferWallEvent);
}

Future<void> getOfferWallEvent(MethodCall methodCall) async {
  // 오퍼월 닫힘 통합 처리 (Android + iOS)
  if (TnkMethodChannelEvent.didOfferwallRemoved(methodCall)) {
    print("오퍼월 닫힘");
    return;
  }

  if (methodCall.method == "tnkAnalytics") {
    try {
      Map<String, dynamic> jsonObj = jsonDecode(methodCall.arguments);
      String event = jsonObj["event"];
      final List<dynamic> params = jsonObj['params'] ?? [];

      switch (event) {
        case TnkRwdAnalyticsEvent.JOIN_AD:
          final String? id = params[0][TnkRwdAnalyticsParam.ITEM_ID];
          final String? name = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
          final rawItemData = params[2][TnkRwdAnalyticsParam.ITEM_DATA];
          final itemData = rawItemData is String ? jsonDecode(rawItemData) : rawItemData;
          print('광고 참여 id: $id, name: $name, item_data: $itemData');
          break;

        case TnkRwdAnalyticsEvent.CLICK_AD:
          final String? id = params[0][TnkRwdAnalyticsParam.ITEM_ID];
          final String? name = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
          final rawItemData = params[2][TnkRwdAnalyticsParam.ITEM_DATA];
          final itemData = rawItemData is String ? jsonDecode(rawItemData) : rawItemData;
          print('광고 클릭 id: $id, name: $name, item_data: $itemData');
          break;

        case TnkRwdAnalyticsEvent.SELECT_CATEGORY: // Android only
          final String? ctgrId = params[0][TnkRwdAnalyticsParam.ITEM_ID];
          final String? ctgrName = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
          print('카테고리 선택 id: $ctgrId, name: $ctgrName');
          break;

        case TnkRwdAnalyticsEvent.SELECT_FILTER: // Android only
          final String? filterId = params[0][TnkRwdAnalyticsParam.ITEM_ID];
          final String? filterName = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
          print('필터 선택 id: $filterId, name: $filterName');
          break;

        default:
          print('Unhandled event: $event');
          break;
      }
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }
}
```

---

### 자. Placement View (커스텀 광고 목록)

오퍼월 전체 화면 대신 앱 내 특정 영역에 광고 목록을 직접 렌더링하는 방식입니다.

#### getPlacementJsonData

플레이스먼트 광고 목록 데이터를 JSON 형식으로 조회합니다.

##### Method

```dart
Future<String?> getPlacementJsonData(String placementId)
```

##### Parameters

| 파라메터 | 내용 |
| ------- | ---- |
| placementId | 플레이스먼트 ID (예: `"offer_nor"`, `"offer_evt"`) |

##### JSON 응답 구조

```json
{
  "res_code": "1",
  "res_message": "success",
  "ad_list": [
    {
      "app_id": 123456,
      "app_nm": "앱이름",
      "img_url": "https://...",
      "pnt_amt": 100,
      "org_amt": 100,
      "pnt_unit": "포인트",
      "prd_price": 9900,
      "org_prd_price": 9900,
      "sale_dc_rate": 10,
      "multi_yn": "N",
      "cmpn_type": "CPS",
      "cmpn_type_name": "설치",
      "like_yn": "N"
    }
  ],
  "pub_info": {
    "ad_type": "normal",
    "title": "인기 앱",
    "more_lbl": "더보기",
    "cust_data": "",
    "ctype_surl": "",
    "pnt_unit": "포인트",
    "plcmt_id": "offer_nor"
  }
}
```

##### 적용예시

```dart
import 'dart:convert';
import 'package:tnk_flutter_rwd/tnk_placement_model.dart';

Future<void> getAdList() async {
  try {
    await TnkFlutterRwd().setUserName("my_user");
    await TnkFlutterRwd().setCOPPA(false);

    String? placementData = await TnkFlutterRwd().getPlacementJsonData("offer_nor");

    if (placementData != null) {
      Map<String, dynamic> jsonObject = jsonDecode(placementData);

      if (jsonObject["res_code"] == "1") {
        // 광고 리스트 파싱
        List<TnkPlacementAdItem> adList =
            praserJsonToTnkPlacementAdItem(jsonObject["ad_list"]);

        // pub_info 파싱
        Map<String, dynamic> pubInfoMap = jsonObject["pub_info"];
        String title = pubInfoMap["title"];
        String pntUnit = pubInfoMap["pnt_unit"];

        setState(() {
          this.adList.addAll(adList);
        });
      }
    }
  } on PlatformException {
    return;
  }
}
```

---

#### onItemClick

Placement View에서 광고 아이템 클릭 시 호출합니다. 광고 상세 화면으로 이동합니다.

##### Method

```dart
Future<String?> onItemClick(String app_id)
```

##### 적용예시

```dart
GestureDetector(
  onTap: () async {
    String? result = await TnkFlutterRwd().onItemClick(adItem.app_id.toString());
  },
  child: /* 광고 아이템 위젯 */,
)
```

---

## 오퍼월 호출 종합 예제

```dart
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
import 'tnk_flutter_rwd_analytics.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _plugin = TnkFlutterRwd();

  @override
  void initState() {
    super.initState();

    // 오퍼월 이벤트 핸들러 등록
    MethodChannel channel = const MethodChannel('tnk_flutter_rwd');
    channel.setMethodCallHandler(getOfferWallEvent);

    // 앱 생명주기 감지
    WidgetsBinding.instance.addObserver(this);

    // iOS ATT 팝업 (Android는 무시됨)
    _plugin.showATTPopup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _plugin.closeAdDetail();
      _plugin.closeOfferwall();
    }
  }

  Future<void> showOfferwall() async {
    try {
      await _plugin.setNoUsePrivacyAlert();    // 개인정보 수집 동의 팝업 제거
      await _plugin.setPubCustomUi(1);         // 매체 커스텀 UI 설정
      await _plugin.setCOPPA(false);           // COPPA 설정
      await _plugin.setUserName("my_user");    // 사용자 식별 값 설정
      await _plugin.showAdList("무료 충전소");  // 오퍼월 표시
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> getOfferWallEvent(MethodCall methodCall) async {
    if (TnkMethodChannelEvent.didOfferwallRemoved(methodCall)) {
      print("오퍼월 닫힘");
      return;
    }

    if (methodCall.method == "tnkAnalytics") {
      try {
        Map<String, dynamic> jsonObj = jsonDecode(methodCall.arguments);
        String event = jsonObj["event"];
        final List<dynamic> params = jsonObj['params'] ?? [];

        switch (event) {
          case TnkRwdAnalyticsEvent.JOIN_AD:
            final String? id = params[0][TnkRwdAnalyticsParam.ITEM_ID];
            final String? name = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
            print('광고 참여: id=$id, name=$name');
            break;
          case TnkRwdAnalyticsEvent.CLICK_AD:
            final String? id = params[0][TnkRwdAnalyticsParam.ITEM_ID];
            final String? name = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
            print('광고 클릭: id=$id, name=$name');
            break;
          case TnkRwdAnalyticsEvent.SELECT_CATEGORY: // Android only
            final String? ctgrId = params[0][TnkRwdAnalyticsParam.ITEM_ID];
            final String? ctgrName = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
            print('카테고리 선택: id=$ctgrId, name=$ctgrName');
            break;
          case TnkRwdAnalyticsEvent.SELECT_FILTER: // Android only
            final String? filterId = params[0][TnkRwdAnalyticsParam.ITEM_ID];
            final String? filterName = params[1][TnkRwdAnalyticsParam.ITEM_NAME];
            print('필터 선택: id=$filterId, name=$filterName');
            break;
          default:
            print('Unhandled event: $event');
        }
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: showOfferwall,
            child: const Text('오퍼월 열기'),
          ),
        ),
      ),
    );
  }
}
```


---

## 포인트 관리

### Callback URL

사용자가 광고참여를 통하여 획득한 포인트를 개발사의 서버에서 관리하실 경우 다음과 같이 진행합니다.

* 매체 정보 설정 화면에서 '포인트 관리' 항목을 '자체서버에서 관리'로 선택합니다.
* URL 항목에 포인트 적립 정보를 받을 URL을 입력합니다.

이후에는 사용자에게 포인트가 적립될 때마다 실시간으로 위 URL로 적립 정보를 받을 수 있습니다.

##### 호출방식

HTTP POST

##### Parameters

| 파라메터 | 상세 내용 | 최대길이 |
| ------- | --------- | ------- |
| seq_id | 포인트 지급에 대한 고유한 ID 값. 이 값으로 중복지급 여부를 확인할 수 있습니다. | string(50) |
| pay_pnt | 사용자에게 지급되어야 할 포인트 값 | long |
| md_user_nm | 게시앱에서 setUserName()으로 설정한 사용자 식별 값 | string(256) |
| md_chk | 유효성 검증 값. `app_key + md_user_nm + seq_id` 의 MD5 Hash | string(32) |
| app_id | 사용자가 참여한 광고앱의 고유 ID | long |
| pay_dt | 포인트 지급 시각 (System milliseconds). 예) 1577343412017 | long |
| app_nm | 참여한 광고명 | string(120) |
| pay_amt | 정산되는 금액 | long |
| actn_id | 0: 설치형, 1: 실행형, 2: 액션형, 5: 구매형 | int |

##### 리턴값 처리

Tnk 서버에서는 위 URL을 호출하고 HTTP 리턴코드로 200이 리턴되면 정상 처리된 것으로 판단합니다.
200이 아닌 값이 리턴되면 Tnk 서버는 비정상 처리로 판단하고 5분 단위 및 1시간 단위로 최대 24시간 동안 반복 호출합니다.

* **중요!** 동일한 Request가 반복적으로 호출될 수 있으므로 `seq_id` 값으로 반드시 중복 체크를 하셔야 합니다.


##### Callback URL 구현 예시 (Java)

```java
int payPoint = Integer.parseInt(request.getParameter("pay_pnt"));
String seqId = request.getParameter("seq_id");
String checkCode = request.getParameter("md_chk");
String mdUserName = request.getParameter("md_user_nm");
String appKey = "d2bbd...........19c86c8b021"; // Tnk 사이트에서 확인

String verifyCode = DigestUtils.md5Hex(appKey + mdUserName + seqId);

if (checkCode == null || !checkCode.equals(verifyCode)) {
    log.error("tnkad() check error : " + verifyCode + " != " + checkCode);
} else {
    log.debug("tnkad() : " + mdUserName + ", " + seqId);
    purchaseManager.getPointByAd(mdUserName, payPoint, seqId);
}
```

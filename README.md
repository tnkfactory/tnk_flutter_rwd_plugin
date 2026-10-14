# tnk_flutter_rwd
[![pub package](https://img.shields.io/badge/Flutter-0.8.11-blue)](./CHANGELOG.md)
[![Android](https://img.shields.io/badge/Android_SDK-8.09.39-blue)](./guide_android.md)
[![iOS](https://img.shields.io/badge/iOS_SDK-5.95-blue)](./guide_ios.md)

티엔케이팩토리 오퍼월(보상형 광고) Flutter 플러그인입니다. (Android / iOS)

- Dart SDK : >= 2.18.5 < 4.0.0
- Flutter : >= 2.5.0
- Android Minimum API Level : 21
- iOS : `TnkRwdSdk2.xcframework` 가 플러그인에 포함되어 있습니다

TnkAd SDK는 Tnk의 광고 네트워크 상에서 광고앱이나 매체앱을 개발하기 위하여 제공되는 통합 SDK이며 아래의 기능들을 사용하실 수 있습니다.

- 보상형/구매형 광고의 오퍼월(Offer-wall) 표시
- 특정 광고 상세 진입 / 참여
- 포인트 조회 / 차감 / 인출 (Tnk 서버 관리형)
- 오퍼월 UI 커스터마이징 (색상, 포인트 아이콘/단위 표시 방식)
- Placement View — 앱 내 특정 영역에 광고 목록을 직접 렌더링
- 오퍼월 내 사용자 행동 Analytics 이벤트 수신 (광고 클릭/참여, 오퍼월 닫힘 등)
- 이벤트 웹페이지 표시 및 `tnkscheme://` 딥링크 처리
- 실행형 광고의 앱 실행 보고 (`applicationStarted`)
<br/>

## Contents
#### [설치 및 플랫폼 설정](#설치-및-플랫폼-설정-1)
- [Installation](#1-installation)
- [Setup Android](#2-setup-android)
- [Setup iOS](#3-setup-ios)
#### [API 가이드](#api-가이드-1)
- [Import 및 생성](#1-import-및-생성)
- [기본 설정](#2-기본-설정) — `setUserName` `setCOPPA` `showATTPopup` `applicationStarted`
- [오퍼월 표시](#3-오퍼월-표시) — `showAdList` `setCategoryAndFilter` `showAdListWithPlacement`
- [광고 상세 / 참여](#4-광고-상세--참여) — `presentAdDetailView` `adJoin` `adAction`
- [포인트 조회 및 인출](#5-포인트-조회-및-인출) — `getEarnPoint` `getQueryPoint` `purchaseItem` `withdrawPoints` `showMyEarnPointList`
- [개인정보 / 약관 동의](#6-개인정보--약관-동의) — `setNoUsePrivacyAlert` `setUseTermsPopup` `setUserTermsAgree` `isUserTermsAgree`
- [오퍼월 UI 커스터마이징](#7-오퍼월-ui-커스터마이징) — `setNoUsePointIcon` `setCustomUnitIcon` `setCustomUIDefault` `setPubCustomUi` `setOfferwallTheme` `getOfferwallTheme`
- [이벤트 웹페이지 / 딥링크](#8-이벤트-웹페이지--딥링크) — `showEventWebPage` `openEventWebView` `openTnkEventScheme`
- [화면 닫기 (iOS 전용)](#9-화면-닫기-ios-전용) — `closeOfferwall` `closeAdDetail` `closeAllView`
- [오퍼월 이벤트 수신](#10-오퍼월-이벤트-수신)
- [Placement View](#11-placement-view) — `getPlacementJsonData` `onItemClick`
#### [플랫폼 지원 현황](#플랫폼-지원-현황-1)
#### [포인트 관리 (자체 서버)](#포인트-관리-자체-서버-1)
#### etc
- [Android 상세 가이드](./guide_android.md)
- [iOS 상세 가이드](./guide_ios.md)
- [Placement View 상세 가이드](./guide_placement.md)
- [Sample App](./example)
- [Releases](./CHANGELOG.md)
- [LICENSE](./LICENSE)
<br/>

## 설치 및 플랫폼 설정
### 1. Installation
```bash
flutter pub add tnk_flutter_rwd
```
또는 `pubspec.yaml` 에 직접 추가합니다.
```yaml
dependencies:
  tnk_flutter_rwd: ^0.8.11
```
- 설치 후 아래 플랫폼별 설정(App ID 등록, 권한, 저장소 추가 등)이 필요합니다
- 테스트 상태에서는 테스트 장비를 개발 장비로 등록해야 광고 목록이 정상적으로 나타납니다 — [테스트 단말기 등록 방법](https://tnkfactory.github.io/incentive/reg_test_device)
<br/>

### 2. Setup Android
#### A. AndroidManifest — App ID 등록
```xml
<application ...>
    <meta-data android:name="tnkad_app_id" android:value="Tnk 사이트에서 발급받은 App ID" />
</application>
```
#### B. Gradle — TNK Maven 저장소 추가 (`android/build.gradle` 또는 `android/build.gradle.kts`)
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://repository.tnkad.net:8443/repository/public/") }
    }
}
```
#### C. MainActivity — `FlutterFragmentActivity` 상속 (필수)
```kotlin
class MainActivity : FlutterFragmentActivity()
```
- `FlutterActivity` 를 상속하면 일부 화면(적립 내역, 광고 상세 등)이 실패 응답을 반환합니다
- 권한, Proguard 등 상세 설정은 [Android 가이드](./guide_android.md)를 참고하세요
- 오퍼월 액티비티(`AdWallActivity`)는 플러그인이 자동으로 등록하며, `configChanges` 에 `uiMode` 가 포함되어 있어 단말 다크모드를 바꿔도 오퍼월이 다시 시작되지 않고 바로 바뀝니다 ([`setOfferwallTheme`](#setofferwalltheme))
<br/>

### 3. Setup iOS
#### A. Info.plist — App ID, 앱 추적 동의 문구
```xml
<key>tnkad_app_id</key>
<string>Tnk 사이트에서 발급받은 App ID</string>
<key>NSUserTrackingUsageDescription</key>
<string>사용자에게 맞춤형 광고를 제공하기 위해 광고 식별자를 사용합니다.</string>
```
- iOS 는 앱 추적 동의(ATT)를 한 사용자에게만 광고 목록이 노출됩니다 → [`showATTPopup`](#showattpopup)
- 오퍼월 처리 흐름 등 상세 설정은 [iOS 가이드](./guide_ios.md)를 참고하세요
<br/><br/>

## API 가이드
### 1. Import 및 생성
```dart
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';

final _tnk = TnkFlutterRwd();
```
- 모든 API 는 `TnkFlutterRwd` 인스턴스의 메서드이며 `Future` 를 반환합니다
- 대부분의 설정 API 는 성공 시 `"success"` 를 반환합니다
- 오퍼월을 띄우기 전 권장 호출 순서
  1. `showATTPopup()` (iOS)
  2. `setCOPPA()`, `setUserName()` 등 설정
  3. `showAdList()`
<br/><br/>

### 2. 기본 설정
#### setUserName
```dart
Future<void> setUserName() async {
  var userName = "my_user_id";   // 앱에서 사용자를 식별하는 고유 ID (로그인 ID 등)
  await _tnk.setUserName(userName);
}
```
- 사용자를 식별하는 고유 ID 를 설정합니다. 최대 256 bytes
- 이 값은 [포인트 적립 콜백](#포인트-관리-자체-서버-1) 시 `md_user_nm` 으로 함께 전달됩니다
- 개인정보(전화번호, 이메일 등)에 해당하는 경우 암호화하여 설정해 주세요
- 오퍼월 · 광고 참여 · 적립 내역 등 **사용자별 기능을 호출하기 전에 설정**합니다
<br/>

#### setCOPPA
```dart
await _tnk.setCOPPA(false);   // true: 아동 사용자, false: 일반 사용자
```
- 아동 온라인 개인정보보호법(COPPA) 대상 여부를 설정합니다
- 오퍼월 호출 전에 설정합니다
<br/>

#### showATTPopup
```dart
await _tnk.showATTPopup();
```
- **iOS 전용** — 앱 추적 동의(ATT, App Tracking Transparency) 팝업을 표시합니다
- Android 에서는 아무 동작도 하지 않으므로 플랫폼 분기 없이 호출해도 됩니다
- iOS 는 동의한 사용자에게만 광고 목록이 노출되므로 오퍼월 호출 전에 호출하세요
<br/>

#### applicationStarted
```dart
@override
void initState() {
  super.initState();
  _tnk.applicationStarted();   // 앱 실행 시마다 호출
}
```
- **광고주 앱(실행형 광고)** 에서 사용합니다. 앱이 실행되었음을 Tnk 서버에 알려 실행형 광고의 적립을 처리합니다
- 오퍼월만 사용하는 매체 앱은 호출하지 않아도 됩니다
- 앱이 실행될 때마다 **첫 화면이 시작될 때** 1회 호출합니다
  - 반환값 `"fail"` 은 플러그인이 화면에 연결되기 전에 호출된 경우입니다 (Android). `runApp()` 이전이 아니라 첫 화면의 `initState` 이후에 호출하세요
- 적립 요청은 설치 1회당 한 번만 전송되므로 매 실행마다 호출해도 중복 적립되지 않습니다
- 적립은 **광고 클릭 → 스토어에서 설치 → 최초 실행** 순서일 때만 이루어집니다
<br/><br/>

### 3. 오퍼월 표시
#### showAdList
```dart
Future<void> showOfferwall() async {
  await _tnk.showATTPopup();          // iOS ATT 팝업 (Android 는 무시)
  await _tnk.setCOPPA(false);
  await _tnk.setUserName("my_user");
  await _tnk.showAdList("무료 충전소"); // 오퍼월 표시
}
```
| 파라미터 | 내용 |
|---|---|
| `title` | 오퍼월 상단에 표시할 타이틀 |
| `appId` | (선택) 광고 ID. 0이 아닌 값을 전달하면 해당 광고 화면으로 바로 진입. 기본값 0 |

- 오퍼월 광고 목록 화면을 표시합니다
- 오퍼월이 닫히는 시점은 [오퍼월 이벤트 수신](#10-오퍼월-이벤트-수신)의 `activity_finish` 이벤트로 알 수 있습니다
<br/>

#### setCategoryAndFilter
```dart
await _tnk.setCategoryAndFilter(4, 0);    // category, filter
await _tnk.showAdList("미션 수행하기");
```
- 오퍼월이 열릴 때 처음 선택될 카테고리와 필터를 지정합니다
- 반드시 `showAdList()` **호출 전에** 설정합니다
- 카테고리 / 필터 ID 는 Tnk 담당자를 통해 확인합니다
<br/>

#### showAdListWithPlacement
```dart
// 카테고리 영역 없이 제휴몰 필터만 노출
await _tnk.showAdListWithPlacement("cps_only", 4, 509);

// 카테고리와 필터 모두 노출
await _tnk.showAdListWithPlacement("", 0, 0);
```
| 파라미터 | 내용 |
|---|---|
| `placementId` | 플레이스먼트 ID (예: `"cps_only"`, `"offer_nor"`) |
| `categoryId` | 카테고리 ID. 0이면 카테고리 영역 없이 표시 |
| `filterId` | 필터 ID. 0이면 전체 필터 표시 |

- **Android 전용** — 플레이스먼트 설정을 적용하여 오퍼월을 표시합니다
- iOS 에서는 지원되지 않으므로 `Platform.isAndroid` 로 분기하세요
<br/><br/>

### 4. 광고 상세 / 참여
#### 공통 응답 형식
`presentAdDetailView`, `adJoin`, `adAction` 은 아래 형태의 JSON 문자열을 반환합니다.
```json
{ "res_code": "1", "res_message": "success" }
```
| res_code | 의미 | 처리 권장 |
|---|---|---|
| `"1"` | 성공 | 정상 처리 |
| `"-2"` | 사용자가 약관 동의 팝업에서 **취소** | 사용자 선택이므로 에러를 표시하지 않음 |
| `"-1"` | Activity 미연결 또는 `FlutterFragmentActivity` 미설정 (Android) | 설정 확인 |
| 그 외 | SDK / 서버 오류 코드 | `res_message` 표시 |

```dart
String? raw = await _tnk.adAction(227796);
final res = jsonDecode(raw ?? "{}");
switch (res["res_code"]) {
  case "1":  break;                               // 성공
  case "-2": break;                               // 약관 취소 - 아무것도 하지 않음
  default:   print("실패: ${res["res_message"]}");
}
```
- 호출은 항상 응답을 반환하므로 `await` 가 멈추지 않습니다
<br/>

#### presentAdDetailView
```dart
await _tnk.setUserName("my_user");
await _tnk.presentAdDetailView(809977);   // appId, [actionId = 0]
```
- 광고 상세 화면을 표시합니다
- 상세 페이지가 없는 광고 타입도 상세 화면으로 이동합니다
<br/>

#### adJoin
```dart
await _tnk.setUserName("my_user");
await _tnk.adJoin(227796);   // appId, [actionId = 0, useTopViewController = false, fullscreen = false]
```
| 파라미터 | 내용 |
|---|---|
| `appId` | 광고 ID |
| `actionId` | (선택) 액션 ID. 기본값 0 |
| `useTopViewController` | (선택, **iOS 전용**) `true` 면 현재 최상단 화면 위에 광고를 띄움. 기본값 `false` |
| `fullscreen` | (선택, **iOS 전용**) `true` 면 화면 전체를 덮음(`overFullScreen`), `false` 면 바텀시트(`pageSheet`). 기본값 `false` |

- 광고 상세 화면의 **참여 버튼과 동일한 동작**을 수행합니다
- iOS 에서 다른 화면(예: 럭키이벤트 웹뷰)이 이미 떠 있는 상태로 호출하면 표시에 실패하면서도 성공 응답이 올 수 있습니다. 이런 경로에서는 `useTopViewController: true` 로 호출하세요 — [iOS 가이드](./guide_ios.md) 참고
<br/>

#### adAction
```dart
await _tnk.setUserName("my_user");
await _tnk.adAction(227796);   // appId, [actionId = 0]
```
- 광고 타입에 따라 [`adJoin`](#adjoin) 또는 [`presentAdDetailView`](#presentaddetailview) 를 자동으로 호출합니다
- 어떤 방식으로 열어야 할지 모를 때 사용합니다
<br/><br/>

### 5. 포인트 조회 및 인출
포인트를 **Tnk 서버에서 관리**하는 경우에 사용하는 API 입니다. 자체 서버에서 관리한다면 [포인트 관리 (자체 서버)](#포인트-관리-자체-서버-1)를 참고하세요.

#### getEarnPoint
```dart
int point = await _tnk.getEarnPoint() ?? 0;
```
- 사용자가 참여 가능한 모든 광고의 **적립 가능한 총 포인트**를 조회합니다
- Android 에서 플러그인이 화면에 연결되기 전에 호출하면 `-1` 을 반환합니다
<br/>

#### getQueryPoint
```dart
int point = await _tnk.getQueryPoint() ?? 0;
```
- Tnk 서버에 **적립되어 있는** 사용자 포인트를 조회합니다
- Android 에서 조회에 실패하면 `-1` 을 반환합니다
<br/>

#### purchaseItem
```dart
String? result = await _tnk.purchaseItem("item.0001", 10);   // itemId, cost
if (result == "success") {
  // 아이템 지급
}
```
| 파라미터 | 내용 |
|---|---|
| `itemId` | 구매할 아이템의 고유 ID (앱에서 직접 정의). Tnk 사이트 보고서에서 확인 가능 |
| `cost` | 차감할 포인트 |

- Tnk 서버에 적립된 사용자 포인트를 `cost` 만큼 차감합니다
- 성공 시 `"success"`, 실패 시 `"fail"` 을 반환합니다
- ⚠️ 실제 포인트가 차감됩니다
<br/>

#### withdrawPoints
```dart
String? result = await _tnk.withdrawPoints("포인트 전체 인출");   // description
```
- Tnk 서버에 적립된 사용자의 **모든 포인트**를 차감합니다
- `description` 은 Tnk 사이트 보고서에 함께 표시됩니다
- 성공 시 `"success"`, 실패 시 `"fail"` 을 반환합니다
- ⚠️ 실제 포인트가 차감됩니다
<br/>

#### showMyEarnPointList
```dart
await _tnk.setUserName("my_user");

HashMap<String, dynamic> paramMap = HashMap();
paramMap["type"] = 1;
await _tnk.showMyEarnPointList(paramMap);
```
- 포인트 적립 내역 화면을 표시합니다
- `map` 을 전달하지 않으면 `"fail"` 을 반환합니다
- Android 는 `type` 값과 무관하게 적립 내역 메뉴로 이동합니다
<br/><br/>

### 6. 개인정보 / 약관 동의
#### setNoUsePrivacyAlert
```dart
await _tnk.setNoUsePrivacyAlert();
await _tnk.showAdList("무료 충전소");
```
- 오퍼월 진입 시 표시되는 **개인정보 수집 동의 팝업을 표시하지 않습니다**
- 앱에서 이미 동의를 받은 경우에 사용합니다
- `showAdList()` 호출 전에 설정합니다
<br/>

#### setUseTermsPopup
```dart
await _tnk.setUseTermsPopup(false);   // true: 약관 팝업 표시, false: 표시 안 함
```
- 약관 동의 팝업의 표시 여부를 설정합니다
<br/>

#### setUserTermsAgree
```dart
await _tnk.setUserTermsAgree(true);   // 사용자가 앱 화면에서 약관에 동의한 경우
```
- 앱에서 자체적으로 약관 동의를 받은 경우, **동의 여부를 SDK 에 저장**합니다
- 저장된 동의는 SDK 의 약관 동의 팝업과 같은 기준으로 사용됩니다
<br/>

#### isUserTermsAgree
```dart
bool agreed = await _tnk.isUserTermsAgree() ?? false;
if (!agreed) {
  // 앱의 약관 동의 화면 표시
}
```
- 사용자가 약관에 동의했는지 조회합니다
- iOS 는 `setNoUsePrivacyAlert()` 로 팝업을 끈 경우에도 `true` 를 반환합니다
<br/><br/>

### 7. 오퍼월 UI 커스터마이징
#### setNoUsePointIcon
```dart
await _tnk.setNoUsePointIcon();
await _tnk.showAdList("무료 충전소");
```
- 오퍼월에 노출되는 포인트 아이콘을 표시하지 않습니다
- `showAdList()` 호출 전에 설정합니다
<br/>

#### setCustomUnitIcon
```dart
HashMap<String, String> paramMap = HashMap();
paramMap["option"] = "2";   // 아이콘만 표시
await _tnk.setCustomUnitIcon(paramMap);
```
| 키 | 내용 |
|---|---|
| `option` | `"1"` 아이콘+단위, `"2"` 아이콘만, `"3"` 단위만, `"4"` 없음 |
| `point_icon_name` | (선택, **iOS 전용**) 포인트 아이콘 이미지 이름 |
| `point_icon_name_sub` | (선택, **iOS 전용**) 포인트 보조 아이콘 이미지 이름 |

- 포인트 아이콘과 단위의 표시 방식을 설정합니다
- Android 는 `option` 값만 적용됩니다
<br/>

#### setCustomUIDefault
```dart
if (Platform.isIOS) {
  HashMap<String, String> paramMap = HashMap();
  // 색상 키와 값("#RRGGBB")은 iOS 가이드 참고
  await _tnk.setCustomUIDefault(paramMap);
}
```
- **iOS 전용** — 오퍼월 UI 색상을 변경합니다
- Android 에서 호출하면 `MissingPluginException` 이 발생하므로 `Platform.isIOS` 로 분기하세요
- 사용 가능한 색상 키 목록은 [iOS 가이드](./guide_ios.md)의 `setCustomUIDefault` 를 참고하세요
<br/>

#### setPubCustomUi
```dart
if (Platform.isIOS) {
  await _tnk.setPubCustomUi(1);
}
```
- **iOS 전용** — 특정 매체용으로 제작된 전용 오퍼월 UI 를 적용합니다
- Tnk 와 협의된 매체에서만 사용하며, `type` 값은 Tnk 담당자에게 받습니다
- Android 에서는 동작하지 않습니다
<br/>

#### setOfferwallTheme
```dart
// 앱 시작 시 한 번, 오퍼월을 열기 전에 설정합니다
await _tnk.setOfferwallTheme("dark");
await _tnk.showAdList("무료 충전소");

String? theme = await _tnk.getOfferwallTheme();   // "dark"
```
| 값 | 동작 |
|---|---|
| `"light"` | 단말 설정과 무관하게 라이트 테마로 고정 |
| `"dark"` | 단말 설정과 무관하게 다크 테마로 고정 |
| `"system"` | **Android** 단말의 다크모드를 따름 / **iOS** `"unspecified"` 와 똑같이 동작 |
| `"unspecified"` | SDK 가 테마에 관여하지 않음 (**기본값**, 호출하지 않았을 때와 동일) |

- 오퍼월을 열기 **전에** 설정해야 반영됩니다. 앱 시작 시 한 번 설정하는 것을 권장합니다
- 대소문자는 구분하지 않으며, 알 수 없는 값은 `"unspecified"` 로 처리됩니다. 정상 처리되면 `"success"` 를 반환합니다
- `getOfferwallTheme()` 은 현재 설정된 값을 `"light"` / `"dark"` / `"system"` / `"unspecified"` 중 하나로 반환합니다 (설정한 적이 없으면 `"unspecified"`)
- **Android** (SDK 8.09.39 기준) 적용 화면: 오퍼월 목록 · 광고 상세 · 쇼핑 상품 검색/카테고리 창 · SDK 다이얼로그. **포인트 스토어에는 적용되지 않습니다**
  - `"system"` / `"unspecified"` 에서 오퍼월을 보는 중 단말 다크모드를 바꾸면 보던 카테고리·스크롤 위치를 유지한 채 바로 바뀝니다 (`AdWallActivity` 의 `configChanges` 에 `uiMode` 포함)
- **iOS** (SDK 5.95 기준) 적용 범위: 오퍼월 목록 · 광고 상세 웹뷰 · 이벤트 웹뷰 · 다이얼로그와 상태바 아이콘의 명암
  - iOS 에는 "시스템 설정을 따른다" 는 값이 없어 `"system"` 은 `"unspecified"` 와 같습니다. 매체 앱이 `UIUserInterfaceStyle` 로 라이트/다크를 고정했다면 단말 설정이 아니라 **앱에 고정된 값**을 따릅니다. 반드시 라이트 또는 다크로 보여주려면 `"light"` / `"dark"` 를 지정하세요
- 웹 페이지 내부의 색상은 웹이 결정하므로, 다크 스타일이 없는 페이지는 그대로 표시됩니다
<br/><br/>

### 8. 이벤트 웹페이지 / 딥링크
#### showEventWebPage
```dart
String eventId = Platform.isIOS ? "814278" : "814139";   // 플랫폼별 이벤트 ID

HashMap<String, String> paramMap = HashMap();
paramMap["event_id"] = eventId;
await _tnk.showEventWebPage(paramMap);
```
- 이벤트 웹페이지를 표시합니다
- **iOS 와 Android 의 `event_id` 가 다릅니다.** Tnk 담당자에게 플랫폼별 ID 를 받으세요
<br/>

#### openEventWebView
```dart
if (Platform.isAndroid) {
  String? result = await _tnk.openEventWebView(814139);   // eventId
}
```
- **Android 전용** — 이벤트 ID 로 이벤트 링크를 조회해 웹뷰로 표시합니다
- 이벤트 정보가 없으면 `"fail"` 을 반환합니다
- iOS 에서는 동작하지 않으므로 양 플랫폼 공통으로는 [`showEventWebPage`](#showeventwebpage) 를 사용하세요
<br/>

#### openTnkEventScheme
```dart
await _tnk.openTnkEventScheme("tnkscheme://offerwall?title=무료충전소");
```
- `tnkscheme://` 형식의 딥링크 URL 을 처리합니다
- `tnkscheme://offerwall` 은 오퍼월을 엽니다. `title` 쿼리 파라미터로 타이틀을 지정할 수 있습니다 (기본값 "무료충전소")
- `tnkscheme://` 로 시작하지 않는 URL 은 `"fail"` 을 반환합니다
- 현재 `tnkscheme://offerwall` 외의 scheme 은 처리되지 않습니다
<br/><br/>

### 9. 화면 닫기 (iOS 전용)
```dart
await _tnk.closeOfferwall();   // 오퍼월 화면 닫기
await _tnk.closeAdDetail();    // 광고 상세 화면 닫기
await _tnk.closeAllView();     // 모든 화면 닫기
```
- **iOS 전용** — 오퍼월 또는 광고 상세 화면을 코드로 닫습니다
- Android 는 오퍼월이 별도 Activity 로 표시되어 사용자가 뒤로가기로 닫습니다. Android 에서 호출하면 아무 동작 없이 `"fail"` 을 반환합니다 (0.8.10 이하는 `MissingPluginException` 이 발생하므로 `Platform.isIOS` 로 분기하세요)
- 광고 참여 후 앱으로 돌아왔을 때 화면을 닫는 패턴

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed && Platform.isIOS) {
    _tnk.closeAdDetail();
    _tnk.closeOfferwall();
  }
}
```
<br/><br/>

### 10. 오퍼월 이벤트 수신
```dart
@override
void initState() {
  super.initState();
  const MethodChannel('tnk_flutter_rwd').setMethodCallHandler(getOfferWallEvent);
}

Future<void> getOfferWallEvent(MethodCall methodCall) async {
  if (methodCall.method == "tnkAnalytics") {
    Map<String, dynamic> jsonObj = jsonDecode(methodCall.arguments);
    String event = jsonObj["event"];                 // 이벤트 이름
    List<dynamic> params = jsonObj["params"] ?? [];  // item_id, item_name, item_data

    if (event == "activity_finish") {
      // 오퍼월 닫힘
    }
  }
}
```
| 이벤트 | 값 | 설명 | 플랫폼 |
|---|---|---|---|
| `ACTIVITY_FINISH` | `"activity_finish"` | 오퍼월 화면 종료 | Android / iOS |
| `CLICK_AD` | `"tnk_ev_ad_click"` | 광고 클릭 | Android / iOS |
| `JOIN_AD` | `"tnk_ev_ad_join"` | 광고 상세에서 참여 클릭 | Android / iOS |
| `CLICK_BANNER` | `"tnk_ev_banner_click"` | 배너 클릭 | Android |
| `SELECT_CATEGORY` | `"tnk_ev_category"` | 카테고리 선택 | Android |
| `SELECT_FILTER` | `"tnk_ev_filter"` | 필터 선택 | Android |
| `CLICK_MENU` | `"tnk_ev_menu"` | 메뉴 선택 | Android |
| `SEARCH_CPS` | `"tnk_ev_search_cps"` | CPS 검색 | Android |

- 오퍼월에서 발생하는 사용자 행동을 `"tnkAnalytics"` 메서드로 전달받습니다
- Android 는 `params` 가 HashMap 순서로 전달되므로 인덱스로 접근할 때 key 를 반드시 확인하세요
- 이벤트 상수와 오퍼월 닫힘 통합 처리 유틸리티(`TnkMethodChannelEvent.didOfferwallRemoved`)는 [`example/lib/tnk_flutter_rwd_analytics.dart`](./example/lib/tnk_flutter_rwd_analytics.dart) 에 있습니다
  - 구버전 iOS 플러그인은 오퍼월 닫힘을 `"didOfferwallRemoved"` 메서드로 전달했으며, 이 유틸리티가 두 방식을 모두 처리합니다
- 이벤트별 전체 처리 예시는 [Android 가이드](./guide_android.md)의 "오퍼월 이벤트 수신"을 참고하세요
<br/><br/>

### 11. Placement View
오퍼월 전체 화면 대신 앱 내 특정 영역에 광고 목록을 직접 그리는 방식입니다.

#### getPlacementJsonData
```dart
String? data = await _tnk.getPlacementJsonData("offer_nor");   // placementId
Map<String, dynamic> json = jsonDecode(data ?? "{}");
if (json["res_code"] == "1") {
  List<dynamic> adList = json["ad_list"];      // 광고 목록
  Map<String, dynamic> pubInfo = json["pub_info"];  // 타이틀, 포인트 단위 등
}
```
- 플레이스먼트에 설정된 광고 목록을 JSON 문자열로 조회합니다
- `ad_list` 의 각 항목에는 `app_id`, `app_nm`, `img_url`, `pnt_amt`, `pnt_unit` 등이 들어 있습니다
- `package:tnk_flutter_rwd/tnk_placement_model.dart` 의 `praserJsonToTnkPlacementAdItem()` 으로 모델 목록으로 변환할 수 있습니다
<br/>

#### onItemClick
```dart
String? result = await _tnk.onItemClick(adItem.app_id.toString());
```
- Placement View 에서 광고 아이템을 눌렀을 때 호출합니다. 광고 상세 화면으로 이동합니다
- 반드시 `getPlacementJsonData()` 로 목록을 **먼저 조회**해야 합니다. 조회하지 않았거나 목록에 없는 `app_id` 는 `res_code` `"-1"` 을 반환합니다
- 개인정보 수집 동의 전이면 동의 팝업이 먼저 뜹니다. 사용자가 **거부**하면 로딩 화면이 닫히고 `res_code` `"-1"`(`res_message` "개인정보 수집 동의가 필요합니다.")을 반환합니다 (0.8.10 부터. 이전 버전 Android 는 로딩 화면이 닫히지 않고 응답도 오지 않았습니다)
- 응답 전체 구조와 화면 구현 예제는 [Placement View 가이드](./guide_placement.md)를 참고하세요
<br/><br/>

## 플랫폼 지원 현황

| API | Android | iOS |
|---|:-:|:-:|
| `setUserName` · `setCOPPA` · `applicationStarted` | ✅ | ✅ |
| `showATTPopup` | ➖ | ✅ |
| `showAdList` · `setCategoryAndFilter` | ✅ | ✅ |
| `showAdListWithPlacement` | ✅ | ❌ |
| `presentAdDetailView` · `adJoin` · `adAction` | ✅ | ✅ |
| `getEarnPoint` · `getQueryPoint` · `purchaseItem` · `withdrawPoints` · `showMyEarnPointList` | ✅ | ✅ |
| `setNoUsePrivacyAlert` · `setUseTermsPopup` · `setUserTermsAgree` · `isUserTermsAgree` | ✅ | ✅ |
| `setNoUsePointIcon` | ✅ | ✅ |
| `setCustomUnitIcon` | ✅ (`option` 만) | ✅ |
| `setCustomUIDefault` | ❌ | ✅ |
| `setPubCustomUi` | ➖ | ✅ |
| `setOfferwallTheme` · `getOfferwallTheme` | ✅ | ✅ (`"system"` 은 `"unspecified"` 와 동일) |
| `showEventWebPage` · `openTnkEventScheme` | ✅ | ✅ |
| `openEventWebView` | ✅ | ❌ |
| `closeOfferwall` · `closeAdDetail` · `closeAllView` | ➖ | ✅ |
| `getPlacementJsonData` · `onItemClick` | ✅ | ✅ |

- ✅ 지원 / ➖ 호출 가능하나 동작 없음 / ❌ 미지원 (`Platform.isIOS` 등으로 분기 필요)
- `showCustomTapActivity` 는 현재 비활성화되어 있어 두 플랫폼 모두 `"fail"` 을 반환합니다
<br/>

## 포인트 관리 (자체 서버)
포인트를 개발사 서버에서 직접 관리하는 경우, Tnk 사이트의 매체 정보 설정에서 '포인트 관리'를 **'자체서버에서 관리'** 로 선택하고 Callback URL 을 입력합니다.
이후 포인트가 적립될 때마다 해당 URL 로 적립 정보가 HTTP POST 로 전달됩니다.

- 동일한 요청이 반복 호출될 수 있으므로 **`seq_id` 로 반드시 중복 지급을 확인**하세요
- 파라미터 명세, 검증 방법(`md_chk`), 구현 예시는 [Android 가이드](./guide_android.md)의 "포인트 관리"를 참고하세요
<br/>

## 예제 앱
```bash
cd example && flutter run
```
- `example/lib/offerwall.dart` — 오퍼월 및 API 호출 예제
- `example/lib/placement_view.dart` — Placement View 구현 예제
- `example/lib/tnk_flutter_rwd_analytics.dart` — Analytics 이벤트 상수 및 오퍼월 닫힘 통합 처리 유틸리티

# tnk_flutter_rwd

티엔케이팩토리 오퍼월(보상형 광고) Flutter 플러그인입니다. (Android / iOS)

TnkAd SDK는 Tnk의 광고 네트워크 상에서 광고앱이나 매체앱을 개발하기 위하여 제공되는 통합 SDK이며 아래의 기능들을 사용하실 수 있습니다.

- 보상형/구매형 광고의 오퍼월(Offer-wall) 표시
- 특정 광고 상세 진입 / 참여 (`presentAdDetailView`, `adJoin`, `adAction`)
- 포인트 조회 / 차감 / 인출 (Tnk 서버 관리형)
- 오퍼월 UI 커스터마이징 (색상, 포인트 아이콘/단위 표시 방식)
- Placement View — 앱 내 특정 영역에 광고 목록을 직접 렌더링
- 오퍼월 내 사용자 행동 Analytics 이벤트 수신 (광고 클릭/참여, 오퍼월 닫힘 등)
- 이벤트 웹페이지 표시 및 `tnkscheme://` 딥링크 처리

## 요구 사항

| 항목 | 버전 |
| ---- | ---- |
| Dart SDK | >= 2.18.5 < 4.0.0 |
| Flutter | >= 2.5.0 |
| Android | minSdk 21, Kotlin, TNK SDK `com.tnkfactory:rwd` (Maven) |
| iOS | Swift, `TnkRwdSdk2.xcframework` (플러그인에 포함) |

## 설치

```
flutter pub add tnk_flutter_rwd
```

설치 후 플랫폼별 설정(App ID 등록, 권한, 저장소 추가 등)이 필요합니다. 아래 가이드를 참고하세요.

- [Android 가이드](https://github.com/tnkfactory/tnk_flutter_rwd_plugin/blob/master/guide_android.md) — Manifest 권한/App ID 설정, TNK Maven 저장소 추가, Proguard 설정
- [iOS 가이드](https://github.com/tnkfactory/tnk_flutter_rwd_plugin/blob/master/guide_ios.md) — Info.plist App ID / 앱 추적 동의 문구 설정, ATT 처리 흐름

> 테스트 상태에서는 테스트 장비를 개발 장비로 등록해야 광고 목록이 정상적으로 나타납니다. — [테스트 단말기 등록 방법](https://tnkfactory.github.io/incentive/reg_test_device)

## 빠른 시작

```dart
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';

final tnk = TnkFlutterRwd();

Future<void> showOfferwall() async {
  await tnk.showATTPopup();           // iOS ATT 동의 팝업 (Android에서는 무시됨)
  await tnk.setCOPPA(false);          // COPPA 설정
  await tnk.setUserName("my_user");   // 사용자 식별 값 설정 (포인트 콜백 시 전달됨)
  await tnk.showAdList("무료 충전소"); // 오퍼월 표시
}
```

오퍼월 이벤트(광고 클릭/참여, 닫힘) 수신은 `initState`에서 핸들러를 등록합니다.

```dart
MethodChannel('tnk_flutter_rwd').setMethodCallHandler(getOfferWallEvent);
```

자세한 이벤트 처리 방법은 각 플랫폼 가이드의 "오퍼월 이벤트 수신" 섹션을 참고하세요.

## 주요 API 및 플랫폼 지원

| API | 설명 | Android | iOS |
| --- | ---- | :-----: | :-: |
| `setUserName(userName)` | 사용자 식별 값 설정 | ✅ | ✅ |
| `setCOPPA(coppa)` | COPPA 대상 여부 설정 | ✅ | ✅ |
| `showATTPopup()` | ATT 추적 동의 팝업 | ➖ (무동작) | ✅ |
| `showAdList(title, [appId])` | 오퍼월 표시 | ✅ | ✅ |
| `setCategoryAndFilter(category, filter)` | 오퍼월 초기 카테고리/필터 | ✅ | ✅ |
| `showAdListWithPlacement(placementId, categoryId, filterId)` | 플레이스먼트 적용 오퍼월 | ✅ | ❌ |
| `presentAdDetailView(appId, [actionId])` | 광고 상세 화면 | ✅ | ✅ |
| `adJoin(appId, [actionId])` | 광고 참여 | ✅ | ✅ |
| `adAction(appId, [actionId])` | 광고 타입에 따라 참여/상세 자동 | ✅ | ✅ |
| `getEarnPoint()` | 적립 가능 총 포인트 조회 | ✅ | ✅ |
| `getQueryPoint()` | 적립된 포인트 조회 | ✅ | ✅ |
| `purchaseItem(itemId, cost)` | 포인트 차감 (아이템 구매) | ✅ | ✅ |
| `withdrawPoints(description)` | 포인트 전액 인출 | ✅ | ✅ |
| `showMyEarnPointList(map)` | 적립 내역 화면 | ✅ | ✅ |
| `setNoUsePrivacyAlert()` | 개인정보 동의 팝업 비활성화 | ✅ | ✅ |
| `setNoUsePointIcon()` | 포인트 아이콘 비활성화 | ✅ | ✅ |
| `setUseTermsPopup(isUse)` | 약관 팝업 표시 여부 | ✅ | ✅ |
| `setCustomUnitIcon(map)` | 포인트 아이콘/단위 표시 방식 | ✅ (option만) | ✅ |
| `setCustomUIDefault(map)` | 오퍼월 UI 색상 커스터마이징 | ❌ | ✅ |
| `showEventWebPage(map)` | 이벤트 웹페이지 표시 | ✅ | ✅ |
| `openTnkEventScheme(url)` | `tnkscheme://offerwall` 딥링크 처리 | ✅ | ✅ |
| `closeOfferwall()` / `closeAdDetail()` / `closeAllView()` | 화면 닫기 | ❌ | ✅ |
| `getPlacementJsonData(placementId)` | Placement 광고 목록 JSON 조회 | ✅ | ✅ |
| `onItemClick(appId)` | Placement 광고 클릭 처리 | ✅ | ✅ |

- ✅ 지원 / ➖ 호출 가능하나 해당 플랫폼에서는 동작 없음 / ❌ 미지원 (`Platform.isIOS` 등으로 분기 필요)

## 예제 앱

`example/` 디렉토리에 오퍼월 호출, 이벤트 수신, Placement View 구현 예제가 포함되어 있습니다.

```
cd example && flutter run
```

- `example/lib/offerwall.dart` — 오퍼월 및 API 호출 예제
- `example/lib/placement_view.dart` — Placement View 구현 예제
- `example/lib/tnk_flutter_rwd_analytics.dart` — Analytics 이벤트 상수 및 오퍼월 닫힘 통합 처리 유틸리티

## 포인트 관리 (자체 서버)

포인트를 개발사 서버에서 직접 관리하는 경우, Tnk 사이트에서 Callback URL을 설정하면 포인트 적립 시마다 HTTP POST로 적립 정보를 실시간 수신할 수 있습니다. 파라미터 명세와 구현 예시는 각 플랫폼 가이드의 "포인트 관리" 섹션을 참고하세요.

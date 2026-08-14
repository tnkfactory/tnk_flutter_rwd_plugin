## 0.0.1
* 안드로이드 기능 개발
## 0.0.5
* AOS / IOS tnk_pub_flutter 배포
## 0.0.6
* AOS / IOS tnk_pub_flutter 배포
## 0.1.0
* AOS / IOS tnk_pub_flutter 배포
## 0.1.1
* IOS UI 커스터마이징 기능 개발
## 0.1.2
* IOS UI 커스터마이징 기능 수정
## 0.1.3
* IOS UI 커스터마이징 기능 수정
## 0.1.4
* IOS UI 커스터마이징 기능 수정
## 0.1.5
* IOS UI 커스터마이징 기능 수정
## 0.1.6
* IOS UI 커스터마이징 기능 수정
* 폰트 색상변경 
## 0.1.7
* IOS UI 커스터마이징 기능 수정
## 0.1.8
* IOS UI 커스터마이징 기능 수정
## 0.1.9
* IOS UI 커스터마이징 기능 수정
## 0.2.3
* 매체사 대응
## 0.2.4
* 매체사 대응
## 0.2.5
* OfferWall CallBack 함수 구현
## 0.2.7
* placement 광고 가져오는 기능 추가
## 0.2.8
* 약관 팝업 출력 옵션 추가( TnkFlutterRwd.setUseTermsPopup(bool) )
## 0.2.9
* 재화 아이콘 커스텀 기능 추가 (ios)
## 0.3.0
* 재화 아이콘 커스텀 기능 추가 (android)
## 0.3.1
* 안드로이드 약관 팝업 사용 안하는 기능 추가
## 0.3.2
* iOS 에서 광고 상세화면을 닫는 메소드 추가
## 0.3.3
* IOS UI 커스터마이징 기능 추가
## 0.3.4
* IOS 광고상세, 광고 목록 화면 닫는 메소드 추가
## 0.3.5
* UI 커스텀 기능 수정
## 0.3.6
* 오퍼월 진입 후 광고 상세로 바로 진입하는 메소드 추가 
## 0.3.7
* 받아온 광고수가 0이면 JSON데이터 리턴시 실패처리 하도록 수정
## 0.3.8
* IOS UI 커스터마이징 기능 추가
## 0.3.9
* IOS UI 커스터마이징 기능 추가
## 0.4.1
* flutter plugin agp update ( test )
## 0.4.2
* Ios SDK 버전 업데이트
## 0.4.3
* flutter plugin agp update
## 0.4.4
* flutter plugin agp update
## 0.4.5
* 오퍼월 카테고리 index 지정 기능 추가
## 0.5.1
* Android 15 대응
## 0.5.2
* IOS status bar 시스템 테마로 변경
## 0.5.3
* 광고상세 진입 기능 추가 
## 0.5.4
* userName 파라미터 검수 추가
## 0.5.5
* setUserName() userName 파라미터 유효성 체크 
## 0.5.6
* adDetail(), adJoin(), adAction() 추가 
## 0.5.8
* TNK 이벤트 사용을 위한 메소드 추가
## 0.5.9
* TNK rv광고 사용을 위한 라이브러리 추가
## 0.6.0
* iOS 약관처리 프로세스 개선
## 0.6.1
* Placement 광고 lib 업데이트 및 가이드 추가
## 0.6.2
* Android WebView 테마 대응
## 0.6.3
* 매체 커스터마이징 지원 
## 0.6.4
* 매체 오퍼월 커스텀 ui 기능 수정 
## 0.6.6
* 특정 이벤트페이지 호출 메소드 추가
## 0.6.7
* tnk analytics 이벤트 메소드 추가, 커스텀 디자인 수정 
## 0.6.8
* 커스텀 디자인 수정 
## 0.6.9
* 커스텀 디자인 수정
## 0.7.0
* 커스텀 디자인 수정 
## 0.7.1
* 커스텀 디자인 수정 ( 라이트모드 강제 ios )
## 0.7.2
* 커스텀 디자인 수정 ( 라이트모드 강제 ios ) 
## 0.7.3
* 적립내역 이동 기능 추가
## 0.7.4
* TnkAdAnalytics 이벤트 기능 수정
## 0.7.5
* TnkAdAnalytics 이벤트 기능 수정 
## 0.7.7
* LuckyEvent 대응 
## 0.7.8
* 오퍼월이벤트 scheme 처리, 큐레이션영역 커스텀 
## 0.7.9
* 오퍼월이벤트, 큐레이션영역 커스텀
## 0.8.0
* 광고 추적허용 얼럿 커스터마이징(다크모드)
## 0.8.1
* 웹뷰 스킴 공통 처리 핸들러 TnkSchemeHandler 추가 (Android / iOS 공통)
  * tnkscheme://offerwall?title=... : 오퍼월 호출
  * tnkscheme://tnk_event?event_id=... : 이벤트 페이지 호출
  * handleTnkScheme(url) : 매체사 자체 스킴과 함께 사용하는 진입 함수 (TNK 스킴이면 처리 후 true 반환)
  * registerCommand() 로 매체사 커스텀 명령 확장 가능
## 0.8.2
setUserTermsAgree(agree) // 약관동의 상태 변경하는 함수 추가
## 0.8.3
* 약관동의 관련 함수 오류 수정
  * setUserTermsAgree(agree) : 호출 후 응답이 반환되지 않아 Future 가 완료되지 않던 문제 수정 (Android / iOS)
  * isUserTermsAgree() : iOS 에서 setUserName 호출 전이면 응답이 반환되지 않던 문제 수정
  * iOS 약관동의 저장/조회 로직을 SDK 내부 규칙과 동일하게 맞춤 (사용자별 동의 키 사용, 저장된 userName 기준)
  * setUseTermsPopup(isUse) : iOS 에서 isUse=true 인 경우 응답이 반환되지 않던 문제 수정
* openEventWebView(eventId), showCustomTapActivity(url, deepLink) 응답 반환 처리 추가
* Android TNK SDK 8.09.29 적용

## 0.8.4
* Android : 응답이 반환되지 않아 Future 가 완료되지 않던 문제 수정
  * 약관 동의 팝업에서 취소한 경우 (presentAdDetailView / adJoin / adAction) — `res_code` `"-2"` 로 반환
  * getQueryPoint / purchaseItem / withdrawPoints 의 서버 오류 및 중복 호출
  * onItemClick 에 목록에 없는 app_id 를 전달한 경우
  * showEventWebPage / showMyEarnPointList 의 파라미터 누락
  * showAdListWithPlacement 내부 예외
* Android : 응답을 항상 메인 스레드에서 1회만 반환하도록 보장, 응답 대기 한계 시간 추가
* Android : 화면 회전 후 이전 Activity 를 참조하던 문제 수정, 엔진 분리 시 리스너 해제
* Android : MainActivity 가 FlutterFragmentActivity 를 상속하지 않을 때 발생하던 크래시 제거 (실패 응답으로 대체)
* Android : getPlacementJsonData 에서 광고가 1건일 때 실패로 처리되던 문제 수정
* Android TNK SDK 8.09.31 적용
* guide_android.md 갱신 (MainActivity 설정 필수 항목, 광고 참여 API 응답 형식 추가)

## 0.8.5
* iOS : adJoin 에 `useTopViewController` 옵션 추가 (기본값 `false`, 기존 동작 유지)
  * `true` 로 호출하면 최상단에 present 된 화면 위에 광고를 띄웁니다.
  * 다른 화면이 present 된 상태에서 기존 동작으로 호출하면 rootViewController 의 view 가
    window 계층에서 빠져 있어 광고가 표시되지 않고, 그런데도 성공으로 응답되던 문제에 대한 대응입니다.
  * dismiss 가 진행 중이면 완료 후 자동으로 재시도합니다.
* iOS : adJoin 에 `fullscreen` 옵션 추가 (기본값 `false`, 기존 동작 유지)
  * `true` 로 호출하면 바텀시트(`pageSheet`) 가 아니라 `overFullScreen` 으로 표시합니다.
  * 상단 여백과 둥근 모서리는 광고 상세 화면 내부 레이아웃이라 이 옵션으로는 바뀌지 않습니다.
* iOS : showMyEarnPointList 크래시 수정
  * `map["type"]` 을 `as! Int` 로 강제 캐스팅해, 매체가 `{"type": "1"}` 처럼 문자열로 넘기면
    `Could not cast value of type 'NSTaggedPointerString' to 'NSNumber'` 로 죽었습니다.
  * 이 값은 iOS·Android 모두 사용하지 않으므로 캐스팅을 제거했습니다.
* guide_ios.md 갱신 (adJoin 파라메터 및 주의사항 추가)

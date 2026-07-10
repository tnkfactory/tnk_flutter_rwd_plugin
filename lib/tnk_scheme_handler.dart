import 'dart:collection';

import 'tnk_flutter_rwd.dart';

/// 스킴 명령 처리 함수 타입
///
/// [uri] 는 매체 앱에 들어온 스킴 URI, [plugin] 은 TNK 플러그인 인스턴스.
typedef TnkSchemeCommand = Future<void> Function(Uri uri, TnkFlutterRwd plugin);

/// TNK 스킴 공통 핸들러 (Android / iOS 공통, 순수 Dart)
///
/// 웹뷰 NavigationDelegate, 딥링크 등 어떤 진입점에서 들어온 URI 든
/// 동일한 규약으로 처리한다. 플랫폼 분기 없이 사용 가능.
///
/// 스킴 규약: `<scheme>://<command>?<params>`
///   - `<scheme>://offerwall?title=오퍼월타이틀` : 오퍼월 호출 (기본 제공)
///   - `<scheme>://tnk_event?event_id=이벤트ID` : 이벤트 페이지 호출 (기본 제공)
///
/// 사용 예 (웹뷰):
/// ```dart
/// final handler = TnkSchemeHandler(
///   scheme: 'myappscheme',
///   userName: 'user1234',
///   coppa: false,
/// );
///
/// NavigationDelegate(
///   onNavigationRequest: (request) {
///     final uri = Uri.parse(request.url);
///     if (uri.scheme == handler.scheme) {
///       handler.handle(uri);
///       return NavigationDecision.prevent;
///     }
///     return NavigationDecision.navigate;
///   },
/// );
/// ```
///
/// 매체 앱 자체 명령이 필요하면 [registerCommand] 로 확장한다:
/// ```dart
/// handler.registerCommand('event', (uri, plugin) async {
///   await plugin.showEventWebPage(...);
/// });
/// ```
class TnkSchemeHandler {
  TnkSchemeHandler({
    this.scheme = 'tnkscheme',
    this.userName,
    this.coppa,
    this.defaultOfferwallTitle = '오퍼월',
  }) {
    _commands['offerwall'] = _offerwallCommand;
    _commands['tnk_event'] = _offerwallEventCommand;
  }

  /// 처리할 스킴 이름 (예: `tnkscheme://...` 의 `tnkscheme`)
  final String scheme;

  /// 오퍼월 호출 전 설정할 유저명. null 이면 setUserName 을 호출하지 않음
  final String? userName;

  /// 오퍼월 호출 전 설정할 COPPA 값. null 이면 setCOPPA 를 호출하지 않음
  final bool? coppa;

  /// 스킴에 title 파라미터가 없을 때 사용할 오퍼월 타이틀
  final String defaultOfferwallTitle;

  final TnkFlutterRwd _plugin = TnkFlutterRwd();
  final Map<String, TnkSchemeCommand> _commands = {};

  /// 커스텀 명령 등록. [host] 는 URI 의 host 부분 (예: `myapp://event` 의 `event`)
  void registerCommand(String host, TnkSchemeCommand command) {
    _commands[host] = command;
  }

  /// 처리 가능한 URI 인지 여부 (실행하지 않음)
  bool canHandle(Uri uri) {
    return uri.scheme == scheme && _commands.containsKey(uri.host);
  }

  /// 스킴 URI 처리. 처리했으면 true, 규약에 없는 URI 면 false 반환
  Future<bool> handle(Uri uri) async {
    if (uri.scheme != scheme) {
      return false;
    }

    final TnkSchemeCommand? command = _commands[uri.host];
    if (command == null) {
      return false;
    }

    await command(uri, _plugin);
    return true;
  }

  /// 문자열 URL 을 파싱해서 처리. 파싱 불가능하면 false 반환
  Future<bool> handleUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    return handle(uri);
  }

  /// 매체사 앱이 자체 스킴과 함께 사용할 때의 진입 함수
  ///
  /// [url] 이 TNK 스킴([scheme])이면 내부 로직을 처리하고 true 를 반환한다.
  /// 등록되지 않은 명령이어도 TNK 스킴이면 true 를 반환해서
  /// 매체사 스킴 처리 로직으로 넘어가지 않도록 소비한다.
  /// TNK 스킴이 아니면 아무것도 하지 않고 false 를 반환한다.
  ///
  /// 사용 예:
  /// ```dart
  /// if (await tnkSchemeHandler.handleTnkScheme(url)) {
  ///   return; // TNK 스킴 처리 완료
  /// }
  /// // 여기서부터 매체사 자체 스킴 처리
  /// ```
  Future<bool> handleTnkScheme(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != scheme) {
      return false;
    }

    final TnkSchemeCommand? command = _commands[uri.host];
    if (command != null) {
      await command(uri, _plugin);
    }
    return true;
  }

  // 기본 제공: 오퍼월 호출 명령
  Future<void> _offerwallCommand(Uri uri, TnkFlutterRwd plugin) async {
    if (coppa != null) {
      await plugin.setCOPPA(coppa!);
    }
    if (userName != null) {
      await plugin.setUserName(userName!);
    }

    final String title =
        uri.queryParameters['title'] ?? defaultOfferwallTitle;
    await plugin.showAdList(title);
  }

  // 기본 제공: 이벤트 페이지 호출 명령
  // event_id 는 iOS/Android 가 다르므로 웹페이지에서 플랫폼에 맞는 값을 전달해야 함
  Future<void> _offerwallEventCommand(Uri uri, TnkFlutterRwd plugin) async {

    final String? eventId = uri.queryParameters['event_id'];
    if (eventId == null || eventId.isEmpty) {
      return;
    }

    HashMap<String, String> paramMap = HashMap();
    paramMap.addAll({
      "event_id": eventId,
    });
    await plugin.showEventWebPage(paramMap);
  }
}

import 'package:flutter/material.dart';
import 'package:tnk_flutter_rwd/tnk_scheme_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 웹뷰에서 스킴 호출로 오퍼월을 여는 테스트 페이지 (Android / iOS 공통)
///
/// 웹뷰는 http/https 이외의 커스텀 스킴을 스스로 처리하지 못하므로
/// NavigationDelegate.onNavigationRequest 에서 스킴을 가로채야 한다.
/// onNavigationRequest 는 Android WebView / iOS WKWebView 모두 동일하게 동작하므로
/// 여기서 가로채 [TnkSchemeHandler] 로 넘기면 플랫폼 분기 없이 공통 처리된다.
class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  // 플러그인이 제공하는 공통 스킴 핸들러 (Android / iOS 공통, 기본 스킴: tnkscheme)
  final _schemeHandler = TnkSchemeHandler(
    userName: 'testUser',
    coppa: false,
    defaultOfferwallTitle: '미션 수행하기',
  );

  static const String _html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  body { font-family: sans-serif; padding: 24px; }
  h3 { margin-bottom: 24px; }
  button {
    display: block;
    width: 100%;
    padding: 16px;
    margin-bottom: 8px;
    font-size: 16px;
    border: none;
    border-radius: 8px;
    background: #26DACA;
    color: #FFFFFF;
  }
  code { font-size: 12px; color: #515151; }
  .gap { margin-bottom: 24px; }
</style>
</head>
<body>
  <h3>웹뷰 → 오퍼월 스킴 호출 테스트</h3>

  <button onclick="location.href='tnkscheme://offerwall?title=미션 수행하기'">
    오퍼월 열기 (location.href)
  </button>
  <code>tnkscheme://offerwall?title=...</code>
  <div class="gap"></div>

  <button onclick="location.href='tnkscheme://tnk_event?event_id=123'">
    이벤트 페이지 열기
  </button>
  <code>tnkscheme://tnk_event?event_id=...</code>
  <div class="gap"></div>

  <button onclick="location.href='unknownscheme://something'">
    미지원 스킴 호출 (외부 인텐트 fallback)
  </button>
  <code>unknownscheme://something</code>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final Uri uri = Uri.parse(request.url);

            // http/https/데이터 URL 은 웹뷰 내에서 그대로 진행
            if (uri.scheme == 'http' ||
                uri.scheme == 'https' ||
                uri.scheme == 'about' ||
                uri.scheme == 'data') {
              return NavigationDecision.navigate;
            }

            // 커스텀 스킴은 가로채서 공통 핸들러로 처리
            _handleScheme(uri);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadHtmlString(_html);
  }

  Future<void> _handleScheme(Uri uri) async {
    try {
      // TNK 스킴이면 플러그인 내부에서 처리되고 true 반환 → 여기서 종료
      if (await _schemeHandler.handleTnkScheme(uri.toString())) {
        return;
      }
    } on Exception catch (e) {
      _showSnackBar('TNK 스킴 처리 실패: $e');
      return;
    }

    // 여기서부터 매체사 자체 스킴 처리 영역
    // (예제에서는 외부 앱 실행 fallback 으로 대체)
    await _launchExternal(uri);
  }

  Future<void> _launchExternal(Uri uri) async {
    String message;
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      message = launched ? '외부 스킴 호출 성공: $uri' : '외부 스킴 호출 실패: $uri';
    } catch (e) {
      message = '외부 스킴 호출 에러: $e';
    }
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('웹뷰 스킴 테스트'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

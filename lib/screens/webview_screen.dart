import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _handleBack() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      await _controller.goBack();
    } else {
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: CupertinoPageScaffold(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(controller: _controller),
              ),
              if (_loading)
                const Positioned.fill(
                  child: Center(child: CupertinoActivityIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

/// 应用内嵌精简动作教学视频 WebView 预览（免跳出 App 直接观看 B站动作教学）
class InlineTutorialWebView extends StatefulWidget {
  final String url;
  final String title;
  final VoidCallback onOpenExternal;

  const InlineTutorialWebView({
    super.key,
    required this.url,
    required this.title,
    required this.onOpenExternal,
  });

  @override
  State<InlineTutorialWebView> createState() => _InlineTutorialWebViewState();
}

class _InlineTutorialWebViewState extends State<InlineTutorialWebView> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _hasError = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _hasError = true);
          },
          onNavigationRequest: (req) {
            // 拦截唤起外部 App Scheme，防止内嵌预览意外跳出
            if (!req.url.startsWith('http://') && !req.url.startsWith('https://')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: AppTheme.cardDecoration(isDark, radius: 20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 顶部控制栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated,
            child: Row(
              children: [
                const Icon(Icons.play_circle_filled_rounded,
                    color: AppTheme.emberRed, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '应用内精讲预览 · ${widget.title}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '后退',
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                    }
                  },
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '刷新',
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  onPressed: () => _controller.reload(),
                ),
                TextButton(
                  onPressed: widget.onOpenExternal,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    '去B站App',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.emberRed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100.0,
              minHeight: 2.5,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emberRed),
            ),

          SizedBox(
            height: 360,
            child: _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          '内嵌视频加载受限或网络异常',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: widget.onOpenExternal,
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('直接打开 B站 App 观看'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.emberRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : WebViewWidget(
                    controller: _controller,
                    gestureRecognizers: {
                      Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                      ),
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

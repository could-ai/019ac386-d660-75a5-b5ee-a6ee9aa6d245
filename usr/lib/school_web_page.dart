import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SchoolWebPage extends StatefulWidget {
  const SchoolWebPage({super.key});

  @override
  State<SchoolWebPage> createState() => _SchoolWebPageState();
}

class _SchoolWebPageState extends State<SchoolWebPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // تنظیمات کنترلر وب‌ویو
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // مدیریت خطاها در صورت نیاز
          },
          onNavigationRequest: (NavigationRequest request) {
            // اینجا می‌توان لینک‌های خاص را مسدود یا مدیریت کرد
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://schoolp.ir/'));
  }

  // مدیریت دکمه بازگشت گوشی
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false; // جلوگیری از خروج از برنامه
    }
    return true; // خروج از برنامه
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مدرسه پلاس'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          actions: [
            // دکمه رفرش
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _controller.reload();
              },
            ),
            // دکمه‌های ناوبری (عقب و جلو)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  _controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  _controller.goForward();
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // نمایش وب‌سایت
            WebViewWidget(controller: _controller),
            
            // نوار پیشرفت بارگذاری (Loading)
            if (_isLoading)
              LinearProgressIndicator(
                value: _progress,
                color: Colors.orange,
                backgroundColor: Colors.grey[200],
              ),
          ],
        ),
      ),
    );
  }
}

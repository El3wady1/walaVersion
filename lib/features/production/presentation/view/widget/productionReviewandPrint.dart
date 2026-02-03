import 'package:flutter/material.dart';
import 'package:saladafactory/core/utils/Strings.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/services/getLinkofPrintP_S.dart';

class ProductionReviewAndPrint extends StatefulWidget {
  const ProductionReviewAndPrint({super.key});

  @override
  State<ProductionReviewAndPrint> createState() => _ProductionReviewAndPrintState();
}

class _ProductionReviewAndPrintState extends State<ProductionReviewAndPrint> {
  late final WebViewController _controller;
  String? productionPrintUrl;
  bool isLoading = true; // حالة اللودنج

  @override
  void initState() {
    super.initState();
    // جلب الرابط أولًا
    GetLonkProductionS_P(context).then((v) {
      setState(() {
        productionPrintUrl = v; // تحديث الرابط
      });

      // إعداد الـWebView بعد الحصول على الرابط
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'Print',
          onMessageReceived: (message) {
            _printPage();
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) {
              setState(() {
                isLoading = false; // إخفاء اللودنج بعد تحميل الصفحة
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(productionPrintUrl!));
    });
  }

  void _printPage() async {
    await _controller.runJavaScript('window.print();');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Review & Print'),
      ),
      body: productionPrintUrl == null
          ? const Center(child: CircularProgressIndicator()) // أثناء جلب الرابط
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (isLoading)
                  const Center(child: CircularProgressIndicator()), // أثناء تحميل الصفحة
              ],
            ),
    );
  }
}

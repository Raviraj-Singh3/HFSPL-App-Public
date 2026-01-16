import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:HFSPL/network/networkcalls.dart';

class HtmlViewerPage extends StatefulWidget {
  final String memberName;
  final String path;

  const HtmlViewerPage({super.key, required this.memberName, required this.path});

  @override
  State<HtmlViewerPage> createState() => _HtmlViewerPageState();
}

class _HtmlViewerPageState extends State<HtmlViewerPage> {
  final DioClient _client = DioClient();
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF)) // Set a visible background color
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      );

    fetchHtmlContentAndLoad();
  }

  Future<void> fetchHtmlContentAndLoad() async {
    try {
      var htmlContent = await _client.downloadReport(widget.memberName, widget.path);

      if (htmlContent != null && htmlContent.isNotEmpty) {
        // Ensure that the content is loaded correctly
        await _controller.loadHtmlString(htmlContent);
      } else {
        await _controller.loadHtmlString("<h1>No content to display</h1>");
      }
    } catch (e) {
      await _controller.loadHtmlString("<h1>Error loading content</h1>");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Viewer'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

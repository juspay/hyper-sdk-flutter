import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final url;

  WebViewScreen(this.url);

  @override
  createState() => _WebViewScreenState(this.url);
}

class _WebViewScreenState extends State<WebViewScreen> {
  var _url;
  var controller;
  _WebViewScreenState(this._url) {
    this.controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(this._url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(), body: WebViewWidget(controller: controller));
  }
}

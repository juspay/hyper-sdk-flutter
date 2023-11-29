import 'package:flutter/material.dart';
import 'package:hyper_webview_flutter/hyper_webview_flutter.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPaymentPage extends StatefulWidget {
  final HyperSDK hyperSDK;
  final String url;
  late HyperWebviewFlutter _hyperWebviewFlutterPlugin;

  WebviewPaymentPage({Key? key, required this.hyperSDK, required this.url}) : super(key: key);

  @override
  State<WebviewPaymentPage> createState() => _WebviewPaymentPageState();
}

class _WebviewPaymentPageState extends State<WebviewPaymentPage> {
  late WebViewController _controller;
  @override
  void initState() {
    var url = Uri.parse(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(url);
    // WidgetsFlutterBinding.ensureInitialized();
    widget._hyperWebviewFlutterPlugin = HyperWebviewFlutter();
    widget._hyperWebviewFlutterPlugin.attach(_controller);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter PaymentPage',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home : Scaffold(
          body: WebViewWidget(
              controller: _controller
          ),
        )
      // home: HomeScreen(
      //   hyperSDK: hyperSDK,
      // ),
    );
  }
}

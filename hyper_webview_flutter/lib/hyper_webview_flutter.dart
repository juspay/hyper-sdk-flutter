
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer';
import 'dart:convert';
class HyperWebviewFlutter {
  late WebViewController _controller;
  static const HYPER_SDK_BRIDGE = 'HyperWebViewBridge';
  static MethodChannel nativeChannel = const MethodChannel("NativeChannel");
  static MethodChannel dartChannel = const MethodChannel("DartChannel");
  List<String> allowedMethods = const ['findApps', 'openApp', 'getResourceByName'];

  HyperWebviewFlutter() {
    dartChannel.setMethodCallHandler((call) {
      try{
        switch (call.method) {
          case 'onActivityResult':
            Map<String, dynamic> args = Map<String,dynamic>.from(call.arguments);
            int requestCode = args['requestCode'] ?? -1 ;
            int resultCode = args['resultCode'] ?? -1 ;
            dynamic payload = args['payload'];
            returnResultInWebview(requestCode, resultCode, payload);
          default:
            log("HyperWebviewFlutter(DartChannel) : Not handled for function ${call.method}");
        }
      }catch(e){
        log("HyperWebviewFlutter(DartChannel) : Error $e");
      }
      return Future.value(null) ;
    });
  }
  void returnResultInWebview(int requestCode, int resultCode, dynamic result){
    String cmd = "window.onActivityResult(${jsonEncode({ "requestCode" : requestCode , "resultCode" : resultCode, "data" : result})})";
    _controller.runJavaScript(cmd);
  }

  void attach(WebViewController c) {
    _controller = c;
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.addJavaScriptChannel(
        HYPER_SDK_BRIDGE, onMessageReceived: (message) {
      var data = jsonDecode(message.message);
      var fnName = data['fnName'] as String;
      nativeFnCall(args) => nativeChannel.invokeMethod(fnName, args);
      onErrorCallback() => returnResultInWebview(-1, -1, null);
      if (allowedMethods.contains(fnName)) {
        var args = data['args'].cast<dynamic>();
        nativeChannel
            .invokeMethod(fnName, args)
            .then(nativeFnCall)
            .catchError( ( e)  {
              log("HyperWebviewFlutter: attach() error $e");
              onErrorCallback(); //just to not block the mapp, to prevent never-resolving aff
        });
      }else{
        onErrorCallback(); //just to not block the mapp, to prevent never-resolving aff
      }
    });
  }
}

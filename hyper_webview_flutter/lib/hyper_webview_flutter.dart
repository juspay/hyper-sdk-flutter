
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
            bool isEncoded = args["is_encoded"] ?? false;
            returnResultInWebview(requestCode, resultCode, payload, isEncoded);
          default:
            throw 'Not handled for function ${call.method}';
        }
      }catch(e){
        log("HyperWebviewFlutter(DartChannel) Error: $e");
      }
      return Future.value(null) ;
    });
  }

  // this function returns the response in stringified format
  String sanitizeResultdata(dynamic data, bool isEncoded){
    data = data ?? {};
    if(isEncoded && data is String){
      Codec<dynamic, String> codec = utf8.fuse(base64);
      data = codec.decode(data);
    }
    return jsonEncode(data);
  }

  void returnResultInWebview(int requestCode, int resultCode, dynamic result, bool isEncoded){
    String cmd = "window.onActivityResult('$requestCode' , '$resultCode', '${sanitizeResultdata(result, isEncoded)}')";
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
      onErrorCallback() => returnResultInWebview(-1, -1, null, false);
      if (allowedMethods.contains(fnName)) {
        var args = data['args'].cast<dynamic>();
        nativeChannel
            .invokeMethod(fnName, args)
            .then(nativeFnCall)
            .catchError( ( e)  {
              log("HyperWebviewFlutter: attach() Error: $e");
              onErrorCallback();
        });
      }else{
        onErrorCallback();
      }
    });
  }
}

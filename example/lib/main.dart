/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:flutter/material.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';
import 'package:flutter/services.dart';
import './screens/home.dart';
import 'screens/webview_screen.dart';

void main() {
  final hyperSDK = HyperSDK();
  runApp(MyApp(hyperSDK: hyperSDK));
}

class MyApp extends StatelessWidget {
  // Create Juspay Object
  // // block:start:create-hyper-sdk-instance
  final HyperSDK hyperSDK;
  // // block:end:create-hyper-sdk-instance
  const MyApp({Key? key, required this.hyperSDK}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StartScreen(hyperSDK: hyperSDK,)
    );
  }
}
class StartScreen extends StatelessWidget {
  final HyperSDK hyperSDK;
  const StartScreen({Key? key, required this.hyperSDK}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Hyper-SDK Demo'),
        ),
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to WebViewPaymentScreen when the first button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebviewPaymentPage(hyperSDK: hyperSDK,url: "http://localhost:4200"),
                    ),
                  );
                },
                child: Text('PaymentPage In WebView'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to NativePaymentScreen when the second button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(hyperSDK: hyperSDK),
                    ),
                  );
                },
                child: Text('Native PaymentPage'),
              ),
            ],
          ),
        )
    );
  }
}

/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';
import 'package:flutter/services.dart';
import './screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  final hyperSDK = HyperSDK();
  runApp(MyApp(hyperSDK: hyperSDK));
}

void temp() async {
  runApp(const Test());
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
      home: HomeScreen(
        hyperSDK: hyperSDK,
      ),
    );
  }
}

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Inside Android'),
        ),
        body: const Center(
          child: Text('Hello from Flutter!'),
        ),
      ),
    );
  }
}

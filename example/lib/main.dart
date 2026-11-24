/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:visa_infinite_access_sdk_flutter/visa_infinite_access_sdk_flutter.dart';
import 'package:flutter/services.dart';
import './screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  final visaInfiniteAccessSdk = VisaInfiniteAccessSdk();
  runApp(MyApp(visaInfiniteAccessSdk: visaInfiniteAccessSdk));
}

void temp() async {
  runApp(const Test());
}

class MyApp extends StatelessWidget {
  // Create VisaInfiniteAccessSdk object
  // // block:start:create-hyper-sdk-instance
  final VisaInfiniteAccessSdk visaInfiniteAccessSdk;
  // // block:end:create-hyper-sdk-instance
  const MyApp({Key? key, required this.visaInfiniteAccessSdk}) : super(key: key);

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
        visaInfiniteAccessSdk: visaInfiniteAccessSdk,
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

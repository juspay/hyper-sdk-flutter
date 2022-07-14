import 'package:flutter/material.dart';
import 'package:hypersdk/hypersdk.dart';

import './screens/home.dart';

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
    return MaterialApp(
      title: 'Flutter Plugin Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(
        hyperSDK: hyperSDK,
      ),
    );
  }
}

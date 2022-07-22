import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hypersdkflutter/hypersdk.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  final HyperSDK hyperSDK;

  const HomeScreen({Key? key, required this.hyperSDK}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var countProductOne = 0;
  var countProductTwo = 0;

  bool paymentSuccess = false;
  bool paymentFailed = false;

  @override
  Widget build(BuildContext context) {
    initiateHyperSDK();
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Hyper SDK Flutter")),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: const Color(0xFFF8F5F5),
            height: screenHeight / 12,
            child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Text(
                  "Juspay Payments SDK should be initiated on this screen",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void initiateHyperSDK() async {
    if (!await widget.hyperSDK.isInitialised()) {
      var initiatePayload = {
        "requestId": const Uuid().v4(),
        "service": "in.juspay.hyperpay",
        "payload": {
          "action": "initiate",
          "merchantId": "picasso",
          "clientId": "picasso",
          "environment": "sandbox"
        }
      };
      widget.hyperSDK.initiate(initiatePayload, hyperSDKCallbackHandler);
    }
  }

  // Define handler for callbacks from hyperSDK
  // block:start:callback-handler
  void hyperSDKCallbackHandler(MethodCall methodCall) {
    switch (methodCall.method) {
      case "initiate_result":
        break;
      case "hide_loader":
        break;
      case "process_result":
        var args = {};

        try {
          args = json.decode(methodCall.arguments);
        } catch (e) {
          print(e);
        }

        var error = args["error"] ?? false;

        var innerPayload = args["payload"] ?? {};

        var status = innerPayload["status"] ?? " ";
        var pi = innerPayload["paymentInstrument"] ?? " ";
        var pig = innerPayload["paymentInstrumentGroup"] ?? " ";

        if (!error) {
          switch (status) {
            case "charged":
              {
                // Successful Transaction
                // check order status via S2S API
                setState(() {
                  paymentSuccess = true;
                  paymentFailed = false;
                });
              }
              break;
            case "cod_initiated":
              {
                // User opted for cash on delivery option displayed on payment page
              }
              break;
          }
        } else {
          var errorCode = args["errorCode"] ?? " ";
          var errorMessage = args["errorMessage"] ?? " ";
          switch (status) {
            case "backpressed":
              {
                // user back-pressed from PP without initiating any txn
                setState(() {
                  paymentFailed = true;
                  paymentSuccess = false;
                });
              }
              break;
            case "user_aborted":
              {
                // user initiated a txn and pressed back
                // check order status via S2S API
              }
              break;
            case "pending_vbv":
              {}
              break;
            case "authorizing":
              {
                // txn in pending state
                // check order status via S2S API
              }
              break;
            case "authorization_failed":
              {}
              break;
            case "authentication_failed":
              {}
              break;
            case "api_failure":
              {
                // txn failed
                // check order status via S2S API
              }
              break;
            case "new":
              {
                // order created but txn failed
                // check order status via S2S API
              }
              break;
          }
        }
    }
  }
}

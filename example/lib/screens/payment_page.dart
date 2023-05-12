/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hypersdkflutter/hypersdkflutter.dart';

import '../utils/generate_payload.dart';
import './success.dart';
import './failed.dart';

class PaymentPage extends StatefulWidget {
  final HyperSDK hyperSDK;
  final String amount;
  final Map<String, dynamic> merchantDetails;
  final Map<String, dynamic> customerDetails;
  const PaymentPage({Key? key, required this.hyperSDK, required this.amount, required this.merchantDetails, required this.customerDetails})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  var showLoader = true;
  var processCalled = false;
  var paymentSuccess = false;
  var paymentFailed = false;

  @override
  Widget build(BuildContext context) {
    if (!processCalled) {
      callProcess();
    }

    navigateAfterPayment(context);

    // Overriding onBackPressed to handle hardware backpress
    // block:start:onBackPressed
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          var backpressResult = await widget.hyperSDK.onBackPress();

          if (backpressResult.toLowerCase() == "true") {
            return false;
          } else {
            return true;
          }
        } else {
          return true;
        }
      },
      // block:end:onBackPressed
      child: Container(
        color: Colors.white,
        child: Center(
          child: showLoader ? const CircularProgressIndicator() : Container(),
        ),
      ),
    );
  }

  void callProcess() async {
    processCalled = true;

    // Get process payload from backend
    // block:start:fetch-process-payload
    var processPayload = await getProcessPayload(widget.amount, widget.merchantDetails, widget.customerDetails);
    // block:end:fetch-process-payload

    // Calling process on hyperSDK to open payment page
    // block:start:process-sdk
    print('The process payload ${processPayload}');
    await widget.hyperSDK.process(processPayload, hyperSDKCallbackHandler);
    // block:end:process-sdk
  }

  // Define handler for callbacks from hyperSDK
  // block:start:callback-handler
  void hyperSDKCallbackHandler(MethodCall methodCall) {
    switch (methodCall.method) {
      case "hide_loader":
        setState(() {
          showLoader = false;
        });
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
                // block:start:check-order-status
                // Successful Transaction
                // check order status via S2S API
                // block:end:check-order-status
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
                setState(() {
                  paymentFailed = true;
                  paymentSuccess = false;
                });
              }
              break;
            case "pending_vbv":
              {

              }
              break;
            case "authorizing":
              {
                // txn in pending state
                // check order status via S2S API
              }
              break;
            case "authorization_failed":
              {
                setState(() {
                  paymentFailed = true;
                  paymentSuccess = false;
                });
              }
              break;
            case "authentication_failed":
              {
                setState(() {
                  paymentFailed = true;
                  paymentSuccess = false;
                });
              }
              break;
            case "api_failure":
              {
                // txn failed
                // check order status via S2S API
                setState(() {
                  paymentFailed = true;
                  paymentSuccess = false;
                });
              }
              break;
            case "new":
              {
                // order created but txn failed
                // check order status via S2S API
                setState(() {
                  paymentFailed = true;
                  paymentSuccess = false;
                });
              }
              break;
          }
        }
    }
  }
  // block:end:callback-handler

  void navigateAfterPayment(BuildContext context) {
    if (paymentSuccess) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SuccessScreen()));
      });
    } else if (paymentFailed) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FailedScreen()));
      });
    }
  }
}

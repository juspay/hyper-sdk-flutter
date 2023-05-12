/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hypersdkflutter/hypersdkflutter.dart';
import 'package:uuid/uuid.dart';

import './checkout.dart';

import '../widgets/app_bar.dart';
import '../widgets/bottom_button.dart';

class HomeScreen extends StatefulWidget {
  final HyperSDK hyperSDK;

  const HomeScreen({Key? key, required this.hyperSDK}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var countProductOne = 0;
  var countProductTwo = 0;

  var customerDetails = {
    "customerId" : "",
    "customerPhone" : "",
    "customerEmail": ""
  };

  var merchantDetails = {
    "clientId": "",
    "merchantId": "",
    "action": "",
    "returnUrl": "",
    "currency": "INR",
    "privateKey": "",
    "merchantKeyId": "",
    "environment": "",
    "service": ""
  };

  @override
  Widget build(BuildContext context) {
    initiateHyperSDK();

    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar(text: "Home Screen"),
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
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20, top: 15),
            child: const Text(
              "Products",
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFfFB8D33),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: screenHeight / 1.75,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                singleProduct(screenHeight / 1.75, "one", countProductOne),
                singleProduct(screenHeight / 1.75, "two", countProductTwo)
              ],
            ),
          ),
          BottomButton(
              height: screenHeight / 10,
              text: "Go to Cart",
              onpressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                            productOneCount: countProductOne,
                            productTwoCount: countProductTwo,
                            hyperSDK: widget.hyperSDK,
                            merchantDetails: merchantDetails,
                            customerDetails: customerDetails
                          ))))
        ],
      ),
    );
  }

  void initiateHyperSDK() async {
    // Check whether hyperSDK is already initialised
    if (!await widget.hyperSDK.isInitialised()) {
      // Getting initiate payload
      // block:start:get-initiate-payload
      var initiatePayload = {
        "requestId": const Uuid().v4(),
        "service": merchantDetails["service"],
        "payload": {
          "action": "initiate",
          "merchantId": merchantDetails["merchantId"],
          "clientId": merchantDetails["clientId"],
          "environment": merchantDetails["environment"]
        }
      };
      // block:end:get-initiate-payload

      // Calling initiate on hyperSDK instance to boot up payment engine.
      // block:start:initiate-sdk
      await widget.hyperSDK.initiate(initiatePayload, initiateCallbackHandler);
      // block:end:initiate-sdk
    }
  }

  // Define handler for inititate callback
  // block:start:initiate-callback-handler
  
  void initiateCallbackHandler(MethodCall methodCall) {
    if (methodCall.method == "initiate_result") {
      print("Debug initiate_result " + methodCall.arguments);
    } else if (methodCall.method == "process_result") {
      print("Debug process_result " + methodCall.arguments);
    }
  }

  // block:end:initiate-callback-handler

  Widget singleProduct(double height, String text, int itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      height: height / 2,
      child: Column(
        children: [
          Container(
            height: height / 4,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFf5f5f5)),
          ),
          Container(
            height: height / 4,
            color: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Product $text",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                            text: "Price: Rs. 1/item",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        const TextSpan(text: "\n"),
                        const TextSpan(
                            text: "Awesome product description for",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        TextSpan(
                            text: "\nproduct $text",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black)),
                      ])),
                    ),
                    Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: height / 12,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.black, width: 2)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () => decreaseItemQuantity(text),
                                  child: const Icon(
                                    Icons.horizontal_rule_rounded,
                                    color: Color(0xFF115390),
                                  ),
                                ),
                                Text(
                                  itemCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFB8D33)),
                                ),
                                GestureDetector(
                                    onTap: () => increaseItemQuantity(text),
                                    child: const Icon(Icons.add,
                                        color: Color(0xFF115390)))
                              ],
                            ),
                          ),
                        )),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void increaseItemQuantity(String text) {
    if (text == "one") {
      setState(() {
        countProductOne += 1;
      });
    } else {
      setState(() {
        countProductTwo += 1;
      });
    }
  }

  void decreaseItemQuantity(String text) {
    if (text == "one") {
      setState(() {
        if (countProductOne != 0) {
          countProductOne -= 1;
        }
      });
    } else {
      setState(() {
        if (countProductTwo != 0) {
          countProductTwo -= 1;
        }
      });
    }
  }
}

/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../screens/home.dart' as details;


Future<Map<String, dynamic>> getProcessPayload(amount, merchantDetails, customerDetails) async{

  
  // NOTE: This part of code should be handled in the server NOT THE CLIENT APP
  // Merchant should call the session API on their server and return the sdk_payload (sample paylaod hard coded below for reference)

  var orderId = getOrderId();
  var orderDetails = {
    "order_id" : orderId,
    "merchant_id" : merchantDetails["merchantId"],
    "client_id" : merchantDetails["clientId"],
    "amount" : amount,
    "timestamp" : (DateTime.now().millisecondsSinceEpoch).toString(),
    "customer_id" : customerDetails["customerId"],
    "customer_phone" : customerDetails["customerPhone"],
    "customer_email" : customerDetails["customerEmail"],
    "return_url" : merchantDetails["returnUrl"],
    "currency": "INR",
  };

  return {
    "requestId": const Uuid().v4(),
    "service": merchantDetails["service"],
    "payload": {
      "clientId": merchantDetails["clientId"],
      "amount": amount,
      "merchantId": merchantDetails["merchantId"],
      "action": "paymentPage",
      "customerId": customerDetails["customerId"],
      "endUrls": [merchantDetails["returnUrl"]],
      "currency": "INR",
      "customerPhone": customerDetails["customerPhone"],
      "customerEmail": customerDetails["customerEmail"],
      "orderId": orderId,
      "orderDetails": jsonEncode(orderDetails),
      "signature": await signPayload(jsonEncode(orderDetails), merchantDetails["privateKey"]),
      "merchantKeyId": merchantDetails["merchantKeyId"],
      "environment": merchantDetails["environment"]
    }
  };
}

Future<String> signPayload(String payload, String privateKey) async {

  String privateKey1 = privateKey.replaceAll("\n","%0a");
  privateKey1 = privateKey1.replaceAll("+","%2b");

  final url = Uri.parse('https://generate-signature.onrender.com/sign-payload?key=$privateKey1&payload=$payload');
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    print('The encrypted signature : ${utf8.decode(response.bodyBytes)}');
    return utf8.decode(response.bodyBytes);
  } else {
    throw Exception('Failed to sign payload: ${response.reasonPhrase}');
  }
}

String getOrderId() {
  var result           = '';
  var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;
  for ( var i = 0; i < 10; i++ ) {
    result += characters[(Random().nextDouble() * charactersLength).floor()];
  }
  print('The order id ${result}');
  return result;
}

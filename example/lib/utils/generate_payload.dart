/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

Future<Map<String, dynamic>> getProcessPayload(
    amount, merchantDetails, customerDetails) async {
  // NOTE: This part of code should be handled in the server NOT THE CLIENT APP
  // Merchant should call the session API on their server and return the sdk_payload (sample paylaod hard coded below for reference)

  var orderId = getOrderId();
  var orderDetails = {
    "order_id": orderId,
    "merchant_id": merchantDetails["merchantId"],
    "client_id": merchantDetails["clientId"],
    "amount": amount,
    "timestamp": (DateTime.now().millisecondsSinceEpoch).toString(),
    "customer_id": customerDetails["customerId"],
    "customer_phone": customerDetails["customerPhone"],
    "customer_email": customerDetails["customerEmail"],
    "return_url": merchantDetails["returnUrl"],
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
      "signature": await signPayload(
          jsonEncode(orderDetails), merchantDetails["privateKey"]),
      "merchantKeyId": merchantDetails["merchantKeyId"],
      "paymentAttributes": [
        {
          "message": "Extra fee of 35 will be applied on COD",
          "messageType": "INFO",
          "paymentInstrument": ["COD"],
          "paymentInstrumentGroup": "giftCard"
        }
      ],
      "environment": merchantDetails["environment"]
    }
  };
}

Future<String> signPayload(String payload, String privateKey) async {
  String privateKey1 = privateKey.replaceAll("\n", "%0a");
  privateKey1 = privateKey1.replaceAll("+", "%2b");

  final url = Uri.parse(
      'https://generate-signature.onrender.com/sign-payload?key=$privateKey1&payload=$payload');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    print('The encrypted signature : ${utf8.decode(response.bodyBytes)}');
    return utf8.decode(response.bodyBytes);
  } else {
    throw Exception('Failed to sign payload: ${response.reasonPhrase}');
  }
}

String getOrderId() {
  var result = '';
  var characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;
  for (var i = 0; i < 10; i++) {
    result += characters[(Random().nextDouble() * charactersLength).floor()];
  }
  print('The order id $result');
  return result;
}

Future<Map<String, dynamic>> getUpdateOrderPayload(
    String orderId, merchantDetails, customerDetails, newAmount) async {
  var orderDetails = {
    "order_id": orderId,
    "merchant_id": merchantDetails["merchantId"],
    "client_id": merchantDetails["clientId"],
    'amount': newAmount,
    "timestamp": (DateTime.now().millisecondsSinceEpoch).toString(),
    "customer_id": customerDetails["customerId"],
    "customer_phone": customerDetails["customerPhone"],
    "customer_email": customerDetails["customerEmail"],
    "return_url": merchantDetails["returnUrl"],
    "currency": "INR"
  };

  var stringifiedOrderDetails = jsonEncode(orderDetails);

  String signature = await signPayload(stringifiedOrderDetails, merchantDetails['privateKey']);

  Map<String, dynamic> innerPayload = {
    'action': 'updateOrder',
    'orderDetails': stringifiedOrderDetails,
    'signature': signature
  };

  Map<String, dynamic> payload = {
    'requestId': const Uuid().v4(),
    'service': 'in.juspay.hyperpay',
    'payload': innerPayload,
  };

  return payload;
}

// uncomment for Payment Widget
// Map<String, dynamic> getProcessPayload1(
//     amount, merchantDetails, customerDetails) {
//   // NOTE: This part of code should be handled in the server NOT THE CLIENT APP
//   // Merchant should call the session API on their server and return the sdk_payload (sample paylaod hard coded below for reference)

//   var orderId = "yJczz4s5b2";
//   var orderDetails = {
//     "order_id": orderId,
//     "merchant_id": merchantDetails["merchantId"],
//     "client_id": merchantDetails["clientId"],
//     "amount": "2.0",
//     "features": { "paymentWidget": { "enable": true } },
//     "timestamp": "1728583366610",
//     "customer_id": customerDetails["customerId"],
//     "customer_phone": customerDetails["customerPhone"],
//     "customer_email": customerDetails["customerEmail"],
//     "return_url": merchantDetails["returnUrl"],
//     "currency": "INR",
//   };

//   var stringifiedOrderDetails = '{"order_id":"yJczz4s5b2","merchant_id":"A23Games","client_id":"instaastro","amount":"2.0","timestamp":"1728650286350","features":{"paymentWidget":{"enable":true}},"customer_id":"7288829342","customer_phone":"7288829342","customer_email":"yaswanth6240@gmail.com","return_url":"https://www.google.co.in","currency":"INR"}';

//   return {
//     "requestId": const Uuid().v4(),
//     "service": merchantDetails["service"],
//     "payload": {
//       "clientId": merchantDetails["clientId"],
//       "amount": "2.0",
//       "merchantId": merchantDetails["merchantId"],
//       "action": "paymentPage",
//       "customerId": customerDetails["customerId"],
//       "endUrls": [merchantDetails["returnUrl"]],
//       "currency": "INR",
//       "customerPhone": customerDetails["customerPhone"],
//       "customerEmail": customerDetails["customerEmail"],
//       "orderId": orderId,
//       "orderDetails": stringifiedOrderDetails,
//       "signature": "wm+67Eud90JbD+kbDU5u7+4kmyPwcv6YLMo9ejgIm5872RyDRay7mI07c5H+dRT9TteKijZspvFeeKl1NTVppK37miDA4ezgTjio52/BSwGiu7fZ2B1/MvuRMLtnzFUnpavus6GpNuH63XJgEecGL3a0vs2FMlhKi+jv58tqkrOBGZ9MF8N6/HuaCCwO5dFwvM8pHPeLiCZ3NIpyTzISO4ybZUi1C4L2B4MXQ1X8Nkg6fRtj7zmRgKg4LqpUlKWcjcW2fYIkImk6M8Swp9UaeYI4DeE1ODK6nIQHFamEO+yMw7hoxlzTUscCUwlV8aCA6FWGEAJVHZyiVmYDeDNxzQ==",
//       "merchantKeyId": merchantDetails["merchantKeyId"],
//       "environment": merchantDetails["environment"]
//     }
//   };
// }

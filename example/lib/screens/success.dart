/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:flutter/material.dart';

import '../widgets/app_bar.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(text: "Payment Status"),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                  color: Colors.blue,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Text(
                    "Call process on HyperServices instance on Checkout Button Click",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  )),
            ),
            const Expanded(
                flex: 8,
                child: Center(
                  child: Text(
                    "Payment Successful!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ))
          ],
        ));
  }
}

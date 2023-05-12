/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:flutter/material.dart';

AppBar customAppBar({required String text}) {
  return AppBar(
    title: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      const Text("Juspay SDK Integration Demo",style: TextStyle(fontSize: 12)),
      const SizedBox(height: 5,),
      Text(text,style: const TextStyle(fontSize: 16)),
    ]),
    backgroundColor: const Color(0xFF2E2B2C),
  );
}

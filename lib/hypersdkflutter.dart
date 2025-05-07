/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Core class to expose all HyperSDK api's to flutter.
///
/// Proper integration constructs to be followed.
class HyperSDK {
  /// @nodoc
  static MethodChannel hyperSDK = const MethodChannel('hyperSDK');

  /// @nodoc
  void dispose() {
    hyperSDK.setMethodCallHandler(null);
  }

  /// Check if SDK is initiated. If SDK is not initiated first call initiate to setup SDK.
  /// {@category Required}
  Future<bool> isInitialised() async {
    return await hyperSDK.invokeMethod('isInitialised') == true ? true : false;
  }

  /// Creates HyperServices instance with tenantId & clientId.
  /// {@category Optional}
  Future<void> createHyperServicesWithTenantId(
      String tenantId, String clientId) async {
    await hyperSDK.invokeMethod('createHyperServicesWithTenantId',
        <String, dynamic>{'tenantId': tenantId, 'clientId': clientId});
  }

  Future<void> createHyperServices(String clientId) async {
    await hyperSDK.invokeMethod('createHyperServices', <String, dynamic>{'clientId': clientId});
  }

  /// Fetches dynamic assets for SDK.
  /// {@category Optional}
  static Future<String> preFetch(Map<String, dynamic> params) async {
    var result = await hyperSDK.invokeMethod('preFetch', <String, dynamic>{
      'params': params,
    });
    return result.toString();
  }

  /// Initiates and setup's the SDK.
  ///
  /// Boots up required services to reduce latency.
  /// {@category Required}
  Future<String> initiate(Map<String, dynamic> params,
      void Function(MethodCall) initiateHandler) async {
    var result = await hyperSDK.invokeMethod('initiate', <String, dynamic>{
      'params': params,
    });

    // Wrapper function to eliminate redundant Future<dynamic> return value
    Future<dynamic> callbackFunction(MethodCall methodCall) {
      initiateHandler(methodCall);
      return Future.value(0);
    }

    hyperSDK.setMethodCallHandler(callbackFunction);

    return result.toString();
  }

  /// To be called for triggering any actions on SDK.
  ///
  /// Requires payload to be passed for each action.
  /// {@category Required}
  Future<String> process(Map<String, dynamic> params,
      void Function(MethodCall) processHandler) async {
    var result = await hyperSDK.invokeMethod('process', <String, dynamic>{
      'params': params,
    });

    // Wrapper function to eliminate redundant Future<dynamic> return value
    Future<dynamic> callbackFunction(MethodCall methodCall) {
      processHandler(methodCall);
      return Future.value(0);
    }

    hyperSDK.setMethodCallHandler(callbackFunction);
    return result.toString();
  }

  /// Kills the SDK and cleans up any extra resources.
  /// {@category Optional}
  Future<String> terminate() async {
    var result = await hyperSDK.invokeMethod('terminate');
    return result.toString();
  }

  /// Required for Android backpress handling.
  /// {@category Required}
  Future<String> onBackPress() async {
    var result = await hyperSDK.invokeMethod('onBackPress');
    return result.toString();
  }

  Future<String> openPaymentPage(Map<String, dynamic> params,
      void Function(MethodCall) hyperSdkCallBackHandler) async {
    Future<dynamic> callbackFunction(MethodCall methodCall) {
      hyperSdkCallBackHandler(methodCall);
      return Future.value(0);
    }

    hyperSDK.setMethodCallHandler(callbackFunction);
    var result =
        await hyperSDK.invokeMethod('openPaymentPage', <String, dynamic>{
      'params': params,
    });

    return result.toString();
  }

  StatefulWidget hyperSdkView(
      Map<String, dynamic> params, void Function(MethodCall) processHandler) {
    // Wrapper function to eliminate redundant Future<dynamic> return value
    Future<dynamic> callbackFunction(MethodCall methodCall) {
      processHandler(methodCall);
      return Future.value(0);
    }

    hyperSDK.setMethodCallHandler(callbackFunction);

    return Platform.isAndroid
        ? AndroidView(
            viewType: 'HyperSdkViewGroup',
            onPlatformViewCreated: (id) async {
              var viewChannel = MethodChannel('hyper_view_$id');
              Future<dynamic> viewIdCallback(MethodCall methodCall) async {
                print(
                    'Method Channel triggered for platform view ${methodCall.method}, ${methodCall.arguments}');
                if (methodCall.method == 'hyperViewCreated') {
                  var viewId = methodCall.arguments as int;

                  await hyperSDK
                      .invokeMethod('processWithView', <String, dynamic>{
                    'viewId': viewId,
                    'params': params,
                  });
                }
                return Future.value(0);
              }

              viewChannel.setMethodCallHandler(viewIdCallback);
            },
          )
        : UiKitView(
            viewType: 'HyperSdkViewGroup',
            onPlatformViewCreated: (id) async {
              var viewChannel = MethodChannel('hyper_view_$id');
              Future<dynamic> viewIdCallback(MethodCall methodCall) async {
                if (methodCall.method == 'hyperViewCreated') {
                  var viewId = methodCall.arguments as int;

                  await hyperSDK
                      .invokeMethod('processWithView', <String, dynamic>{
                    'viewId': viewId,
                    'params': params,
                  });
                }
                return Future.value(0);
              }

              viewChannel.setMethodCallHandler(viewIdCallback);
            },
          );
  }

  /// Blended payment widget where users can interact with both product and payment UI at the same time as per convenience.
  Widget hyperFragmentView(double height, double width, String namespace,
      Map<String, dynamic> payload, void Function(MethodCall) processHandler) {
    // Wrapper function to eliminate redundant Future<dynamic> return value
    Future<dynamic> callbackFunction(MethodCall methodCall) {
      processHandler(methodCall);
      return Future.value(0);
    }

    hyperSDK.setMethodCallHandler(callbackFunction);

    return Platform.isAndroid
        ? Container(
            height: height,
            width: width,
            child: AndroidView(
              viewType: 'HyperFragmentView',
              onPlatformViewCreated: (id) async {
                var viewChannel = MethodChannel('hyper_fragment_view_$id');

                Future<dynamic> viewIdCallback(MethodCall methodCall) async {
                  if (methodCall.method == 'hyperFragmentViewCreated') {
                    var viewId = methodCall.arguments as int;
                    await hyperSDK.invokeMethod(
                        'hyperFragmentView', <String, dynamic>{
                      'viewId': viewId,
                      'payload': payload,
                      'namespace': namespace
                    });
                  }
                  return Future.value(0);
                }

                viewChannel.setMethodCallHandler(viewIdCallback);
              },
            ))
        : Container(
            height: height,
            width: width,
            child: UiKitView(
              viewType: 'HyperFragmentView',
              onPlatformViewCreated: (id) async {
                var viewChannel = MethodChannel('hyper_fragment_view_$id');
                Future<dynamic> viewIdCallback(MethodCall methodCall) async {
                  if (methodCall.method == 'hyperFragmentViewCreated') {
                    var viewId = methodCall.arguments as int;

                    await hyperSDK.invokeMethod(
                        'hyperFragmentView', <String, dynamic>{
                      'viewId': viewId,
                      'params': payload,
                      'namespace': namespace
                    });
                  }
                  return Future.value(0);
                }

                viewChannel.setMethodCallHandler(viewIdCallback);
              },
            ));
  }


  Future<String> processWithActivity(Map<String, dynamic> params,
    void Function(MethodCall) processHandler) async {
      if (Platform.isIOS) {
        return process(params, processHandler);
      }
      var result = await hyperSDK.invokeMethod('processWithActivity', <String, dynamic>{
        'params': params,
      });

    // Wrapper function to eliminate redundant Future<dynamic> return value
    Future<dynamic> callbackFunction(MethodCall methodCall) {
      processHandler(methodCall);
      return Future.value(0);
    }

    hyperSDK.setMethodCallHandler(callbackFunction);
    return result.toString();
  }
}

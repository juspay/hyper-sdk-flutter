import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

/// Core class to expose all HyperSDK api's to flutter.
///
/// Proper integration constructs to be followed.
class HyperSDK {
  /// @nodoc
  static MethodChannel hyperSDK = const MethodChannel('hyperSDK');

  /// @nodoc
  final Function onInitiateResult;

  /// @nodoc
  final Function onProcessResult;

  /// @nodoc
  final Function onShowLoader;

  /// @nodoc
  final Function onHideLoader;

  HyperSDK({
    required this.onInitiateResult,
    required this.onProcessResult,
    required this.onShowLoader,
    required this.onHideLoader,
  }) {
    hyperSDK.setMethodCallHandler(hyperSDKCallbacks);
  }

  /// @nodoc
  void dispose() {
    hyperSDK.setMethodCallHandler(null);
  }

  /// Check if SDK is initiated. If SDK is not initiated first call initiate to setup SDK.
  /// {@category Required}
  Future<bool> isInitialised() async {
    return await hyperSDK.invokeMethod('isInitialised') == true ? true : false;
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
  Future<String> initiate(Map<String, dynamic> params) async {
    var result = await hyperSDK.invokeMethod('initiate', <String, dynamic>{
      'params': params,
    });
    return result.toString();
  }

  /// To be called for triggering any actions on SDK.
  ///
  /// Requires payload to be passed for each action.
  /// {@category Required}
  Future<String> process(Map<String, dynamic> params) async {
    var result = await hyperSDK.invokeMethod('process', <String, dynamic>{
      'params': params,
    });
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

  /// @nodoc Returns responses for all callbacks for methods exposed above.
  Future<dynamic> hyperSDKCallbacks(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onShowLoader':
        return onShowLoader.call(jsonDecode(methodCall.arguments.toString()));
      case 'onHideLoader':
        return onHideLoader.call(jsonDecode(methodCall.arguments.toString()));
      case 'onInitiateResult':
        return onInitiateResult
            .call(jsonDecode(methodCall.arguments.toString()));
      case 'onProcessResult':
        return onProcessResult
            .call(jsonDecode(methodCall.arguments.toString()));
      default:
        return Future.error('invalid method ${methodCall.method}');
    }
  }
}

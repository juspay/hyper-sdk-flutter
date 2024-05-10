/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Flutter
import UIKit
import HyperSDK

public class SwiftHyperSdkFlutterPlugin: NSObject, FlutterPlugin {
    private static var CHANNEL_NAME = "hyperSDK"
    private let juspay: FlutterMethodChannel
    private lazy var hyperServices: HyperServices = {
        return HyperServices()
    }()
    private let hyperViewController = UIViewController()

    init(_ channel: FlutterMethodChannel, _ registrar: FlutterPluginRegistrar) {
        juspay = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftHyperSdkFlutterPlugin(channel, registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        let factory = HyperPlatformViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "HyperSdkViewGroup")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "preFetch":
            let args = call.arguments as! Dictionary<String, Any>
            preFetch(args["params"] as! [String: Any], result)
        case "initiate":
            let args = call.arguments as! Dictionary<String, Any>
            initiate(args["params"] as! [String: Any], result)
        case "openPaymentPage":
            let args = call.arguments as! Dictionary<String, Any>
            openPaymentPage(args["params"] as! [String: Any], result)
        case "process":
            let args = call.arguments as! Dictionary<String, Any>
            process(args["params"] as! [String: Any], result)
        case "processWithView":
            let args = call.arguments as! Dictionary<String, Any>
            processWithView(args["viewId"] as! Int, args["params"] as! [String: Any], result)
        case "terminate": terminate(result)
        case "isInitialised": isInitialised(result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    private func isInitialised(_ result: @escaping FlutterResult) {
        result(hyperServices.isInitialised())
    }

    private func preFetch(_ params: [String: Any], _ result: @escaping FlutterResult) {
        HyperServices.preFetch(params)
        result(true)
    }

    private func initiate(_ params: [String: Any], _ result: @escaping FlutterResult) {
        hyperViewController.modalPresentationStyle = .overFullScreen
        hyperServices.initiate(hyperViewController, payload: params, callback: { [unowned self] (response) in
            if response == nil {
                return
            }

            let event = response!["event"] as? String ?? ""

            if let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.juspay.invokeMethod(event, arguments: jsonString)
                }
            }
        })
        result(true)
    }

    private func process(_ params: [String: Any], _ result: @escaping FlutterResult) {
        if (self.hyperServices.isInitialised()) {
            let topViewController = (UIApplication.shared.keyWindow?.rootViewController)!
            self.hyperServices.baseViewController = topViewController
            self.hyperServices.shouldUseViewController = true
            self.hyperServices.process(params)
        }
        result(true)
    }

    private func processWithView(_ viewId: Int, _ params: [String: Any], _ result: @escaping FlutterResult) {
        let topViewController = (UIApplication.shared.keyWindow?.rootViewController)!
        if let uiView = topViewController.view.viewWithTag(viewId) {
            // TODO :: uncomment these lines once hyperServices.process(view, payload) once it is ready
//            self.hyperServices.baseViewController = topViewController
//            self.hyperServices.shouldUseViewController = true
//            self.hyperServices.process(uiView, params)
            uiView.backgroundColor = UIColor.green

        } else {
            result(false)
        }
    }

    private func openPaymentPage(_ params: [String: Any], _ result: @escaping FlutterResult) {
        let topViewController = (UIApplication.shared.keyWindow?.rootViewController)!
        HyperCheckoutLite.openPaymentPage(topViewController, payload: params, callback: { [unowned self] (response) in
            if response == nil {
                return
            }

            let event = response!["event"] as? String ?? ""

            if let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.juspay.invokeMethod(event, arguments: jsonString)
                }
            }
        })
        result(true)
    }

    private func terminate(_ result: @escaping FlutterResult) {
        hyperServices.terminate()
        result(true)
    }
}

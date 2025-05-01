/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Flutter
import UIKit
import HyperSDK


public typealias JuspayWebViewConfigurationCallback = (WKWebView) -> ()

@objc public class SwiftHyperSdkFlutterPlugin: NSObject, FlutterPlugin, HyperDelegate {

    private static var CHANNEL_NAME = "hyperSDK"
    private let juspay: FlutterMethodChannel
    private var hyperServices: HyperServices? = nil
    private var processedViewId: Int = -1
    private var processedFragmentViewId: Int = -1
    private let hyperViewController = UIViewController()
    private static var webViewCallback: JuspayWebViewConfigurationCallback? = nil

    init(_ channel: FlutterMethodChannel, _ registrar: FlutterPluginRegistrar) {
        juspay = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftHyperSdkFlutterPlugin(channel, registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        let factory = HyperPlatformViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "HyperSdkViewGroup")
        let fragmentViewFactory = HyperFragmentViewFactory(messenger: registrar.messenger())
        registrar.register(fragmentViewFactory, withId: "HyperFragmentView")
    }

    @objc public func onWebViewReady(_ webView: WKWebView) {
        SwiftHyperSdkFlutterPlugin.webViewCallback?(webView)
    }

    @objc public static func setJuspayWebViewConfigurationCallback(_ callback: @escaping JuspayWebViewConfigurationCallback) {
        self.webViewCallback = callback
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createHyperServicesWithTenantId":
            let args = call.arguments as! Dictionary<String, Any>
            createHyperServicesWithTenantId(args["tenantId"] as? String, args["clientId"] as? String, result);
        case "createHyperServices":
            let args = call.arguments as! Dictionary<String, Any>
            createHyperServices(args["clientId"] as? String, result);
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
        case "hyperFragmentView":
            let args = call.arguments as! Dictionary<String, Any>
            hyperFragmentView(args["viewId"] as! Int, args["params"] as! [String: Any], args["namespace"] as! String, result)
        case "terminate": terminate(result)
        case "isInitialised": isInitialised(result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    private func createHyperServicesWithTenantId(_ tenantId: String?, _ clientId: String?, _ result: @escaping FlutterResult) {
        if (self.hyperServices != nil) {
            result(true)
            return
        }
        if (tenantId == nil || clientId == nil) {
            result(false)
            return
        }
        self.hyperServices = HyperServices(tenantId: tenantId!, clientId: clientId!)
    }

    private func createHyperServices(_ clientId: String?, _ result: @escaping FlutterResult) {
        if (self.hyperServices != nil) {
            result(true)
            return
        }
        self.hyperServices = HyperServices()
    }

    private func isInitialised(_ result: @escaping FlutterResult) {
        result(hyperServices?.isInitialised())
    }

    private func preFetch(_ params: [String: Any], _ result: @escaping FlutterResult) {
        HyperServices.preFetch(params)
        result(true)
    }

    private func initiate(_ params: [String: Any], _ result: @escaping FlutterResult) {
        if (self.hyperServices == nil) {
            self.hyperServices = HyperServices()
        }
        hyperViewController.modalPresentationStyle = .overFullScreen
        self.hyperServices?.initiate(hyperViewController, payload: params, callback: { [unowned self] (response) in
            if response == nil {
                return
            }

            let event = response!["event"] as? String ?? ""

            if (event == "process_result") {
                self.processedViewId = -1
            }

            if let jsonData = try? JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    self.juspay.invokeMethod(event, arguments: jsonString)
                }
            }
        })
        result(true)
    }

    private func process(_ params: [String: Any], _ result: @escaping FlutterResult) {
        guard let hyperServices = self.hyperServices, hyperServices.isInitialised() else {
            result(false)
            return
        }

        if let topViewController = UIApplication.shared.delegate?.window??.rootViewController {
            hyperServices.baseViewController = topViewController
            hyperServices.shouldUseViewController = true
            hyperServices.hyperDelegate = self
            hyperServices.process(params)
            result(true)
        } else {
            result(false)
        }
        result(true)
    }

    private func processWithView(_ viewId: Int, _ params: [String: Any], _ result: @escaping FlutterResult) {
        guard let hyperServices = self.hyperServices, hyperServices.isInitialised() else {
            result(false)
            return
        }

        if let topViewController = UIApplication.shared.delegate?.window??.rootViewController {
            hyperServices.baseViewController = topViewController
            hyperServices.shouldUseViewController = true
            hyperServices.hyperDelegate = self
            hyperServices.process(params)
            result(true)
        } else {
            result(false)
        }
    }



    private func hyperFragmentView(_ viewId: Int, _ params: [String: Any], _ namespace: String, _ result: @escaping FlutterResult) {
        guard let hyperServices = self.hyperServices, hyperServices.isInitialised() else {
            result(false)
            return
        }

        if let topViewController = UIApplication.shared.delegate?.window??.rootViewController {
            hyperServices.baseViewController = topViewController
            hyperServices.shouldUseViewController = false
            hyperServices.hyperDelegate = self
            hyperServices.process(params)
            result(true)
        } else {
            result(false)
        }
    }



    private func manuallyLayoutChildren(_ view: UIView) {
        guard let parent = view.superview else {
            return
        }
        view.frame = parent.bounds
    }

    private func openPaymentPage(_ params: [String: Any], _ result: @escaping FlutterResult) {
        if let topViewController = (UIApplication.shared.delegate?.window??.rootViewController) {
            HyperCheckoutLite.openPaymentPage(topViewController, payload: params, callback: { [unowned self] (response) in
                guard let response = response else {
                    return
                }
                let event = response["event"] as? String ?? ""

                if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted) {
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        self.juspay.invokeMethod(event, arguments: jsonString)
                    }
                }
            })
            result(true)
        } else {
            result(false)
        }
    }

    private func terminate(_ result: @escaping FlutterResult) {
        hyperServices?.terminate()
        result(true)
    }
}

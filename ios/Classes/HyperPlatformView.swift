//
//  HyperPlatformView.swift
//  hypersdkflutter
//
//  Created by Harsh Garg on 09/05/24.
//

import Flutter
import UIKit


class HyperPlatformView: NSObject, FlutterPlatformView {
    private let _view: UIView

    init(viewId: Int64, messenger: FlutterBinaryMessenger, frame: CGRect) {
        let tag = TagProvider.getNewTag()
        let methodChannel = FlutterMethodChannel(name: "hyper_view_\(viewId)", binaryMessenger: messenger)
        _view = UIView(frame: frame)
        _view.tag = tag
        methodChannel.invokeMethod("hyperViewCreated", arguments: tag)
        super.init()
    }

    func view() -> UIView {
        return _view
    }
}

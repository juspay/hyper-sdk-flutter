//
//  HyperUIView.swift
//  hypersdkflutter
//
//  Created by Harsh Garg on 10/05/24.
//

import Foundation

class HyperUIView: UIView {
    private let methodChannel: FlutterMethodChannel?


    init(frame: CGRect, methodChannel: FlutterMethodChannel, tag: Int) {
        self.methodChannel = methodChannel
        super.init(frame: frame)
        self.tag = tag
    }

    required init?(coder: NSCoder) {
        self.methodChannel = nil
        super.init(coder: coder)
    }

    override func didMoveToWindow() {
        methodChannel?.invokeMethod("hyperViewCreated", arguments: tag)
    }
}

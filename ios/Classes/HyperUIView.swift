//
//  HyperUIView.swift
//  hypersdkflutter
//
//  Created by Harsh Garg on 10/05/24.
//

import Foundation

class HyperUIView: UIView {
    private let methodChannel: FlutterMethodChannel?
    private let messageToInvoke: String?

    init(frame: CGRect, methodChannel: FlutterMethodChannel, messageToInvoke: String) {
        self.methodChannel = methodChannel
        self.messageToInvoke = messageToInvoke
        super.init(frame: frame)
        self.tag = getNewTag()
    }

    required init?(coder: NSCoder) {
        self.methodChannel = nil
        self.messageToInvoke = nil
        super.init(coder: coder)
    }

    override func didMoveToWindow() {
        if let messageToInvoke = self.messageToInvoke {
            methodChannel?.invokeMethod(messageToInvoke, arguments: tag)
        } else {
            print("messageToInvoke is nil")
        }
    }

    private func getNewTag() -> Int {
        return Int(arc4random_uniform(UInt32.max))
    }
}

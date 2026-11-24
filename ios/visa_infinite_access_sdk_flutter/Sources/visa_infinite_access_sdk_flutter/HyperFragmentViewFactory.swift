
import UIKit
import Flutter

public class HyperFragmentViewFactory: NSObject, FlutterPlatformViewFactory {
    private let binaryMessenger: FlutterBinaryMessenger

    public init(messenger: FlutterBinaryMessenger) {
        binaryMessenger = messenger
        super.init()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return HyperFragmentView(viewId: viewId, messenger: binaryMessenger, frame: frame)
    }
}


import Flutter
import UIKit

class HyperFragmentView: NSObject, FlutterPlatformView {

    private let _view: UIView
    init(viewId: Int64, messenger: FlutterBinaryMessenger, frame: CGRect) {
        let methodChannel = FlutterMethodChannel(name: "hyper_fragment_view_\(viewId)", binaryMessenger: messenger)
        _view = HyperUIView(frame: frame, methodChannel: methodChannel, messageToInvoke: "hyperFragmentViewCreated")
        super.init()
    }

    func view() -> UIView {
        return _view
    }
}

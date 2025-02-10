package `in`.juspay.hyper_sdk_flutter

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.core.view.ViewCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class HyperFragmentView(
    context: Context,
    viewId: Int,
    binaryMessenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    private val methodChannel: MethodChannel = MethodChannel(binaryMessenger, "hyper_fragment_view_$viewId")
    private val view: FrameLayout = FrameLayout(context)
    private val containerId: Int = ViewCompat.generateViewId()

    init {
        view.id = containerId
        methodChannel.setMethodCallHandler(this)
        methodChannel.invokeMethod("hyperFragmentViewCreated", containerId)
    }

    override fun getView(): View {
        return view;
    }

    override fun dispose() {
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    }
}

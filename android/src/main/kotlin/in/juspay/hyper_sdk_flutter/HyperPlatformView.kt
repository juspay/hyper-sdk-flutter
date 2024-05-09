package `in`.juspay.hyper_sdk_flutter

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.core.view.ViewCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class HyperPlatformView(
    context: Context,
    viewId: Int,
    binaryMessenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    private val methodChannel: MethodChannel = MethodChannel(binaryMessenger, "hyper_view_$viewId")
    private val containerView: FrameLayout = FrameLayout(context)
    private val containerId: Int = ViewCompat.generateViewId()

    init {
        containerView.id = containerId
        methodChannel.setMethodCallHandler(this)
    }

    /** Returns the Android view to be embedded in the Flutter hierarchy.  */
    override fun getView(): View {
        methodChannel.invokeMethod("hyperViewCreated", containerId)
        return containerView
    }

    /**
     * Dispose this platform view.
     *
     *
     * The [PlatformView] object is unusable after this method is called.
     *
     *
     * Plugins implementing [PlatformView] must clear all references to the View object and
     * the PlatformView after this method is called. Failing to do so will result in a memory leak.
     *
     *
     * References related to the Android [View] attached in [ ][.onFlutterViewAttached] must be released in `dispose()` to avoid memory leaks.
     */
    override fun dispose() {

    }

    /**
     * Handles the specified method call received from Flutter.
     *
     *
     * Handler implementations must submit a result for all incoming calls, by making a single
     * call on the given [Result] callback. Failure to do so will result in lingering Flutter
     * result handlers. The result may be submitted asynchronously and on any thread. Calls to
     * unknown or unimplemented methods should be handled using [Result.notImplemented].
     *
     *
     * Any uncaught exception thrown by this method will be caught by the channel implementation
     * and logged, and an error result will be sent back to Flutter.
     *
     *
     * The handler is called on the platform thread (Android main thread) by default, or
     * otherwise on the thread specified by the [BinaryMessenger.TaskQueue] provided to the
     * associated [MethodChannel] when it was created. See also [Threading in
 * the Flutter Engine](https://github.com/flutter/flutter/wiki/The-Engine-architecture#threading).
     *
     * @param call A [MethodCall].
     * @param result A [Result] used for submitting the result of the call.
     */
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    }

}
/*
 * Copyright (c) Juspay Technologies.
 *
 * This source code is licensed under the AGPL 3.0 license found in the
 * LICENSE file in the root directory of this source tree.
 */
@file:Suppress("LogNotTimber")

package `in`.juspay.hyper_sdk_flutter

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.Choreographer
import android.view.View
import android.view.ViewGroup
import android.webkit.WebViewClient
import androidx.fragment.app.FragmentActivity
import `in`.juspay.hypercheckoutlite.HyperCheckoutLite
import `in`.juspay.hypersdk.core.JuspayWebViewConfigurationCallback
import `in`.juspay.hypersdk.core.MerchantViewType
import `in`.juspay.hypersdk.data.JuspayResponseHandler
import `in`.juspay.hypersdk.ui.HyperPaymentsCallback
import `in`.juspay.hypersdk.ui.HyperPaymentsCallbackAdapter
import `in`.juspay.services.HyperServices
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject

class HyperSdkFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var binding: ActivityPluginBinding? = null
    private var hyperServices: HyperServices? = null
    private var isHyperCheckOutLiteInteg: Boolean = false
    private var flutterPluginBinding: FlutterPluginBinding? = null
    private var initiatedWithApplicationContext: Boolean = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hyperSDK")
        this.flutterPluginBinding = flutterPluginBinding
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "HyperSdkViewGroup",
            HyperPlatformViewFactory(flutterPluginBinding.binaryMessenger)
        )
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "HyperFragmentView",
            HyperFragmentViewFactory(flutterPluginBinding.binaryMessenger)
        )
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        this.binding?.removeActivityResultListener(this)
        this.binding = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        try {
            hyperServices?.onActivityResult(requestCode, resultCode, data)
            return true
        } catch (e: Exception) {
            return false
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "createHyperServicesWithTenantId" -> createHyperServicesWithTenantId(call.argument("tenantId"), call.argument("clientId"), result)
            "createHyperServices" -> createHyperServices(call.argument("clientId"), result)
            "preFetch" -> preFetch(call.argument<Map<String, Any>>("params") ?: mapOf(), result)
            "initiate" -> initiate(call.argument<Map<String, Any>>("params") ?: mapOf(), result)
            "process" -> process(call.argument<Map<String, Any>>("params") ?: mapOf(), result)
            "terminate" -> terminate(result)
            "isInitialised" -> isInitialised(result)
            "onBackPress" -> onBackPress(result)
            "openPaymentPage" -> openPaymentPage(call.argument<Map<String, Any>>("params"), result)
            "processWithView" -> processWithView(
                call.argument<Int>("viewId"),
                call.argument<Map<String, Any>>("params") ?: mapOf(),
                result
            )
            "processWithActivity" -> processWithActivity(
                call.argument<Map<String, Any>>("params") ?: mapOf(),
                result
            )
            "hyperFragmentView" -> hyperFragmentView(
                call.argument<Int>("viewId"),
                call.argument<String>("namespace"),
                call.argument<Map<String, Any>>("payload") ?: mapOf(),
                result
            )

            else -> result.notImplemented()
        }
    }

    private fun createHyperServicesWithTenantId(tenantId: String?, clientId: String?, result: Result) {
        val activity = binding?.activity
        if (activity == null) {
            result.error("INIT_ERROR", "Activity is null, cannot proceed", "")
            return
        }
        if (tenantId == null || clientId == null) {
            result.error("INIT_ERROR", "tenantId or clientId cannot be null", "")
            return
        }

        if (activity is FragmentActivity) {
            hyperServices = HyperServices(activity, tenantId, clientId)
            initiatedWithApplicationContext = false
        } else {
            hyperServices = HyperServices(activity.applicationContext, tenantId, clientId)
            initiatedWithApplicationContext = true
        }
        result.success(true)
    }

    private fun onBackPress(result: Result) {
        try {
            if (isHyperCheckOutLiteInteg) {
                val backPress = HyperCheckoutLite.onBackPressed()
                result.success(backPress)
            } else {
                val backPress = hyperServices?.onBackPressed() ?: false
                result.success(backPress)
            }
        } catch (e: Exception) {
            result.error("HYPERSDKFLUTTER: backpress error", e.localizedMessage, e)
        }
    }

    private fun isInitialised(result: Result) {
        try {
            val isInitiated = hyperServices?.isInitialised() ?: false
            result.success(isInitiated)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun preFetch(params: Map<String, Any>, result: Result) {
        try {
            binding?.let { HyperServices.preFetch(it.activity, JSONObject(params)) }
            result.success(true)
        } catch (e: Exception) {
            result.error("HYPERSDKFLUTTER: prefetch error", e.message, e)
        }
    }

    private fun createHyperServices(clientId: String?, result: Result) {
        val activity = binding?.activity
        if (activity == null) {
            result.error("INIT_ERROR", "Activity is null, cannot proceed", "")
            return
        }
        if (clientId == null) {
            result.error("INIT_ERROR", "clientId cannot be null", "")
            return
        }

        if (activity is FragmentActivity) {
            hyperServices = HyperServices(activity, clientId)
            initiatedWithApplicationContext = false
        } else {
            hyperServices = HyperServices(activity.applicationContext, clientId)
            initiatedWithApplicationContext = true
        }
        result.success(true)
    }

    private fun updateHyperPaymentsCallback(hyperPaymentsCallback: HyperPaymentsCallback): HyperPaymentsCallback {
        return object : HyperPaymentsCallback {
            override fun onStartWaitingDialogCreated(parent: View?) {
                hyperPaymentsCallback.onStartWaitingDialogCreated(parent)
            }

            override fun onEvent(event: JSONObject?, handler: JuspayResponseHandler?) {
                if (event != null && event.optString("event") == "process_result") {
                    val processActivity = HyperProcessActivity.getCurrentActivity()
                    if (processActivity != null) {
                        processActivity.finish()
                        processActivity.overridePendingTransition(0, android.R.anim.fade_out)
                    }
                    HyperProcessActivity.setActivityCallback(null)
                }
                hyperPaymentsCallback.onEvent(event, handler)
            }

            override fun getMerchantView(parent: ViewGroup?, viewType: MerchantViewType?): View? {
                return hyperPaymentsCallback.getMerchantView(parent, viewType)
            }

            override fun createJuspaySafeWebViewClient(): WebViewClient? {
                return hyperPaymentsCallback.createJuspaySafeWebViewClient()
            }
        }
    }

    private fun initiate(params: Map<String, Any>, result: Result) {
        try {
            if (binding?.activity == null) {
                result.error("INIT_ERROR", "Activity binding is not available", null)
                return
            }
            val fragmentActivity = binding?.activity as? FragmentActivity
            if (hyperServices == null && fragmentActivity == null) {
                result.error("INIT_ERROR", "HyperServices has not been initialized. Please call createHyperServices first.", null)
                return
            }
            if (hyperServices == null && fragmentActivity is FragmentActivity) {
                hyperServices = HyperServices(fragmentActivity)
            }

            val invokeMethodResult = object : Result {
                override fun success(result: Any?) {
                    Log.d(this.javaClass.canonicalName, "success: ${result.toString()}")
                    println("result = ${result.toString()}")
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e(this.javaClass.canonicalName, "$errorCode\n$errorMessage")
                }

                override fun notImplemented() {
                    Log.e(this.javaClass.canonicalName, "notImplemented")
                }
            }
            val callback = object : HyperPaymentsCallbackAdapter() {
                override fun onEvent(data: JSONObject, p1: JuspayResponseHandler?) {
                    try {
                        channel.invokeMethod(
                            data.getString("event"),
                            data.toString(),
                            invokeMethodResult
                        )
                    } catch (e: Exception) {
                        Log.e(
                            this.javaClass.canonicalName,
                            "Failed to invoke method from native to dart",
                            e
                        )
                    }
                }
            }

            val activity = binding?.activity
            if (!initiatedWithApplicationContext && activity is FragmentActivity) {
                hyperServices?.initiate(
                        activity,
                        JSONObject(params),
                        updateHyperPaymentsCallback(callback)
                )
            } else {
                hyperServices?.initiate(
                        JSONObject(params),
                        updateHyperPaymentsCallback(callback)
                )
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.localizedMessage, e)
        }
    }

    private fun process(params: Map<String, Any>, result: Result) {
        val hyperServices = this.hyperServices
        if (hyperServices == null) {
            result.success(false)
            return
        }
        webViewConfigurationCallback?.let { hyperServices.setWebViewConfigurationCallback(it) }

        val activity = binding?.activity
        if (activity == null) {
            result.error("PROCESS_ERROR", "Activity is null.", null)
            return
        }

        if (initiatedWithApplicationContext) {
            HyperProcessActivity.setActivityCallback(object : ActivityCallback {
                override fun onCreated(fragmentActivity: FragmentActivity) {
                    hyperServices.process(fragmentActivity, JSONObject(params))
                }

                override fun onBackPressed(): Boolean {
                    return hyperServices.onBackPressed()
                }
            })

            val intent = Intent(activity, HyperProcessActivity::class.java)
            activity.startActivity(intent)
            result.success(true)
        } else {
            hyperServices.process(JSONObject(params))
            result.success(true)
        }
    }

    private fun processWithView(id: Int?, params: Map<String, Any>, result: Result) {
        val hyperServices = this.hyperServices
        if (hyperServices == null) {
            result.success(false)
            return
        }
        val activity = binding?.activity as? FragmentActivity
            ?: return result.success(false)
        val view = id?.let { (activity as Activity).findViewById<ViewGroup>(it) }
            ?: return result.success(false)
        webViewConfigurationCallback?.let { hyperServices.setWebViewConfigurationCallback(it) }
        hyperServices.process(activity, view, JSONObject(params))
        result.success(true)
    }

    private fun processWithActivity(params: Map<String, Any>, result: Result) {
        val activity = binding?.activity as? FragmentActivity
            ?: return result.success(false)

        try {
            val hyperServices = this.hyperServices
            if (hyperServices == null) {
                result.success(false)
                return
            }

            HyperProcessActivity.setActivityCallback(object : ActivityCallback {
                override fun onCreated(fragmentActivity: FragmentActivity) {
                    hyperServices.process(fragmentActivity,  JSONObject(params))
                }

                override fun onBackPressed(): Boolean {
                    return hyperServices.onBackPressed()
                }
            })

            val intent = Intent(activity, HyperProcessActivity::class.java)
            activity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }

    private fun hyperFragmentView(id: Int?, namespace: String?, payload: Map<String, Any>, result: Result) {
        val hyperServices = this.hyperServices
        if (hyperServices == null) {
            result.success(false)
            return
        }

        val activity = binding?.activity as? FragmentActivity
            ?: return result.success(false)
        val view = id?.let { (activity as Activity).findViewById<ViewGroup>(it) }
            ?: return result.success(false)

        // setuplayout
        setupLayout(view)
        val jsonPayload = JSONObject(payload)
        val fragments = JSONObject()
        fragments.put(namespace, view)
        jsonPayload.getJSONObject("payload").put("fragmentViewGroups", JSONObject().put(namespace, view));
        webViewConfigurationCallback?.let { hyperServices.setWebViewConfigurationCallback(it) }
        hyperServices.process(activity, jsonPayload)
        result.success(true)
    }

    private fun setupLayout(view: View) {
        Choreographer.getInstance().postFrameCallback(object : Choreographer.FrameCallback {
            override fun doFrame(frameTimeNanos: Long) {
                try {
                    manuallyLayoutChildren(view)
                    view.viewTreeObserver.dispatchOnGlobalLayout()
                    Choreographer.getInstance().postFrameCallback(this)
                } catch (ignore: java.lang.Exception) {
                }
            }
        })
    }

    private fun manuallyLayoutChildren(view: View) {
        val parent = view.parent as ViewGroup ?: return
        val height = parent.measuredHeight
        val width = parent.measuredWidth
        view.measure(
            View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY)
        )
        view.layout(0, 0, width, height)
    }

    private fun openPaymentPage(params: Map<String, Any>?, result: Result) {
        isHyperCheckOutLiteInteg = true
        val invokeMethodResult = object : Result {
            override fun success(result: Any?) {
                Log.d(this.javaClass.canonicalName, "success: ${result.toString()}")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(this.javaClass.canonicalName, "$errorCode\n$errorMessage")
            }

            override fun notImplemented() {
                Log.e(this.javaClass.canonicalName, "notImplemented")
            }
        }
        val callback = object : HyperPaymentsCallbackAdapter() {
            override fun onEvent(data: JSONObject, p1: JuspayResponseHandler?) {
                try {
                    channel.invokeMethod(
                        data.getString("event"),
                        data.toString(),
                        invokeMethodResult
                    )
                } catch (e: Exception) {
                    Log.e(
                        this.javaClass.canonicalName,
                        "Failed to invoke method from native to dart",
                        e
                    )
                }
            }
        }
        val activity = binding?.activity
        if (activity !is FragmentActivity) {
            throw Exception("Kotlin MainActivity should extend FlutterFragmentActivity instead of FlutterActivity!")
        }
        HyperCheckoutLite.openPaymentPage(
            activity,
            params?.let { JSONObject(it) }, callback
        )
        result.success(true)
    }

    private fun terminate(result: Result) {
        if (hyperServices != null) {
            hyperServices?.terminate()
            result.success(true)
        } else {
            Log.w(this.javaClass.canonicalName, "Terminate called without initiate, skipping")
            result.success(false)
        }
    }

    companion object {
        @JvmStatic
        var webViewConfigurationCallback: JuspayWebViewConfigurationCallback? = null
    }
}

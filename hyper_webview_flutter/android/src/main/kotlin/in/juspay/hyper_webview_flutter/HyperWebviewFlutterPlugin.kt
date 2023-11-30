package `in`.juspay.hyper_webview_flutter

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONArray
import org.json.JSONObject
import java.lang.Exception
import androidx.fragment.app.FragmentActivity

/** HyperWebviewFlutterPlugin */
class HyperWebviewFlutterPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener{
  private var binding: ActivityPluginBinding? = null

  private lateinit var channel: MethodChannel
  private lateinit var dartChannel : MethodChannel;

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "NativeChannel")
    channel.setMethodCallHandler(this)
    dartChannel =  MethodChannel(flutterPluginBinding.binaryMessenger, "DartChannel");
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    var args = call.arguments<List<String>>();
    try {
      when (call.method) {
        "findApps" -> {
          var payload = args?.first();
          this.binding?.activity?.let {
            var allApps = UPIInterface.findApps(it as FragmentActivity, payload);
            var output = hashMapOf<String, Any>();
            output["requestCode"] = Constants.FINDAPPS_REQUEST_CODE;
            output["payload"] = allApps;
            dartChannel.invokeMethod("onActivityResult", output);
          }
        }

        "openApp" -> {
          var args = call.arguments<List<String>>();
          var packageName = args!![0];
          var payload = args!![1];
          var action = args!![2];
          var flag = args!![1].toIntOrNull() ?: 0 // whats the correct default?
          this.binding?.activity?.let { UPIInterface.openApp(it as FragmentActivity, packageName, payload, action, flag) };
        }
        "getResourceByName" -> {
          var args = call.arguments<List<String>>();
          var resName = args!![0];
          this.binding?.activity?.let {
             var resourceVal = UPIInterface.getResourceByName(it as FragmentActivity, resName);
             var output = hashMapOf<String, Any>();
             output["requestCode"] = Constants.GET_RESOURCE_NAME;
             output["payload"] = resourceVal;
             dartChannel.invokeMethod("onActivityResult", output);
           };
        }
        else -> {
          result.notImplemented();
          return;
        }
      }
    }catch (e : Exception){
      println("OnMethodCall error "+ e);
    }
    result.success(null);
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding
    binding.addActivityResultListener(this)

  }
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }
  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onDetachedFromActivity() {
    this.binding?.removeActivityResultListener(this)
    this.binding = null
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) : Boolean {
    var output = hashMapOf<String, Any>()
    if(requestCode != Constants.OPENAPPS_REQUEST_CODE){
      return false
    }
    val jsonObject: JSONObject =  toJSON(data?.extras)  ;
    val encoded = Base64.encodeToString(jsonObject.toString().toByteArray(), Base64.NO_WRAP);
    output["payload"] = encoded;
    output["resultCode"] = resultCode;
    output["requestCode"] = requestCode;
    output["is_encoded"] = true;
    dartChannel.invokeMethod( "onActivityResult", output);
    return true;
  }

  // Translated from HYPER-WEBVIEW-Android
  private fun toJSON(bundle: Bundle?): JSONObject {
    val json = JSONObject()
    try {
      if (bundle != null) {
        val keys = bundle.keySet()
        for (key in keys) {
          val value = bundle[key]
          if (value == null) {
            json.put(key, JSONObject.NULL)
          } else if (value is ArrayList<*>) {
            json.put(key, toJSONArray(value))
          } else if (value is Bundle) {
            json.put(key, toJSON(value as Bundle?))
          } else {
            json.put(key, value.toString())
          }
        }
      }
    } catch (ignored: Exception) {
    }
    return json
  }

  // Translated from HYPER-WEBVIEW-Android
  private fun toJSONArray(array: ArrayList<*>): JSONArray {
    val jsonArray = JSONArray()
    for (obj in array) {
      if (obj is ArrayList<*>) {
        jsonArray.put(toJSONArray(obj))
      } else if (obj is JSONObject) {
        jsonArray.put(obj)
      } else {
        jsonArray.put(obj.toString())
      }
    }
    return jsonArray
  }

}

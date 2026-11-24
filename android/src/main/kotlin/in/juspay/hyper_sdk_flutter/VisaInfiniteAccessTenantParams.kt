package `in`.juspay.hyper_sdk_flutter

import `in`.juspay.hyper.bridge.HyperBridge
import `in`.juspay.services.TenantParams
import org.json.JSONObject

internal class VisaInfiniteAccessTenantParams(
    private val clientId: String,
    private val headers: Map<String?, String?>,
) : TenantParams {
    override fun getTenant(): String = "visabenefits"

    override fun getBaseContent(): String? = null

    override fun getOTAEndPoint(): String =
        "https://visabenefits.me1.juspay.io/release/visabenefits/$clientId-android"

    override fun getLogsEndPoint(): JSONObject = JSONObject().apply {
        put("sandboxLogUrl", "https://debug.logs.juspay.net/godel/analytics")
        put("prodLogUrl", "https://visabenefits.me1.juspay.io/logs")
    }

    override fun getHeaders(): Map<String?, String?> = headers

    override fun getBridgeClasses(): MutableList<Class<out HyperBridge>> = mutableListOf()
}

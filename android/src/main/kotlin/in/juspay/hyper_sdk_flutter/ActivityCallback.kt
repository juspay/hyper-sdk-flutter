package `in`.juspay.hyper_sdk_flutter

import androidx.fragment.app.FragmentActivity

interface ActivityCallback {
    fun onCreated(fragmentActivity: FragmentActivity)
    fun onBackPressed(): Boolean
}

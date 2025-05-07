package `in`.juspay.hyper_sdk_flutter

import android.R
import android.os.Bundle
import androidx.fragment.app.FragmentActivity

class HyperProcessActivity : FragmentActivity() {
    companion object {
        private var activityCallback: ActivityCallback? = null
        private var currentActivity: FragmentActivity? = null

        fun setActivityCallback(callback: ActivityCallback?) {
            activityCallback = callback
        }

        fun getCurrentActivity(): FragmentActivity? {
            return currentActivity
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
        currentActivity = this
        activityCallback?.onCreated(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (currentActivity == this) {
            currentActivity = null
        }
    }

    override fun onBackPressed() {
        if (activityCallback?.onBackPressed()!= true) {
            super.onBackPressed()
        }
    }
}

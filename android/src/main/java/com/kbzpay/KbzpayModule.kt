package com.kbzpay

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.kbzbank.payment.KBZPay

@ReactModule(name = KbzpayModule.NAME)
class KbzpayModule(reactContext: ReactApplicationContext) : NativeKbzpaySpec(reactContext) {

  companion object {
    const val NAME = "Kbzpay"
    private const val TAG = "KbzpayModule"
    private const val E_ACTIVITY_DOES_NOT_EXIST = "ACTIVITY_DOES_NOT_EXIST"
    private const val E_PAYMENT_FAILED = "PAYMENT_FAILED"
    private const val E_PAYMENT_CANCELLED = "PAYMENT_CANCELLED"
    private const val KBZPAY_PACKAGE_PRODUCTION = "com.kbzbank.kpaycustomer"
    private const val KBZPAY_PACKAGE_UAT = "com.kbzbank.kpaycustomer.uat"
  }

  private var paymentPromise: Promise? = null
  private var paymentResultReceiver: BroadcastReceiver? = null

  init {
    registerPaymentResultReceiver()
  }

  override fun onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy()
    unregisterPaymentResultReceiver()
  }

  private fun registerPaymentResultReceiver() {
    if (paymentResultReceiver != null) return

    paymentResultReceiver =
            object : BroadcastReceiver() {
              override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == KbzpayCallbackActivity.ACTION_PAYMENT_RESULT) {
                  handlePaymentResult(intent)
                }
              }
            }

    val filter = IntentFilter(KbzpayCallbackActivity.ACTION_PAYMENT_RESULT)
    try {
      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
        reactApplicationContext.registerReceiver(
                paymentResultReceiver,
                filter,
                Context.RECEIVER_NOT_EXPORTED
        )
      } else {
        reactApplicationContext.registerReceiver(paymentResultReceiver, filter)
      }
      Log.d(TAG, "✅ Payment receiver registered")
    } catch (e: Exception) {
      Log.e(TAG, "❌ Failed to register receiver: ${e.message}", e)
    }
  }

  private fun unregisterPaymentResultReceiver() {
    paymentResultReceiver?.let { receiver ->
      try {
        reactApplicationContext.unregisterReceiver(receiver)
        Log.d(TAG, "✅ Payment receiver unregistered")
      } catch (e: Exception) {
        Log.e(TAG, "Error unregistering: ${e.message}")
      }
      paymentResultReceiver = null
    }
  }

  private fun handlePaymentResult(intent: Intent) {
    try {
      val resultCode = intent.getIntExtra(KBZPay.EXTRA_RESULT, -1)
      val orderId = intent.getStringExtra(KBZPay.EXTRA_ORDER_ID) ?: ""
      val failMsg = intent.getStringExtra(KBZPay.EXTRA_FAIL_MSG) ?: ""

      Log.d(TAG, "📊 Result received: code=$resultCode, order=$orderId")

      val result =
              Arguments.createMap().apply {
                putInt("resultCode", resultCode)
                putString("orderId", orderId)
                putString("failMsg", failMsg)
              }

      paymentPromise?.let { p ->
        when (resultCode) {
          KBZPay.COMPLETED -> {
            Log.d(TAG, "✅ Payment success")
            p.resolve(result)
          }
          KBZPay.FAIL -> {
            Log.e(TAG, "❌ Payment failed: $failMsg")
            p.reject(E_PAYMENT_FAILED, failMsg, result)
          }
          KBZPay.CANCEL -> {
            Log.w(TAG, "⚠️ Payment cancelled")
            p.reject(E_PAYMENT_CANCELLED, "Cancelled", result)
          }
          else -> {
            Log.w(TAG, "⚠️ Unknown: $resultCode")
            p.reject(E_PAYMENT_CANCELLED, "Unknown", result)
          }
        }
        paymentPromise = null
      }
    } catch (e: Exception) {
      Log.e(TAG, "❌ Error: ${e.message}", e)
      paymentPromise?.reject("RESULT_ERROR", e.message, e)
      paymentPromise = null
    }
  }

  @ReactMethod
  override fun initialize(appId: String, merchCode: String, promise: Promise) {
    try {
      if (reactApplicationContext.currentActivity == null) {
        promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "No activity")
        return
      }
      Log.d(TAG, "✅ Initialized")
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject("INIT_ERROR", e.message, e)
    }
  }

  @ReactMethod
  override fun isKBZPayInstalled(promise: Promise) {
    try {
      val activity = reactApplicationContext.currentActivity
      if (activity == null) {
        promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "No activity")
        return
      }

      val pm = activity.packageManager
      val isInstalled =
              try {
                pm.getPackageInfo(KBZPAY_PACKAGE_PRODUCTION, 0)
                true
              } catch (e: Exception) {
                try {
                  pm.getPackageInfo(KBZPAY_PACKAGE_UAT, 0)
                  true
                } catch (e2: Exception) {
                  false
                }
              }

      promise.resolve(isInstalled)
    } catch (e: Exception) {
      promise.reject("CHECK_ERROR", e.message, e)
    }
  }

  @ReactMethod
  override fun startPayment(
          appId: String,
          merchCode: String,
          prepayId: String,
          orderInfo: String,
          sign: String,
          appScheme: String?,
          promise: Promise
  ) {
    val activity = reactApplicationContext.currentActivity
    if (activity == null) {
      promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "No activity")
      return
    }

    paymentPromise = promise

    try {
      Log.d(TAG, "🚀 Starting payment")
      KBZPay.startPay(activity, orderInfo, sign, "SHA256")
      Log.d(TAG, "✅ Request sent, waiting for callback...")
    } catch (e: Exception) {
      Log.e(TAG, "❌ Payment error: ${e.message}", e)
      paymentPromise?.reject("PAYMENT_ERROR", e.message, e)
      paymentPromise = null
    }
  }
}

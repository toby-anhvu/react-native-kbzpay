package com.kbzpay

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.kbzbank.payment.KBZPay

@ReactModule(name = KbzpayModule.NAME)
class KbzpayModule(reactContext: ReactApplicationContext) :
        NativeKbzpaySpec(reactContext), ActivityEventListener {

  companion object {
    const val NAME = "Kbzpay"
    private const val TAG = "KbzpayModule"
    private const val E_ACTIVITY_DOES_NOT_EXIST = "ACTIVITY_DOES_NOT_EXIST"
    private const val E_PAYMENT_FAILED = "PAYMENT_FAILED"
    private const val E_PAYMENT_CANCELLED = "PAYMENT_CANCELLED"

    // KBZPay app package names
    private const val KBZPAY_PACKAGE_PRODUCTION = "com.kbzbank.kpaycustomer"
    private const val KBZPAY_PACKAGE_UAT = "com.kbzbank.kpaycustomer.uat"

    // Request codes
    private const val REQUEST_CODE_KBZPAY = 9001
  }

  private var paymentPromise: Promise? = null

  init {
    reactContext.addActivityEventListener(this)
  }

  @ReactMethod
  override fun initialize(appId: String, merchCode: String, promise: Promise) {
    try {
      val activity = reactApplicationContext.currentActivity

      if (activity == null) {
        promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist")
        return
      }
      Log.d(TAG, "✅ KBZPay initialized (no-op)")
      promise.resolve(true)
    } catch (e: Exception) {
      Log.e(TAG, "❌ Init error: ${e.message}", e)
      promise.reject("INIT_ERROR", e.message, e)
    }
  }

  @ReactMethod
  override fun isKBZPayInstalled(promise: Promise) {
    Log.d(TAG, "🔍 Checking KBZPay installation...")
    try {
      val activity = reactApplicationContext.currentActivity

      if (activity == null) {
        Log.e(TAG, "❌ Activity is null")
        promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist")
        return
      }

      val packageManager = activity.packageManager
      var isInstalled = false

      // Try Production package first
      try {
        packageManager.getPackageInfo(KBZPAY_PACKAGE_PRODUCTION, 0)
        isInstalled = true
        Log.d(TAG, "✅ Found Production KBZPay app")
      } catch (e: Exception) {
        // Try UAT package
        try {
          packageManager.getPackageInfo(KBZPAY_PACKAGE_UAT, 0)
          isInstalled = true
          Log.d(TAG, "✅ Found UAT KBZPay app")
        } catch (e2: Exception) {
          isInstalled = false
          Log.d(TAG, "❌ KBZPay app not found")
        }
      }

      promise.resolve(isInstalled)
    } catch (e: Exception) {
      Log.e(TAG, "❌ Check install error: ${e.message}", e)
      promise.reject("CHECK_INSTALL_ERROR", e.message, e)
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
      Log.e(TAG, "❌ Activity is null")
      promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist")
      return
    }

    // Store promise for callback
    paymentPromise = promise

    try {
      KBZPay.startPay(activity, orderInfo, sign, "SHA256")
      Log.d(TAG, "🚀 Payment request sent to KBZPay SDK")
    } catch (e: Exception) {
      Log.e(TAG, "❌ Payment error: ${e.message}", e)
      paymentPromise?.let { p ->
        p.reject("PAYMENT_ERROR", e.message, e)
        paymentPromise = null
      }
    }
  }

  override fun onActivityResult(
          activity: Activity,
          requestCode: Int,
          resultCode: Int,
          data: Intent?
  ) {
    Log.d(TAG, "onActivityResult: requestCode=$requestCode, resultCode=$resultCode")

    if (data == null) {
      Log.d(TAG, "Intent data is null")
      return
    }

    try {
      val resultCodeFromIntent = data.getIntExtra(KBZPay.EXTRA_RESULT, -1)
      val orderId = data.getStringExtra(KBZPay.EXTRA_ORDER_ID) ?: ""
      val failMsg = data.getStringExtra(KBZPay.EXTRA_FAIL_MSG) ?: ""

      Log.d(TAG, "📊 Payment callback received")
      Log.d(TAG, "Result Code: $resultCodeFromIntent")
      Log.d(TAG, "Order ID: $orderId")
      Log.d(TAG, "Fail Message: $failMsg")

      val result =
              Arguments.createMap().apply {
                putInt("resultCode", resultCodeFromIntent)
                putString("orderId", orderId)
                putString("failMsg", failMsg)
              }

      paymentPromise?.let { p ->
        when (resultCodeFromIntent) {
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
            p.reject(E_PAYMENT_CANCELLED, "Payment cancelled", result)
          }
          else -> {
            Log.w(TAG, "⚠️ Unknown result: $resultCodeFromIntent")
            p.reject(E_PAYMENT_CANCELLED, "Unknown result", result)
          }
        }
        paymentPromise = null
      }
    } catch (e: Exception) {
      Log.e(TAG, "❌ Error processing result: ${e.message}", e)
      paymentPromise?.let { p ->
        p.reject("RESULT_ERROR", e.message, e)
        paymentPromise = null
      }
    }
  }

  override fun onNewIntent(intent: Intent) {
    Log.d(TAG, "onNewIntent: $intent")
  }
}

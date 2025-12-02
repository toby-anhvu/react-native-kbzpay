package com.kbzpay

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.kbzbank.payment.KBZPay

class KbzpayCallbackActivity : Activity() {

    companion object {
        private const val TAG = "KbzpayCallback"
        const val ACTION_PAYMENT_RESULT = "com.kbzpay.PAYMENT_RESULT"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "🎯 KbzpayCallbackActivity created")
        handleCallback()
    }

    private fun handleCallback() {
        try {
            val intent = intent

            if (intent == null) {
                Log.e(TAG, "❌ Intent is null")
                finish()
                return
            }

            // Extract payment result
            val resultCode = intent.getIntExtra(KBZPay.EXTRA_RESULT, -1)
            val orderId = intent.getStringExtra(KBZPay.EXTRA_ORDER_ID) ?: ""
            val failMsg = intent.getStringExtra(KBZPay.EXTRA_FAIL_MSG) ?: ""

            Log.d(TAG, "📊 Payment callback received")
            Log.d(TAG, "Result Code: $resultCode")
            Log.d(TAG, "Order ID: $orderId")

            val resultIntent = Intent(ACTION_PAYMENT_RESULT)
            resultIntent.putExtra(KBZPay.EXTRA_RESULT, resultCode)
            resultIntent.putExtra(KBZPay.EXTRA_ORDER_ID, orderId)
            resultIntent.putExtra(KBZPay.EXTRA_FAIL_MSG, failMsg)

            sendBroadcast(resultIntent)

            Log.d(TAG, "✅ Broadcast sent")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error: ${e.message}", e)
        } finally {
            finish()
        }
    }
}

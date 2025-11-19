package com.kbzpay

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import java.util.HashMap

class KbzpayPackage : BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return if (name == KbzpayModule.NAME) {
      KbzpayModule(reactContext)
    } else {
      null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
      val isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
      moduleInfos[KbzpayModule.NAME] = ReactModuleInfo(
        KbzpayModule.NAME,
        KbzpayModule.NAME,
        false,  // canOverrideExistingModule
        false,  // needsEagerInit
        false,  // isCxxModule
        isTurboModule // isTurboModule - enabled with New Architecture
      )
      moduleInfos
    }
  }
}

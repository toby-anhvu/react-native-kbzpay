import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  var reactNativeDelegate: ReactNativeDelegate?
  var reactNativeFactory: RCTReactNativeFactory?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let delegate = ReactNativeDelegate()
    let factory = RCTReactNativeFactory(delegate: delegate)
    delegate.dependencyProvider = RCTAppDependencyProvider()

    reactNativeDelegate = delegate
    reactNativeFactory = factory

    window = UIWindow(frame: UIScreen.main.bounds)

    factory.startReactNative(
      withModuleName: "KbzpayExample",
      in: window,
      launchOptions: launchOptions
    )

    return true
  }

  //  Handle Deep Link for KBZPay
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    
    print("📱 [AppDelegate] Received deep link: \(url.absoluteString)")
    
    // Get the bridge from factory
    if let bridge = reactNativeFactory?.bridge {
      // Get Kbzpay module by class name
      if let kbzpayModule = bridge.module(forName: "Kbzpay") as? NSObject {
        print("✅ [AppDelegate] Found Kbzpay module, handling URL...")
        // Call handleOpenURL method dynamically
        let selector = NSSelectorFromString("handleOpenURL:")
        if kbzpayModule.responds(to: selector) {
          kbzpayModule.perform(selector, with: url)
          return true
        }
      } else {
        print("⚠️ [AppDelegate] Kbzpay module not found")
      }
    } else {
      print("⚠️ [AppDelegate] Bridge not available")
    }
    
    return false
  }
}

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    self.bundleURL()
  }

  override func bundleURL() -> URL? {
#if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}

import Foundation
import React
import KBZPayAPPPay

@objc(Kbzpay)
class Kbzpay: NSObject {
    
    // MARK: - Properties
    
    private var paymentResolve: RCTPromiseResolveBlock?
    private var paymentReject: RCTPromiseRejectBlock?
    private var currentAppScheme: String?
    
    @objc
    static func moduleName() -> String! {
        return "Kbzpay"
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    // MARK: - Initialize
    
    @objc func initialize(
        _ appId: String,
        merchCode: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            print("✅ KBZPay iOS SDK initialized with AppID: \(appId), MerchCode: \(merchCode)")
            resolve(true)
        } catch {
            print("❌ KBZPay initialization error: \(error.localizedDescription)")
            reject("INIT_ERROR", error.localizedDescription, error)
        }
    }
    
    // MARK: - Check Installation
    
    @objc func isKBZPayInstalled(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        do {
            guard let kbzpayURL = URL(string: "kbzpay://") else {
                resolve(false)
                return
            }
            
            let isInstalled = UIApplication.shared.canOpenURL(kbzpayURL)
            print("🔍 KBZPay installation check: \(isInstalled ? "INSTALLED ✅" : "NOT INSTALLED ❌")")
            resolve(isInstalled)
        } catch {
            print("❌ Check installation error: \(error.localizedDescription)")
            reject("CHECK_INSTALL_ERROR", error.localizedDescription, error)
        }
    }
    
    // MARK: - Start Payment
    
    @objc func startPayment(
        _ appId: String,
        merchCode: String,
        prepayId: String,
        orderInfo: String,
        sign: String,
        appScheme: String?,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Store promise and app scheme for callback
                self.paymentResolve = resolve
                self.paymentReject = reject
                self.currentAppScheme = appScheme
                
                print("🚀 Starting KBZPay payment...")
                print("📦 Order Info: \(orderInfo)")
                print("🔐 Sign: \(sign)")
                print("🔗 App Scheme: \(appScheme ?? "nil")")
                
                // Check if KBZPay app is installed
                guard let kbzpayURL = URL(string: "kbzpay://"),
                      UIApplication.shared.canOpenURL(kbzpayURL) else {
                    print("❌ KBZPay app is not installed")
                    reject("KBZPAY_NOT_INSTALLED", "KBZPay app is not installed. Please install it from App Store.", nil)
                    self.clearPromises()
                    return
                }
                
                // Get the root view controller
                guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
                    print("❌ Root view controller not found")
                    reject("NO_ROOT_CONTROLLER", "Could not get root view controller", nil)
                    self.clearPromises()
                    return
                }
                
                // Get the top-most view controller
                var topViewController = rootViewController
                while let presented = topViewController.presentedViewController {
                    topViewController = presented
                }
                
                // Create PaymentViewController instance
                let paymentVC = PaymentViewController()
                
                // Start payment with KBZPay SDK
                paymentVC.startPay(
                    withOrderInfo: orderInfo,
                    signType: "SHA256",
                    sign: sign,
                    appScheme: appScheme ?? ""
                )
                
                print("✅ Payment request sent to KBZPay SDK")
                
            } catch {
                print("❌ Payment error: \(error.localizedDescription)")
                reject("PAYMENT_ERROR", error.localizedDescription, error)
                self.clearPromises()
            }
        }
    }
    
    // MARK: - Handle Deep Link Callback
    
    @objc func handleOpenURL(_ url: URL) {
        print("📱 Handling deep link callback: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ Invalid callback URL")
            if let reject = paymentReject {
                reject("INVALID_URL", "Invalid callback URL", nil)
            }
            clearPromises()
            return
        }
        
        // Default values
        var resultCode = 3 // Default to failed
        var orderId = ""
        var failMsg = ""
        
        // Extract query parameters
        if let queryItems = components.queryItems {
            for item in queryItems {
                switch item.name {
                case "EXTRA_RESULT":
                    if let value = item.value, let code = Int(value) {
                        resultCode = code
                        print("📊 Result Code: \(resultCode)")
                    }
                case "EXTRA_ORDER_ID":
                    orderId = item.value ?? ""
                    print("📝 Order ID: \(orderId)")
                case "EXTRA_FAIL_MSG":
                    failMsg = item.value ?? ""
                    print("⚠️ Fail Message: \(failMsg)")
                default:
                    break
                }
            }
        }
        
        // Create result dictionary
        let result: [String: Any] = [
            "resultCode": resultCode,
            "orderId": orderId,
            "failMsg": failMsg
        ]
        
        // Handle payment result
        // resultCode: 0 = Success, 2 = Cancelled, 3 = Failed
        switch resultCode {
        case 0:
            print("✅ Payment successful!")
            if let resolve = paymentResolve {
                resolve(result)
            }
            
        case 2:
            print("⚠️ Payment cancelled by user")
            if let reject = paymentReject {
                reject("PAYMENT_CANCELLED", "Payment cancelled by user", nil)
            }
            
        case 3:
            print("❌ Payment failed: \(failMsg)")
            if let reject = paymentReject {
                let message = failMsg.isEmpty ? "Payment failed" : failMsg
                reject("PAYMENT_FAILED", message, nil)
            }
            
        default:
            print("⚠️ Unknown payment result: \(resultCode)")
            if let reject = paymentReject {
                reject("PAYMENT_UNKNOWN", "Unknown payment result", nil)
            }
        }
        
        clearPromises()
    }
    
    // MARK: - Helper Methods
    
    private func clearPromises() {
        paymentResolve = nil
        paymentReject = nil
        currentAppScheme = nil
    }
}


# KBZPay iOS SDK

## Current Version

SDK Version: **1.3.0**

## Framework Details

- **Name**: KBZPayAPPPay.framework
- **Version**: 1.3+
- **Architecture**: Universal (armv7, arm64, x86_64)
- **Minimum iOS**: 11.0
- **Language**: Objective-C

## How to Add SDK

### Option 1: From docs/sdk (Included)

Framework đã được include trong project. Copy từ:

- **Production**: `docs/sdk/1.3/framework/prod/KBZPayAPPPay.framework`
- **Simulator**: `docs/sdk/1.3/framework/simulator/KBZPayAPPPay.framework`

### Option 2: Download từ KBZPay

Contact: [email protected]
Download: https://wap.kbzpay.com/pgw/uat/api/#/en/docs/InApp/in-app-download-en

### Steps

1. Copy framework vào thư mục này: `ios/Frameworks/`
2. Chạy `pod install` trong thư mục iOS
3. Framework sẽ tự động được link qua podspec

## Framework Structure

```
ios/Frameworks/KBZPayAPPPay.framework/
├── Headers/
│   ├── KBZPayAPPPay.h          # Main header
│   └── PaymentViewController.h  # Payment interface
├── Info.plist                   # Framework info
├── KBZPayAPPPay                # Binary
└── Modules/
    └── module.modulemap         # Module map
```

## API Reference

### PaymentViewController

```objc
@interface PaymentViewController : UIViewController

- (void)startPayWithOrderInfo:(NSString *)orderInfo
                     signType:(NSString *)signType
                         sign:(NSString *)sign
                    appScheme:(NSString *)appScheme;

@end
```

### Parameters

- `orderInfo`: Chuỗi thông tin đơn hàng
- `signType`: Luôn dùng `"SHA256"`
- `sign`: Chữ ký SHA256
- `appScheme`: URL scheme của app để nhận callback

### Swift Usage

```swift
import KBZPayAPPPay

let paymentVC = PaymentViewController()
paymentVC.startPay(
    withOrderInfo: orderInfo,
    signType: "SHA256",
    sign: sign,
    appScheme: "yourappscheme"
)
```

## Payment Flow

```
Your App → PaymentViewController.startPay()
         → Opens KBZPay App
         → User completes payment
         → KBZPay returns via deep link
         → Your App handles callback
```

## Callback Format

```
yourappscheme://?EXTRA_RESULT=0&EXTRA_ORDER_ID=xxx&EXTRA_FAIL_MSG=
```

### Result Codes

- `0` = Success ✅
- `2` = Cancelled ⚠️
- `3` = Failed ❌

## Integration

Framework được tự động cấu hình qua CocoaPods. Xem [iOS Setup Guide](../../md/IOS_SETUP.md) để biết chi tiết.

## Requirements

1. **Info.plist**: Add `kbzpay` to LSApplicationQueriesSchemes
2. **Info.plist**: Configure CFBundleURLTypes với app scheme của bạn
3. **AppDelegate**: Implement deep link handling

Xem chi tiết tại [iOS Setup Guide](../../md/IOS_SETUP.md)

## Troubleshooting

### Framework Not Found

```bash
cd ios && rm -rf Pods Podfile.lock && pod install
```

### Module Not Found

1. Clean build (Cmd + Shift + K)
2. Rebuild project

### Simulator vs Device

- Device: Dùng production framework
- Simulator: Dùng simulator framework

## Documentation

- 📱 [iOS Setup Guide](../../md/IOS_SETUP.md) - Hướng dẫn cài đặt chi tiết
- 🤖 [Android Setup Guide](../../md/DEV_ANDROID.md)
- 📖 [Main README](../../README.md)
- 🧪 [UAT Testing Guide](../../md/UAT_TESTING_GUIDE.md)

## Support

- **Integration Issues**: GitHub Issues
- **Framework Issues**: [email protected]
- **KBZPay Docs**: https://wap.kbzpay.com/pgw/uat/api/

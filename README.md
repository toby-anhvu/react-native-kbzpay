# react-native-kbzpay

React Native library for KBZPay integration in Myanmar 🇲🇲

[![npm version](https://badge.fury.io/js/react-native-kbzpay.svg)](https://badge.fury.io/js/react-native-kbzpay)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- ✅ Easy integration with KBZPay
- ✅ Built with Kotlin (Android) & Swift (iOS)
- ✅ TypeScript support
- ✅ iOS & Android support
- ✅ Promise-based API
- ✅ Full payment flow handling
- ✅ Auto signature generation
- ✅ TurboModule architecture

## Installation

```bash
npm install react-native-kbzpay
# or
yarn add react-native-kbzpay
```

## Prerequisites

### 1. Get KBZPay Credentials

Contact KBZ Bank ([email protected]) to get:

- App ID
- Merchant Code
- Sign Key (also called Merchant Key or App Key)
- KBZPay SDK files

### 2. Add SDK Files

#### Android

1. Download `kbzsdk_1.1.0.aar` from KBZ Bank (or use from `docs/sdk`)
2. Place it in: `node_modules/react-native-kbzpay/android/kbz-pay-sdk/`
3. Rebuild your Android app

**For your own project:**
You can copy the SDK from the library's docs:

```bash
cp node_modules/react-native-kbzpay/docs/sdk/kbzsdk_1.1.0.aar node_modules/react-native-kbzpay/android/kbz-pay-sdk/
```

#### iOS

1. Download `KBZPayAPPPay.framework` from KBZ Bank (or use from `docs/sdk`)
2. Place it in: `node_modules/react-native-kbzpay/ios/Frameworks/`
3. Run: `cd ios && pod install`

**For your own project:**
You can copy the framework from the library's docs:

```bash
# For production
cp -r node_modules/react-native-kbzpay/docs/sdk/1.3/framework/prod/KBZPayAPPPay.framework node_modules/react-native-kbzpay/ios/Frameworks/

# Or for simulator
cp -r node_modules/react-native-kbzpay/docs/sdk/1.3/framework/simulator/KBZPayAPPPay.framework node_modules/react-native-kbzpay/ios/Frameworks/
```

Then uncomment the `vendored_frameworks` line in `Kbzpay.podspec`.

## Configuration

### iOS Setup

#### 1. Update Info.plist

Add the following to your `ios/YourApp/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kbzpay</string>
</array>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>KBZPayCallback</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourappscheme</string>
        </array>
    </dict>
</array>
```

Replace `yourappscheme` with your app's bundle identifier or custom scheme.

#### 2. Handle Deep Link (Optional for now)

**For Objective-C (AppDelegate.m):**

```objc
#import <Kbzpay/Kbzpay.h>

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    // Handle KBZPay callback
    Kbzpay *kbzpayModule = [self.bridge moduleForClass:[Kbzpay class]];
    if (kbzpayModule) {
        [kbzpayModule handleOpenURL:url];
    }

    return YES;
}
```

### Android Setup

No additional configuration needed! The library handles everything automatically.

## Usage

### Basic Example

```typescript
import React, { useEffect, useState } from 'react';
import { View, Button, Alert } from 'react-native';
import KBZPay from 'react-native-kbzpay';

function PaymentScreen() {
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    initializeKBZPay();
  }, []);

  const initializeKBZPay = async () => {
    try {
      await KBZPay.initialize({
        appId: 'YOUR_APP_ID',
        merchCode: 'YOUR_MERCHANT_CODE',
        signKey: 'YOUR_SIGN_KEY',
        appScheme: 'yourappscheme', // iOS only
      });

      const isInstalled = await KBZPay.isKBZPayInstalled();
      setIsReady(isInstalled);

      if (!isInstalled) {
        Alert.alert('KBZPay Not Installed', 'Please install KBZPay app');
      }
    } catch (error) {
      console.error('Initialization error:', error);
    }
  };

  const handlePayment = async () => {
    try {
      // Get prepayId from your backend
      const prepayId = await fetchPrepayIdFromBackend();

      // Start payment
      const result = await KBZPay.startPayment({
        prepayId,
      });

      Alert.alert('Payment Success', `Order ID: ${result.orderId}`);
    } catch (error) {
      Alert.alert('Payment Failed', error.message);
    }
  };

  return (
    <View>
      <Button
        title="Pay with KBZPay"
        onPress={handlePayment}
        disabled={!isReady}
      />
    </View>
  );
}
```

### Complete Example with Backend

```typescript
import KBZPay from 'react-native-kbzpay';

// Initialize once when app starts
await KBZPay.initialize({
  appId: 'YOUR_APP_ID',
  merchCode: 'YOUR_MERCHANT_CODE',
  signKey: 'YOUR_SIGN_KEY',
  appScheme: 'yourappscheme',
});

// Check if KBZPay is installed
const isInstalled = await KBZPay.isKBZPayInstalled();

// Create order on your backend
const createOrder = async () => {
  const response = await fetch('YOUR_API/create-order', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      amount: 10000,
      currency: 'MMK',
      description: 'Product purchase',
    }),
  });

  const data = await response.json();
  return data.prepayId;
};

// Start payment
const payWithKBZPay = async () => {
  try {
    // Step 1: Get prepayId from backend
    const prepayId = await createOrder();

    // Step 2: Start KBZPay payment
    const result = await KBZPay.startPayment({ prepayId });

    // Step 3: Verify with backend
    await verifyPayment(result.orderId);

    console.log('Payment successful!', result);
  } catch (error) {
    console.error('Payment failed:', error);
  }
};
```

## API Reference

### `initialize(config)`

Initialize KBZPay SDK. Must be called before any other method.

**Parameters:**

- `config.appId` (string): Your KBZPay App ID
- `config.merchCode` (string): Your Merchant Code
- `config.signKey` (string): Your Sign Key
- `config.appScheme` (string, iOS only): Your app's URL scheme

**Returns:** `Promise<void>`

**Example:**

```typescript
await KBZPay.initialize({
  appId: 'YOUR_APP_ID',
  merchCode: 'YOUR_MERCHANT_CODE',
  signKey: 'YOUR_SIGN_KEY',
  appScheme: 'yourappscheme',
});
```

### `isKBZPayInstalled()`

Check if KBZPay app is installed on the device.

**Returns:** `Promise<boolean>`

**Example:**

```typescript
const isInstalled = await KBZPay.isKBZPayInstalled();
```

### `startPayment(orderInfo)`

Start the payment process.

**Parameters:**

- `orderInfo.prepayId` (string): Prepay ID from your backend

**Returns:** `Promise<PaymentResult>`

```typescript
interface PaymentResult {
  resultCode: number; // 0 = success, 3 = failed
  orderId: string;
}
```

**Example:**

```typescript
const result = await KBZPay.startPayment({
  prepayId: 'PREPAY_ID_FROM_BACKEND',
});
```

## Result Codes

| Code | Status  | Description                    |
| ---- | ------- | ------------------------------ |
| 0    | Success | Payment completed successfully |
| 3    | Failed  | Payment failed                 |

## Important Notes

⚠️ **Security**

- Never expose your Sign Key in the mobile app
- Always get prepayId from your backend server
- Always verify payment on your backend

⚠️ **Keys Clarification**

- Sign Key = Merchant Key = App Key (they are the same)
- Merchant Code ≠ Merchant Key (they are different)

⚠️ **SDK Versions**

- UAT: For testing environment
- Production: For live app

## Troubleshooting

### Android

**Error: Activity doesn't exist**

- Make sure you're calling methods when the app is in foreground

**Error: SDK not found**

- Verify `kbzsdk_1.1.0.aar` is in `node_modules/react-native-kbzpay/android/kbz-pay-sdk/`
- Clean and rebuild: `cd android && ./gradlew clean`

### iOS

**Error: Module not found**

- Run `cd ios && pod install`
- Clean build folder in Xcode

**Deep link not working**

- Verify Info.plist configuration
- Check appScheme matches CFBundleURLSchemes

## Example App

Check the `example/` directory for a complete working example.

```bash
# Install dependencies
yarn install

# Run on iOS
yarn example ios

# Run on Android
yarn example android
```

## SDK Files Location

The KBZPay SDK files are available in the `docs/sdk` directory:

- Android: `docs/sdk/kbzsdk_1.1.0.aar`
- iOS Production: `docs/sdk/1.3/framework/prod/KBZPayAPPPay.framework`
- iOS Simulator: `docs/sdk/1.3/framework/simulator/KBZPayAPPPay.framework`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT

## Support

- Documentation: [GitHub](https://github.com/toby-anhvu/react-native-kbzpay)
- Issues: [GitHub Issues](https://github.com/toby-anhvu/react-native-kbzpay/issues)
- Email: anhvu070790@gmail.com

## Acknowledgments

- [KBZ Bank](https://www.kbzbank.com/) for KBZPay SDK
- Myanmar Payment Gateway Integration

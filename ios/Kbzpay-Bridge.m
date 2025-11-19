#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_REMAP_MODULE(Kbzpay, Kbzpay, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)appId
                  merchCode:(NSString *)merchCode
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isKBZPayInstalled:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startPayment:(NSString *)appId
                  merchCode:(NSString *)merchCode
                  prepayId:(NSString *)prepayId
                  orderInfo:(NSString *)orderInfo
                  sign:(NSString *)sign
                  appScheme:(NSString *)appScheme
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end


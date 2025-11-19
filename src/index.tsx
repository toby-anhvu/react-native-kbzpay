import { Platform } from 'react-native';
import CryptoJS from 'crypto-js';
import Kbzpay from './NativeKbzpay';
import type {
  KBZPayConfig,
  PaymentResult,
  OrderInfo,
  KBZPayError,
} from './types';

class KBZPaySDK {
  private config: KBZPayConfig | null = null;
  private initialized: boolean = false;

  async initialize(config: KBZPayConfig): Promise<void> {
    if (this.initialized) {
      console.warn('KBZPay is already initialized');
      return;
    }

    this.config = config;

    try {
      await Kbzpay.initialize(config.appId, config.merchCode);
      this.initialized = true;
    } catch (error) {
      const kbzError: KBZPayError = {
        name: 'InitializationError',
        code: 'INIT_FAILED',
        message: 'Failed to initialize KBZPay SDK',
        details: error,
      };
      throw kbzError;
    }
  }

  isInitialized(): boolean {
    return this.initialized;
  }

  getConfig(): KBZPayConfig | null {
    return this.config;
  }

  async isKBZPayInstalled(): Promise<boolean> {
    try {
      return await Kbzpay.isKBZPayInstalled();
    } catch (error) {
      console.error('Error checking KBZPay installation:', error);
      return false;
    }
  }

  private buildOrderInfo(
    prepayId: string,
    nonceStr: string,
    timestamp: string | number
  ): string {
    if (!this.config) {
      throw new Error('KBZPay not initialized');
    }
    return `appid=${this.config.appId}&merch_code=${this.config.merchCode}&nonce_str=${nonceStr}&prepay_id=${prepayId}&timestamp=${timestamp}`;
  }

  /**
   * Gen signature for order info
   * @param orderInfo
   * @returns
   */
  private generateSignature(orderInfo: string): string {
    if (!this.config) {
      throw new Error('KBZPay not initialized');
    }
    const stringToSign = `${orderInfo}&key=${this.config.signKey}`;
    return CryptoJS.SHA256(stringToSign).toString().toUpperCase();
  }

  private generateOrderInfoWithSign(orderInfo: string, sign: string): string {
    return `${orderInfo}&sign=${sign}`;
  }

  async startPayment(orderInfo: OrderInfo): Promise<PaymentResult> {
    if (!this.initialized || !this.config) {
      throw new Error('KBZPay not initialized. Call initialize() first.');
    }

    try {
      const orderInfoStr = this.buildOrderInfo(
        orderInfo.prepayId,
        orderInfo.nonceStr,
        orderInfo.timestamp
      );
      const sign = this.generateSignature(orderInfoStr);

      const orderInfoStrWithSign = this.generateOrderInfoWithSign(
        orderInfoStr,
        sign
      );

      console.log('📦 Order Info:', orderInfoStrWithSign);
      console.log('🔐 Signature:', sign);

      const result = await Kbzpay.startPayment(
        this.config.appId,
        this.config.merchCode,
        orderInfo.prepayId,
        orderInfoStrWithSign,
        sign,
        Platform.OS === 'ios' ? this.config.appScheme : undefined
      );

      return result;
    } catch (error: any) {
      const kbzError: KBZPayError = {
        name: 'PaymentError',
        code: error.code || 'PAYMENT_FAILED',
        message: error.message || 'Payment failed',
        details: error,
      };
      throw kbzError;
    }
  }

  handleOpenURL(url: string): void {
    if (Platform.OS === 'ios') {
      console.log('Handling deep link:', url);
    }
  }
}

const kbzPaySDK = new KBZPaySDK();

export default kbzPaySDK;
export * from './types';
export { KBZPaySDK };

export interface KBZPayConfig {
  appId: string;
  merchCode: string;
  signKey: string;
  appScheme?: string; // Required for iOS
}

export interface PaymentResult {
  resultCode: number;
  orderId: string;
}

export interface OrderInfo {
  prepayId: string;
  nonceStr: string;
  timestamp: string | number;
}

export interface OrderInfoV2 {
  prepayId: string;
  nonceStr: string;
  timestamp: string | number;
}

export enum PaymentStatus {
  SUCCESS = 0,
  CANCELLED = 2,
  FAILED = 3,
}

export interface KBZPayError extends Error {
  code: string;
  message: string;
  details?: any;
}

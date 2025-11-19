import { TurboModuleRegistry, type TurboModule } from 'react-native';
import type { PaymentResult } from './types';

export interface Spec extends TurboModule {
  initialize(appId: string, merchCode: string): Promise<boolean>;
  isKBZPayInstalled(): Promise<boolean>;
  startPayment(
    appId: string,
    merchCode: string,
    prepayId: string,
    orderInfo: string,
    sign: string,
    appScheme?: string
  ): Promise<PaymentResult>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Kbzpay');

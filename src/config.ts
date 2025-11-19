/**
 * KBZPay Environment Configuration
 *
 * This file contains configuration for different KBZPay environments.
 * Switch between UAT and Production by changing the active environment.
 */

export type Environment = 'UAT' | 'PRODUCTION';

export interface KBZPayEnvironmentConfig {
  environment: Environment;
  appId: string;
  merchCode: string;
  signKey: string;
  appScheme?: string; // iOS only
}

/**
 * UAT Environment Configuration
 * Use this for testing before going live
 */
export const UAT_CONFIG: Partial<KBZPayEnvironmentConfig> = {
  environment: 'UAT',
  // Replace these with your UAT credentials from KBZ Bank
  appId: 'YOUR_UAT_APP_ID',
  merchCode: 'YOUR_UAT_MERCH_CODE',
  signKey: 'YOUR_UAT_SIGN_KEY',
  appScheme: 'yourapp', // iOS deep link scheme
};

/**
 * Production Environment Configuration
 * Use this for live app
 */
export const PRODUCTION_CONFIG: Partial<KBZPayEnvironmentConfig> = {
  environment: 'PRODUCTION',
  // Replace these with your Production credentials from KBZ Bank
  appId: 'YOUR_PROD_APP_ID',
  merchCode: 'YOUR_PROD_MERCH_CODE',
  signKey: 'YOUR_PROD_SIGN_KEY',
  appScheme: 'yourapp', // iOS deep link scheme
};

/**
 * Get current environment configuration
 * Change this to switch between UAT and Production
 */
export const getCurrentConfig = (): Partial<KBZPayEnvironmentConfig> => {
  // Change to PRODUCTION_CONFIG when ready for production
  return UAT_CONFIG;
};

/**
 * Helper to check if using UAT environment
 */
export const isUATEnvironment = (): boolean => {
  return getCurrentConfig().environment === 'UAT';
};

export default {
  UAT: UAT_CONFIG,
  PRODUCTION: PRODUCTION_CONFIG,
  current: getCurrentConfig,
  isUAT: isUATEnvironment,
};

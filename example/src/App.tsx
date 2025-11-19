import { useEffect, useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Button,
  Alert,
  ActivityIndicator,
  ScrollView,
  SafeAreaView,
  TextInput,
} from 'react-native';
import KBZPay from 'react-native-kbzpay';

const Mock_Order_Info = {
  appid: 'kpa00000000000000000000000000000000',
  merch_code: '000000',
  nonce_str: 'MOCKNONCESTRING12345678901234567890',
  prepay_id: 'KBZ00mockprepayid123456789012345678901234567890',
  timestamp: '1700000000000',
  sign: '0000000000000000000000000000000000000000000000000000000000000000',
  merch_order_id: '00000000-0000-0000-0000-000000000000',
};

const APP_KEY = 'mockkey@123';
export default function App() {
  const [loading, setLoading] = useState(false);
  const [isInstalled, setIsInstalled] = useState(false);
  const [initialized, setInitialized] = useState(false);

  useEffect(() => {
    initializeKBZPay();
  }, []);

  const initializeKBZPay = async () => {
    try {
      await KBZPay.initialize({
        appId: Mock_Order_Info.appid,
        merchCode: Mock_Order_Info.merch_code,
        signKey: APP_KEY,
        appScheme: 'kbzpayexample', // iOS only
      });

      setInitialized(true);

      const installed = await KBZPay.isKBZPayInstalled();
      setIsInstalled(installed);
    } catch (error) {
      console.error('Initialization error:', error);
      Alert.alert('Error', 'Failed to initialize KBZPay');
    }
  };

  const handlePayment = async () => {
    try {
      setLoading(true);

      const result = await KBZPay.startPayment({
        prepayId: Mock_Order_Info.prepay_id,
        nonceStr: Mock_Order_Info.nonce_str,
        timestamp: Mock_Order_Info.timestamp,
      });

      console.log('✅ Payment result:', result);
      Alert.alert(
        'Payment Success',
        `Order ID: ${result.orderId}\nResult Code: ${result.resultCode}`
      );
    } catch (error: any) {
      console.error('❌ Payment error:', error);
      Alert.alert('Payment Failed', error.message || 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const checkInstallation = async () => {
    try {
      const installed = await KBZPay.isKBZPayInstalled();
      console.log('✅ Check result:', installed);
      setIsInstalled(installed);
      Alert.alert(
        'Installation Check',
        `KBZPay is ${installed ? 'INSTALLED ✅' : 'NOT INSTALLED ❌'}`
      );
    } catch (error: any) {
      console.error('❌ Check error:', error);
      Alert.alert('Error', error.message);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.container}>
        <Text style={styles.title}>KBZPay Example</Text>

        <View style={styles.statusContainer}>
          <Text style={styles.statusLabel}>Status:</Text>
          <Text style={styles.statusText}>
            Initialized: {initialized ? '✅' : '❌'}
          </Text>
          <Text style={styles.statusText}>
            KBZPay Installed: {isInstalled ? '✅' : '❌'}
          </Text>
          <View style={styles.buttonContainer}>
            <Button
              title="🔄 Re-check Installation"
              onPress={checkInstallation}
              disabled={loading}
            />
          </View>
        </View>

        {!isInstalled && (
          <View style={styles.warningContainer}>
            <Text style={styles.warningText}>
              ⚠️ KBZPay app is not installed
            </Text>
            <Text style={styles.warningSubText}>
              Payment will not work without the KBZPay app
            </Text>
          </View>
        )}

        <View style={styles.divider} />

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Real Payment</Text>
          <Text style={styles.sectionSubtitle}>
            Enter prepay ID from your backend
          </Text>
          <TextInput
            style={styles.input}
            placeholder="Enter Prepay ID"
            value={Mock_Order_Info.prepay_id}
            onChangeText={() => {}}
            editable={!loading}
            autoCapitalize="none"
            autoCorrect={false}
          />
          <View style={styles.buttonContainer}>
            <Button
              title="Start Payment"
              onPress={handlePayment}
              disabled={!isInstalled}
            />
          </View>
        </View>

        {loading && (
          <ActivityIndicator
            size="large"
            color="#0000ff"
            style={styles.loader}
          />
        )}

        <View style={styles.infoContainer}>
          <Text style={styles.infoTitle}>Setup Instructions:</Text>
          <Text style={styles.infoText}>
            1. Update credentials in initializeKBZPay()
          </Text>
          <Text style={styles.infoText}>
            2. Install KBZPay app on your device
          </Text>
          <Text style={styles.infoText}>
            3. Get prepay_id from your backend
          </Text>
          <Text style={styles.infoText}>4. Test the payment flow</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  container: {
    flexGrow: 1,
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginVertical: 20,
    textAlign: 'center',
    color: '#333',
  },
  statusContainer: {
    backgroundColor: 'white',
    padding: 15,
    borderRadius: 8,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statusLabel: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
  statusText: {
    fontSize: 16,
    marginVertical: 5,
    color: '#666',
  },
  warningContainer: {
    backgroundColor: '#fff3cd',
    padding: 15,
    borderRadius: 8,
    marginBottom: 20,
    borderLeftWidth: 4,
    borderLeftColor: '#ffc107',
  },
  warningText: {
    color: '#856404',
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  warningSubText: {
    color: '#856404',
    fontSize: 12,
  },
  section: {
    marginVertical: 10,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 5,
    color: '#333',
  },
  sectionSubtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 15,
  },
  input: {
    backgroundColor: 'white',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 15,
    fontSize: 16,
  },
  buttonContainer: {
    marginVertical: 10,
  },
  divider: {
    height: 1,
    backgroundColor: '#ddd',
    marginVertical: 20,
  },
  loader: {
    marginTop: 20,
  },
  infoContainer: {
    backgroundColor: '#e3f2fd',
    padding: 15,
    borderRadius: 8,
    marginTop: 20,
    borderLeftWidth: 4,
    borderLeftColor: '#2196f3',
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#1976d2',
  },
  infoText: {
    fontSize: 14,
    color: '#1565c0',
    marginVertical: 3,
  },
});

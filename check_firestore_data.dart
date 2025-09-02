// Simple script to check what data exists in Firestore for demo_user_123
// Run this with: dart run check_firestore_data.dart

import 'dart:developer';
import 'dart:io';

void main() async {
  log('🔍 Manual Firestore Data Check', name: 'FirestoreDebug');
  log('================================', name: 'FirestoreDebug');
  log('', name: 'FirestoreDebug');
  log('Please check your Firestore console manually:', name: 'FirestoreDebug');
  log('', name: 'FirestoreDebug');
  log('1. Go to: https://console.firebase.google.com/', name: 'FirestoreDebug');
  log('2. Select your project', name: 'FirestoreDebug');
  log('3. Go to Firestore Database', name: 'FirestoreDebug');
  log('4. Navigate to: Collections > Products > demo_user_123', name: 'FirestoreDebug');
  log('5. Check if there\'s a "products" subcollection', name: 'FirestoreDebug');
  log('6. Check what data is in each product document', name: 'FirestoreDebug');
  log('', name: 'FirestoreDebug');
  log('Expected structure:', name: 'FirestoreDebug');
  log('Products (collection)', name: 'FirestoreDebug');
  log('  └── demo_user_123 (document)', name: 'FirestoreDebug');
  log('      └── products (subcollection)', name: 'FirestoreDebug');
  log('          └── [auto-generated-id] (document)', name: 'FirestoreDebug');
  log('              ├── Name: "Product name"', name: 'FirestoreDebug');
  log('              ├── Price: 123.45', name: 'FirestoreDebug');
  log('              ├── Quantity: 10', name: 'FirestoreDebug');
  log('              ├── Category: "Medicine"', name: 'FirestoreDebug');
  log('              └── ... other fields', name: 'FirestoreDebug');
  log('', name: 'FirestoreDebug');
  log('If the demo_user_123 document is empty:', name: 'FirestoreDebug');
  log('- The products might be in a different location', name: 'FirestoreDebug');
  log('- There might be an error in the saving process', name: 'FirestoreDebug');
  log('- Check the debug logs in the Flutter app', name: 'FirestoreDebug');
  log('', name: 'FirestoreDebug');
  log('Press Enter to continue...', name: 'FirestoreDebug');
  stdin.readLineSync();
}

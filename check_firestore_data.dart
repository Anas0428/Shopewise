// Simple script to check what data exists in Firestore for demo_user_123
// Run this with: dart run check_firestore_data.dart

import 'dart:io';

void main() async {
  print('🔍 Manual Firestore Data Check');
  print('================================');
  print('');
  print('Please check your Firestore console manually:');
  print('');
  print('1. Go to: https://console.firebase.google.com/');
  print('2. Select your project');
  print('3. Go to Firestore Database');
  print('4. Navigate to: Collections > Products > demo_user_123');
  print('5. Check if there\'s a "products" subcollection');
  print('6. Check what data is in each product document');
  print('');
  print('Expected structure:');
  print('Products (collection)');
  print('  └── demo_user_123 (document)');
  print('      └── products (subcollection)');
  print('          └── [auto-generated-id] (document)');
  print('              ├── Name: "Product name"');
  print('              ├── Price: 123.45');
  print('              ├── Quantity: 10');
  print('              ├── Category: "Medicine"');
  print('              └── ... other fields');
  print('');
  print('If the demo_user_123 document is empty:');
  print('- The products might be in a different location');
  print('- There might be an error in the saving process');
  print('- Check the debug logs in the Flutter app');
  print('');
  print('Press Enter to continue...');
  stdin.readLineSync();
}

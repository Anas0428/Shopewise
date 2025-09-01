import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_project/firebase_options.dart';
import 'package:my_project/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Service
  FirestoreService.initialize();

  debugPrint('🔄 Testing Firebase connection...');

  try {
    // Test connection
    final isConnected = await FirestoreService.checkConnection();
    debugPrint('Connection: ${isConnected ? "✅ Connected" : "❌ Failed"}');

    if (!isConnected) {
      debugPrint('❌ Firebase connection failed. Check your configuration.');
      return;
    }

    debugPrint('\n📖 Reading existing products...');
    final existingProducts = await FirestoreService.getAllProductsList();
    debugPrint('Found ${existingProducts.length} existing products');

    if (existingProducts.isEmpty) {
      debugPrint('\n📦 Adding test products...');

      // Add test products
      final testProducts = [
        {
          'Name': 'Paracetamol 500mg',
          'price': 25.50,
          'category': 'Pain Relief',
          'inStock': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'Name': 'Vitamin D3 Tablets',
          'price': 18.90,
          'category': 'Vitamins',
          'inStock': true,
          'createdAt': DateTime.now().toIso8601String(),
        }
      ];

      for (final product in testProducts) {
        final id = await FirestoreService.addProduct(product);
        debugPrint('✅ Added: ${product['Name']} (ID: $id)');
      }
    } else {
      debugPrint('Products found:');
      for (var product in existingProducts) {
        debugPrint('  - ${product['Name']} (₹${product['price']})');
      }
    }

    debugPrint('\n🔍 Testing search...');

    // Test search
    final searchResults = await FirestoreService.searchProducts('paracetamol');
    debugPrint('Search for "paracetamol": ${searchResults.length} results');

    for (var product in searchResults) {
      debugPrint('  - ${product['Name']} (₹${product['price']})');
    }

    debugPrint('\n✅ All tests completed successfully!');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}

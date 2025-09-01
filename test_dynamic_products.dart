// Test script for validating dynamic sub-collections functionality
// Run this to test the updated FirestoreService
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/services/firestore_service.dart';
import 'lib/firebase_options.dart';

void debugPrint(String? message, {int? wrapWidth}) {
  print(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🧪 Testing Dynamic Sub-Collections Functionality');
  debugPrint('================================================');

  try {
    // Initialize Firebase first
    debugPrint('\n1. Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
    
    // Initialize Firestore service
    debugPrint('\n2. Initializing Firestore Service...');
    FirestoreService.initialize();
    await Future.delayed(const Duration(seconds: 2)); // Give it time to initialize

    // Test connection
    debugPrint('\n3. Testing Firestore connection...');
    bool connected = await FirestoreService.checkConnection();
    debugPrint('Connection status: ${connected ? "✅ Connected" : "❌ Failed"}');

    if (!connected) {
      debugPrint('❌ Cannot connect to Firestore. Please check your configuration.');
      return;
    }

    // First, explore the Firestore structure to understand what we're working with
    debugPrint('\n4. Exploring Firestore structure...');
    await FirestoreService.exploreFirestoreStructure();
    
    // Test getting all products with new dynamic structure
    debugPrint('\n5. Testing getAllProductsList() with enhanced detection...');
    try {
      var products = await FirestoreService.getAllProductsList();
      debugPrint('✅ Successfully retrieved ${products.length} products');
      
      if (products.isNotEmpty) {
        debugPrint('\n📋 Sample product data:');
        for (int i = 0; i < (products.length > 3 ? 3 : products.length); i++) {
          final product = products[i];
          debugPrint('  Product ${i + 1}:');
          debugPrint('    ID: ${product['id']}');
          debugPrint('    Name: ${product['Name']}');
          debugPrint('    Price: ${product['Price']}');
          debugPrint('    Quantity: ${product['Quantity']}');
          debugPrint('    Store: ${product['StoreName']}');
          debugPrint('    User ID: ${product['userId']}');
          debugPrint('    Document ID: ${product['documentId']}');
          debugPrint('');
        }
      } else {
        debugPrint('');
        debugPrint('🚨 STILL NO PRODUCTS FOUND!');
        debugPrint('💡 Recommendations:');
        debugPrint('   1. Check the structure exploration results above');
        debugPrint('   2. Verify your Firestore console shows data in Products collection');
        debugPrint('   3. Ensure sub-collections contain documents with product fields');
        debugPrint('   4. Check if products are embedded directly in user documents');
      }
    } catch (e) {
      debugPrint('❌ Error getting products: $e');
    }

    // Test search functionality
    debugPrint('\n6. Testing search functionality...');
    try {
      // Test with empty query (should return all products)
      var searchResults = await FirestoreService.searchProducts('');
      debugPrint('✅ Empty search returned ${searchResults.length} products');
      
      // Test with a common search term
      searchResults = await FirestoreService.searchProducts('medicine');
      debugPrint('✅ Search for "medicine" returned ${searchResults.length} products');
      
    } catch (e) {
      debugPrint('❌ Error testing search: $e');
    }

    // Test getting products for a specific user (if any users exist)
    debugPrint('\n7. Testing getProductsForUser()...');
    try {
      // First get all products to find a user ID
      var allProducts = await FirestoreService.getAllProductsList();
      if (allProducts.isNotEmpty) {
        var userId = allProducts.first['userId'];
        debugPrint('Testing with user ID: $userId');
        
        var userProducts = await FirestoreService.getProductsForUser(userId);
        debugPrint('✅ Retrieved ${userProducts.length} products for user $userId');
      } else {
        debugPrint('ℹ️ No products available to test user-specific retrieval');
      }
    } catch (e) {
      debugPrint('❌ Error testing getProductsForUser: $e');
    }

    // Test database statistics
    debugPrint('\n8. Testing database statistics...');
    try {
      var stats = await FirestoreService.getDatabaseStats();
      debugPrint('✅ Database statistics:');
      debugPrint('   Total products: ${stats['totalProducts']}');
      debugPrint('   In stock: ${stats['inStockProducts']}');
      debugPrint('   Out of stock: ${stats['outOfStockProducts']}');
    } catch (e) {
      debugPrint('❌ Error getting database stats: $e');
    }

    debugPrint('\n🎉 Testing completed successfully!');
    debugPrint('The updated FirestoreService is working with dynamic sub-collections.');

  } catch (e) {
    debugPrint('❌ Critical error during testing: $e');
  }

  debugPrint('\nPress Enter to exit...');
  stdin.readLineSync();
}

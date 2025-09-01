import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProductDiscoveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _productsRef = _firestore.collection('Products');

  /// Discover all products using the same approach as the working function
  static Future<List<Map<String, dynamic>>> discoverAllProducts() async {
    try {
      if (kDebugMode) {
        print('🔍 Starting product discovery...');
      }

      final products = <Map<String, dynamic>>[];
      
      // Get all user documents from Products collection
      final userSnapshot = await _productsRef.get();
      
      if (userSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('❌ No user documents found in Products collection');
        }
        return [];
      }

      if (kDebugMode) {
        print('📁 Found ${userSnapshot.docs.length} user documents');
      }
      
      for (var userDoc in userSnapshot.docs) {
        try {
          // Get the products subcollection for this user
          final productsSubcollection = userDoc.reference.collection('products');
          final productsSnapshot = await productsSubcollection.get();
          
          if (kDebugMode) {
            print('👤 User ${userDoc.id}: Found ${productsSnapshot.docs.length} products');
          }
          
          // Add each product to the main list
          for (var productDoc in productsSnapshot.docs) {
            final data = productDoc.data();
            products.add({
              "Name": data['Name'] ?? data['name'] ?? 'Unknown Product',
              "Price": data['Price'] ?? data['price'] ?? 0,
              "Quantity": data['Quantity'] ?? data['quantity'] ?? 0,
              "StoreId": data['StoreId'] ?? data['storeId'] ?? userDoc.id,
              "ProductId": data['ProductId'] ?? data['productId'] ?? productDoc.id,
              "Type": data['Type'] ?? data['type'] ?? 'Medicine',
              "Category": data['Category'] ?? data['category'] ?? 'General',
              "StoreName": data['StoreName'] ?? data['storeName'] ?? 'Unknown Store',
              "StoreLocation": data['StoreLocation'] ?? data['storeLocation'],
              "storeEmail": data['storeEmail'] ?? data['email'] ?? '',
              "Expire": data['Expire'] ?? data['expire'],
              "id": productDoc.id,
              "userId": userDoc.id,
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting products for user ${userDoc.id}: $e');
          }
          continue;
        }
      }

      if (kDebugMode) {
        print('✅ Retrieved total of ${products.length} products');
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all products: $e');
      }
      return [];
    }
  }

  /// Search products by query
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final allProducts = await discoverAllProducts();

      if (query.isEmpty) return allProducts;

      final searchQuery = query.toLowerCase().trim();

      return allProducts.where((product) {
        final name = (product['Name'] ?? '').toString().toLowerCase();
        final category = (product['Category'] ?? '').toString().toLowerCase();
        final type = (product['Type'] ?? '').toString().toLowerCase();
        final storeName = (product['StoreName'] ?? '').toString().toLowerCase();
        
        return name.contains(searchQuery) ||
            category.contains(searchQuery) ||
            type.contains(searchQuery) ||
            storeName.contains(searchQuery);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching products: $e');
      }
      return [];
    }
  }

  /// Get products for a specific user
  static Future<List<Map<String, dynamic>>> getUserProducts(String userId) async {
    try {
      final products = <Map<String, dynamic>>[];
      
      // Get the user document
      final userDoc = await _productsRef.doc(userId).get();
      if (!userDoc.exists) return [];
      
      // Get the products subcollection for this user
      final productsSubcollection = userDoc.reference.collection('products');
      final productsSnapshot = await productsSubcollection.get();
      
      // Add each product to the list
      for (var productDoc in productsSnapshot.docs) {
        final data = productDoc.data();
        products.add({
          "Name": data['Name'] ?? data['name'] ?? 'Unknown Product',
          "Price": data['Price'] ?? data['price'] ?? 0,
          "Quantity": data['Quantity'] ?? data['quantity'] ?? 0,
          "StoreId": data['StoreId'] ?? data['storeId'] ?? userDoc.id,
          "ProductId": data['ProductId'] ?? data['productId'] ?? productDoc.id,
          "Type": data['Type'] ?? data['type'] ?? 'Medicine',
          "Category": data['Category'] ?? data['category'] ?? 'General',
          "StoreName": data['StoreName'] ?? data['storeName'] ?? 'Unknown Store',
          "StoreLocation": data['StoreLocation'] ?? data['storeLocation'],
          "storeEmail": data['storeEmail'] ?? data['email'] ?? '',
          "Expire": data['Expire'] ?? data['expire'],
          "id": productDoc.id,
          "userId": userDoc.id,
        });
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products for user $userId: $e');
      }
      return [];
    }
  }
}

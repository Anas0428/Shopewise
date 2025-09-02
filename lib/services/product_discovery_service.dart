import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProductDiscoveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _productsRef = _firestore.collection('products');

  /// Discover all products from centralized products collection
  /// No user-specific filtering - all products are globally accessible
  static Future<List<Map<String, dynamic>>> discoverAllProducts() async {
    try {
      if (kDebugMode) {
        print('🔍 Starting centralized product discovery...');
      }

      final products = <Map<String, dynamic>>[];
      
      // Get all products directly from centralized collection
      final productsSnapshot = await _productsRef.get();
      
      if (productsSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('❌ No products found in centralized products collection');
        }
        return [];
      }

      if (kDebugMode) {
        print('📁 Found ${productsSnapshot.docs.length} products');
      }
      
      for (var productDoc in productsSnapshot.docs) {
        try {
          final data = productDoc.data() as Map<String, dynamic>?;
          
          // Map product data with robust null-checks and flexible schema support
          final mappedProduct = {
            "Name": _safeParseString(
              data?['Name'] ?? data?['name'] ?? data?['productName'] ?? data?['title'],
              'Unknown Product'
            ),
            "Price": _safeParseDouble(
              data?['Price'] ?? data?['price'] ?? data?['cost'] ?? data?['amount'],
              0.0
            ),
            "Quantity": _safeParseInt(
              data?['Quantity'] ?? data?['quantity'] ?? data?['stock'] ?? data?['inventory'],
              0
            ),
            "StoreId": _safeParseString(
              data?['StoreId'] ?? data?['storeId'] ?? data?['vendorId'] ?? data?['supplierId'],
              'unknown_store'
            ),
            "ProductId": _safeParseString(
              data?['ProductId'] ?? data?['productId'] ?? data?['sku'] ?? productDoc.id,
              productDoc.id
            ),
            "Type": _safeParseString(
              data?['Type'] ?? data?['type'] ?? data?['productType'],
              'General'
            ),
            "Category": _safeParseString(
              data?['Category'] ?? data?['category'],
              'General'
            ),
            "StoreName": _safeParseString(
              data?['StoreName'] ?? data?['storeName'] ?? data?['store'] ?? data?['vendor'],
              'Unknown Store'
            ),
            "StoreLocation": data?['StoreLocation'] ?? data?['storeLocation'] ?? data?['location'],
            "storeEmail": _safeParseString(
              data?['storeEmail'] ?? data?['store_email'] ?? data?['email'],
              ''
            ),
            "Expire": data?['Expire'] ?? data?['expire'] ?? data?['expiryDate'],
            "description": _safeParseString(
              data?['description'] ?? data?['Description'] ?? data?['details'],
              ''
            ),
            "manufacturer": _safeParseString(
              data?['manufacturer'] ?? data?['Manufacturer'] ?? data?['brand'],
              ''
            ),
            "id": productDoc.id,
            "documentId": productDoc.id,
            "createdAt": data?['createdAt'],
            "updatedAt": data?['updatedAt'],
            "isActive": data?['isActive'] ?? data?['active'] ?? data?['enabled'] ?? true,
          };
          
          // Only add valid products
          if (_isValidProduct(mappedProduct)) {
            products.add(mappedProduct);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error processing product ${productDoc.id}: $e');
          }
          continue;
        }
      }

      if (kDebugMode) {
        print('✅ Retrieved total of ${products.length} valid products');
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all products: $e');
      }
      return [];
    }
  }

  /// Search products by query without user-specific filtering
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final allProducts = await discoverAllProducts();

      if (query.isEmpty) return allProducts;

      final searchQuery = query.toLowerCase().trim();

      final filteredProducts = allProducts.where((product) {
        final name = (product['Name'] ?? '').toString().toLowerCase();
        final category = (product['Category'] ?? '').toString().toLowerCase();
        final type = (product['Type'] ?? '').toString().toLowerCase();
        final storeName = (product['StoreName'] ?? '').toString().toLowerCase();
        final description = (product['description'] ?? '').toString().toLowerCase();
        final manufacturer = (product['manufacturer'] ?? '').toString().toLowerCase();
        
        return name.contains(searchQuery) ||
            category.contains(searchQuery) ||
            type.contains(searchQuery) ||
            storeName.contains(searchQuery) ||
            description.contains(searchQuery) ||
            manufacturer.contains(searchQuery);
      }).toList();
      
      if (kDebugMode) {
        print('🔍 Search for "$query" returned ${filteredProducts.length} results');
      }
      
      return filteredProducts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching products: $e');
      }
      return [];
    }
  }

  /// Get products filtered by store (replaces user-specific filtering)
  /// Since products are now centralized, we filter by store instead of user
  static Future<List<Map<String, dynamic>>> getStoreProducts(String storeId) async {
    try {
      final allProducts = await discoverAllProducts();
      
      final storeProducts = allProducts.where((product) {
        final productStoreId = product['StoreId']?.toString() ?? '';
        return productStoreId == storeId;
      }).toList();
      
      if (kDebugMode) {
        print('🏢 Found ${storeProducts.length} products for store $storeId');
      }
      
      return storeProducts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products for store $storeId: $e');
      }
      return [];
    }
  }
  
  /// Get products by category
  static Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      final allProducts = await discoverAllProducts();
      
      final categoryProducts = allProducts.where((product) {
        final productCategory = product['Category']?.toString().toLowerCase() ?? '';
        return productCategory == category.toLowerCase();
      }).toList();
      
      if (kDebugMode) {
        print('🏷️ Found ${categoryProducts.length} products in category $category');
      }
      
      return categoryProducts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products for category $category: $e');
      }
      return [];
    }
  }
  
  /// Helper methods for safe data parsing
  static String _safeParseString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    return value.toString().trim();
  }
  
  static double _safeParseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
        return double.parse(cleanValue);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
  
  static int _safeParseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
        return int.parse(cleanValue);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
  
  /// Validate if a product has essential data
  static bool _isValidProduct(Map<String, dynamic> product) {
    final name = product['Name']?.toString().trim() ?? '';
    final price = product['Price'] ?? 0;
    final quantity = product['Quantity'] ?? 0;
    
    return name.isNotEmpty && 
           name != 'Unknown Product' && 
           (price > 0 || quantity > 0);
  }
}

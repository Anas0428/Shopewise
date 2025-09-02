import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

/// Utility class to help migrate to centralized products collection
/// and create sample data for testing
class MigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Create sample products in the centralized collection for testing
  static Future<void> createSampleProducts() async {
    if (kDebugMode) {
      print('🔄 Creating sample products in centralized collection...');
    }
    
    final sampleProducts = [
      {
        'Name': 'Paracetamol 500mg',
        'Price': 25.0,
        'Quantity': 100,
        'Category': 'Medicine',
        'Type': 'Over-the-counter',
        'StoreName': 'City Medical Store',
        'StoreId': 'store_001',
        'storeEmail': 'city@example.com',
        'description': 'Pain relief and fever reducer',
        'manufacturer': 'Generic Pharma',
        'isActive': true,
      },
      {
        'Name': 'Vitamin D3 Tablets',
        'Price': 150.0,
        'Quantity': 50,
        'Category': 'Vitamins',
        'Type': 'Supplements',
        'StoreName': 'Health Plus Pharmacy',
        'StoreId': 'store_002',
        'storeEmail': 'healthplus@example.com',
        'description': 'Vitamin D3 supplement for bone health',
        'manufacturer': 'Wellness Co',
        'isActive': true,
      },
      {
        'Name': 'Cough Syrup',
        'Price': 85.0,
        'Quantity': 30,
        'Category': 'Syrup',
        'Type': 'Over-the-counter',
        'StoreName': 'Care Pharmacy',
        'StoreId': 'store_003',
        'storeEmail': 'care@example.com',
        'description': 'Relief from dry and wet cough',
        'manufacturer': 'Pharma Solutions',
        'isActive': true,
      },
      {
        'Name': 'First Aid Kit',
        'Price': 200.0,
        'Quantity': 15,
        'Category': 'First Aid',
        'Type': 'Medical Supplies',
        'StoreName': 'Emergency Supplies',
        'StoreId': 'store_004',
        'storeEmail': 'emergency@example.com',
        'description': 'Complete first aid kit for home and office',
        'manufacturer': 'MedCare',
        'isActive': true,
      },
      {
        'Name': 'Antiseptic Cream',
        'Price': 45.0,
        'Quantity': 75,
        'Category': 'Ointment',
        'Type': 'Over-the-counter',
        'StoreName': 'City Medical Store',
        'StoreId': 'store_001',
        'storeEmail': 'city@example.com',
        'description': 'Prevents infection in minor cuts and wounds',
        'manufacturer': 'Skin Care Ltd',
        'isActive': true,
      },
    ];
    
    int successCount = 0;
    
    for (int i = 0; i < sampleProducts.length; i++) {
      try {
        final productId = await FirestoreService.addProduct(sampleProducts[i]);
        successCount++;
        
        if (kDebugMode) {
          print('✅ Created sample product ${i + 1}: ${sampleProducts[i]['Name']} (ID: $productId)');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error creating sample product ${i + 1}: $e');
        }
      }
    }
    
    if (kDebugMode) {
      print('📊 Migration completed: $successCount/${sampleProducts.length} products created');
    }
  }
  
  /// Migrate products from old nested structure to centralized collection
  /// This is a helper method for migrating existing data
  static Future<void> migrateFromNestedStructure() async {
    if (kDebugMode) {
      print('🔄 Starting migration from nested structure to centralized collection...');
    }
    
    try {
      // Get all user documents from old Products collection
      final oldProductsRef = _firestore.collection('Products');
      final userSnapshot = await oldProductsRef.get();
      
      if (userSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No data found in old Products collection structure');
        }
        return;
      }
      
      int totalMigrated = 0;
      int totalErrors = 0;
      
      for (final userDoc in userSnapshot.docs) {
        final userId = userDoc.id;
        
        try {
          // Try to get products subcollection
          final productsSubcollection = userDoc.reference.collection('products');
          final productsSnapshot = await productsSubcollection.get();
          
          if (kDebugMode) {
            print('👤 Processing user $userId: Found ${productsSnapshot.docs.length} products');
          }
          
          for (final productDoc in productsSnapshot.docs) {
            try {
              final productData = productDoc.data();
              
              // Transform and clean the data for centralized collection
              final centralizedData = _transformProductData(productData, userId);
              
              // Add to centralized collection
              await FirestoreService.addProduct(centralizedData);
              totalMigrated++;
              
              if (kDebugMode && totalMigrated <= 10) {
                print('  ✅ Migrated: ${centralizedData['Name']}');
              }
              
            } catch (e) {
              totalErrors++;
              if (kDebugMode) {
                print('  ❌ Error migrating product ${productDoc.id}: $e');
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error processing user $userId: $e');
          }
        }
      }
      
      if (kDebugMode) {
        print('📊 Migration completed:');
        print('   ✅ Successfully migrated: $totalMigrated products');
        print('   ❌ Errors: $totalErrors products');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Critical error during migration: $e');
      }
    }
  }
  
  /// Transform product data from old structure to new centralized format
  static Map<String, dynamic> _transformProductData(Map<String, dynamic> oldData, String userId) {
    return {
      // Core product fields with fallbacks
      'Name': oldData['Name'] ?? oldData['name'] ?? 'Unknown Product',
      'Price': _safeParseDouble(oldData['Price'] ?? oldData['price'], 0.0),
      'Quantity': _safeParseInt(oldData['Quantity'] ?? oldData['quantity'], 0),
      'Category': oldData['Category'] ?? oldData['category'] ?? 'General',
      'Type': oldData['Type'] ?? oldData['type'] ?? 'Medicine',
      
      // Store information (use user data as store data in old structure)
      'StoreName': oldData['StoreName'] ?? oldData['storeName'] ?? 'Store $userId',
      'StoreId': oldData['StoreId'] ?? oldData['storeId'] ?? userId,
      'storeEmail': oldData['storeEmail'] ?? oldData['email'] ?? '',
      'StoreLocation': oldData['StoreLocation'] ?? oldData['storeLocation'],
      
      // Optional fields
      'description': oldData['description'] ?? oldData['Description'] ?? '',
      'manufacturer': oldData['manufacturer'] ?? oldData['Manufacturer'] ?? '',
      'Expire': oldData['Expire'] ?? oldData['expire'],
      
      // Migration metadata
      'isActive': true,
      'migratedFrom': userId,
      'migrationDate': FieldValue.serverTimestamp(),
    };
  }
  
  /// Clean up old nested structure after successful migration
  /// WARNING: This will delete the old data structure!
  static Future<void> cleanupOldStructure() async {
    if (kDebugMode) {
      print('⚠️ WARNING: This will delete the old nested Products collection!');
      print('💡 Make sure you have backed up your data and verified the migration was successful.');
    }
    
    // This is intentionally not implemented for safety
    // Users should manually delete old data after verifying the migration
    throw UnimplementedError(
      'Cleanup must be done manually for safety. '
      'Please verify your migration was successful before deleting old data.'
    );
  }
  
  /// Helper method to safely parse double values
  static double _safeParseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
  
  /// Helper method to safely parse int values
  static int _safeParseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
  
  /// Verify the centralized collection has data
  static Future<Map<String, dynamic>> verifyMigration() async {
    try {
      final products = await FirestoreService.getAllProductsList();
      
      final stats = {
        'totalProducts': products.length,
        'activeProducts': products.where((p) => p['isActive'] == true).length,
        'migratedProducts': products.where((p) => p['migratedFrom'] != null).length,
        'sampleProducts': products.where((p) => p['migratedFrom'] == null).length,
      };
      
      if (kDebugMode) {
        print('📊 Migration Verification Results:');
        print('   Total products in centralized collection: ${stats['totalProducts']}');
        print('   Active products: ${stats['activeProducts']}');
        print('   Migrated products: ${stats['migratedProducts']}');
        print('   Sample products: ${stats['sampleProducts']}');
      }
      
      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying migration: $e');
      }
      return {'error': e.toString()};
    }
  }
}

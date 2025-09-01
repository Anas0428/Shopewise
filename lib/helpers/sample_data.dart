import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class SampleDataHelper {
  // Add sample products to Firebase for testing (nested structure)
  static Future<void> addSampleProducts() async {
    // Sample users to add products to
    final sampleUsers = ['user1', 'user2', 'pharmacist1'];
    
    final sampleProducts = [
      {
        'Name': 'Paracetamol 500mg',
        'Price': 25.50,
        'Category': 'Pain Relief',
        'description': 'Effective pain relief and fever reducer',
        'Quantity': 100,
        'Expire': '2025-12-31',
        'ProductId': 'PAR500',
        'StoreId': 'CITY001',
        'StoreName': 'City Pharmacy',
      },
      {
        'Name': 'Amoxicillin 250mg',
        'Price': 45.75,
        'Category': 'Antibiotics',
        'description': 'Broad-spectrum antibiotic for infections',
        'Quantity': 50,
        'Expire': '2025-08-15',
        'ProductId': 'AMX250',
        'StoreId': 'HEALTH001',
        'StoreName': 'Health Plus Pharmacy',
      },
      {
        'Name': 'Insulin Pen',
        'Price': 120.00,
        'Category': 'Diabetes Care',
        'description': 'Easy-to-use insulin delivery pen',
        'Quantity': 0,
        'Expire': '2024-12-01',
        'ProductId': 'INS001',
        'StoreId': 'MEDI001',
        'StoreName': 'MediCare Center',
      },
      {
        'Name': 'Cough Syrup',
        'Price': 35.25,
        'Category': 'Cold & Flu',
        'description': 'Relieves cough and soothes throat',
        'Quantity': 75,
        'Expire': '2025-06-30',
        'ProductId': 'COUGH001',
        'StoreId': 'QUICK001',
        'StoreName': 'Quick Relief Pharmacy',
      },
      {
        'Name': 'Vitamin D3 Tablets',
        'Price': 18.90,
        'Category': 'Vitamins',
        'description': 'Essential vitamin D supplement',
        'Quantity': 200,
        'Expire': '2026-03-15',
        'ProductId': 'VITD3',
        'StoreId': 'WELL001',
        'StoreName': 'Wellness Pharmacy',
      },
      {
        'Name': 'Blood Pressure Monitor',
        'Price': 85.00,
        'Category': 'Medical Devices',
        'description': 'Digital blood pressure monitoring device',
        'Quantity': 25,
        'Expire': '2027-12-31',
        'ProductId': 'BPM001',
        'StoreId': 'TECH001',
        'StoreName': 'Tech Med Store',
      },
      {
        'Name': 'Aspirin 100mg',
        'Price': 12.50,
        'Category': 'Pain Relief',
        'description': 'Low-dose aspirin for cardiovascular health',
        'Quantity': 300,
        'Expire': '2025-09-20',
        'ProductId': 'ASP100',
        'StoreId': 'HEART001',
        'StoreName': 'Heart Care Pharmacy',
      },
      {
        'Name': 'Antacid Tablets',
        'Price': 22.75,
        'Category': 'Digestive Health',
        'description': 'Fast relief from heartburn and indigestion',
        'Quantity': 150,
        'Expire': '2025-11-10',
        'ProductId': 'ANT001',
        'StoreId': 'DIGEST001',
        'StoreName': 'Digestive Health Pharmacy',
      },
    ];

    debugPrint('🔄 Adding sample products to Firebase (nested structure)...');
    debugPrint('👥 Adding to users: $sampleUsers');

    try {
      int totalProductsAdded = 0;
      
      // Distribute products across different users
      for (int i = 0; i < sampleProducts.length; i++) {
        // Assign each product to a random user
        final userId = sampleUsers[i % sampleUsers.length];
        
        // Add StoreLocation as GeoPoint for this user
        final productData = {
          ...sampleProducts[i],
          'StoreLocation': {
            'latitude': 33.6844 + (i * 0.001), // Slight variation for each product
            'longitude': 73.0479 + (i * 0.001),
          },
        };
        
        final productId = await FirestoreService.addProductToUser(userId, productData);
        totalProductsAdded++;
        
        debugPrint(
            'ā Added product $totalProductsAdded: ${sampleProducts[i]['Name']} to user $userId (ID: $productId)');

        // Add a small delay to avoid overwhelming Firebase
        await Future.delayed(const Duration(milliseconds: 500));
      }

      debugPrint('✅ All $totalProductsAdded sample products added successfully!');
      debugPrint('📁 Products distributed across ${sampleUsers.length} users');
    } catch (e) {
      debugPrint('❌ Error adding sample products: $e');
    }
  }

  // Test search functionality
  static Future<void> testSearchFunctionality() async {
    debugPrint('\n🔍 Testing search functionality...');

    try {
      // Test 1: Search for "paracetamol"
      debugPrint('\nTest 1: Searching for "paracetamol"');
      final results1 = await FirestoreService.searchProducts('paracetamol');
      debugPrint('Found ${results1.length} results');
      for (var product in results1) {
        debugPrint('- ${product['Name']} (₹${product['price']})');
      }

      // Test 2: Search for "vitamin"
      debugPrint('\nTest 2: Searching for "vitamin"');
      final results2 = await FirestoreService.searchProducts('vitamin');
      debugPrint('Found ${results2.length} results');
      for (var product in results2) {
        debugPrint('- ${product['Name']} (₹${product['price']})');
      }

      // Test 3: Advanced search by category
      debugPrint('\nTest 3: Searching by category "Pain Relief"');
      final results3 =
          await FirestoreService.searchProductsByCategory('Pain Relief');
      debugPrint('Found ${results3.length} results');
      for (var product in results3) {
        debugPrint('- ${product['Name']} (₹${product['price']})');
      }

      // Test 4: Get all products
      debugPrint('\nTest 4: Getting all products');
      final allProducts = await FirestoreService.getAllProductsList();
      debugPrint('Total products in database: ${allProducts.length}');

      debugPrint('\n✅ All search tests completed successfully!');
    } catch (e) {
      debugPrint('❌ Error during search tests: $e');
    }
  }

  // Clean up test data (optional)
  static Future<void> clearAllProducts() async {
    try {
      debugPrint('⚠️ This will delete all products from Firebase!');
      await FirestoreService.deleteAllProducts();
      debugPrint('✅ All products cleared from Firebase');
    } catch (e) {
      debugPrint('❌ Error clearing products: $e');
    }
  }
}

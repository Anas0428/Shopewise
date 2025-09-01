// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static FirebaseFirestore? _firestore;
  static CollectionReference? _productsRef;
  static CollectionReference? _usersRef;
  static CollectionReference? _appDataRef;

  /// Initialize Firestore service
  static void initialize() {
    try {
      _firestore = FirebaseFirestore.instance;
      _productsRef = _firestore!.collection('Products');
      _usersRef = _firestore!.collection('users');
      _appDataRef = _firestore!.collection('appData');

      if (kDebugMode) {
        print('✅ Firestore Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Firestore Service: $e');
      }
    }
  }

  /// Get Firestore instance
  static FirebaseFirestore get instance {
    return _firestore ?? FirebaseFirestore.instance;
  }

  /// Get appData collection reference
  static CollectionReference get appDataCollection {
    return _appDataRef ?? FirebaseFirestore.instance.collection('appData');
  }

  /// Get Products collection reference
  static CollectionReference get productsCollection {
    return _productsRef ?? FirebaseFirestore.instance.collection('Products');
  }

  /// Get users collection reference
  static CollectionReference get usersCollection {
    return _usersRef ?? FirebaseFirestore.instance.collection('users');
  }

  // ===== PRODUCT MANAGEMENT =====

  /// Add a new product to Firestore
  static Future<String> addProduct(Map<String, dynamic> product) async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      // Add timestamp to product data
      final productData = {
        ...product,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _productsRef!.add(productData);
      final productId = docRef.id;

      // Update the document with its own ID
      await docRef.update({'id': productId});

      if (kDebugMode) {
        print('✅ Product added successfully with ID: $productId');
      }

      return productId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding product: $e');
      }
      rethrow;
    }
  }

  /// Get all products from Firestore with comprehensive sub-collection detection
  /// Structure: Products (collection) -> User Documents -> Product Sub-collections -> Product Documents
  /// Automatically discovers all sub-collections under each user document
  static Future<List<Map<String, dynamic>>> getAllProductsList() async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final productsList = <Map<String, dynamic>>[];
      
      if (kDebugMode) {
        print('🔍 Starting comprehensive product discovery...');
        print('=' * 60);
      }
      
      // Start with Products collection and get all user documents
      final userSnapshot = await _productsRef!.get();

      if (userSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('❌ No user documents found in Products collection');
          print('🗂️ Database Structure Check:');
          print('   - Products collection exists but is empty');
          print('   - Expected structure: Products/{userId}/{subCollections}/{productDocs}');
        }
        return [];
      }

      if (kDebugMode) {
        print('📁 Found ${userSnapshot.docs.length} user documents in Products collection');
        print('🔍 Now checking each user document for sub-collections...');
        print('');
      }
      
      int totalUsersProcessed = 0;
      int usersWithProducts = 0;
      
      // Loop through each user document in the Products collection
      for (final userDoc in userSnapshot.docs) {
        totalUsersProcessed++;
        int userProductCount = 0;
        bool foundProductsForUser = false;
        
        if (kDebugMode) {
          print('👤 Processing User $totalUsersProcessed/${userSnapshot.docs.length}: ${userDoc.id}');
        }

        try {
          final userData = userDoc.data() as Map<String, dynamic>;
          
          // Strategy 1: Check for embedded products in user document
          if (userData.containsKey('products') && userData['products'] is Map) {
            final productsMap = Map<String, dynamic>.from(userData['products'] as Map);
            if (kDebugMode) {
              print('  📦 Found embedded products map with ${productsMap.length} items');
            }
            
            productsMap.forEach((productId, productData) {
              if (productData is Map) {
                final mappedProduct = _mapProductData(
                  Map<String, dynamic>.from(productData), 
                  productId, 
                  userDoc.id, 
                  productId,
                  userData
                );
                productsList.add(mappedProduct);
                userProductCount++;
                foundProductsForUser = true;
                
                if (kDebugMode) {
                  print('  ✅ Added product: ${mappedProduct['Name']} from embedded products');
                }
              }
            });
          }
          
          // Strategy 2: Comprehensive sub-collection discovery
          final subCollectionResults = await _discoverSubCollections(userDoc, userData);
          userProductCount += subCollectionResults['productCount'] as int;
          if (subCollectionResults['foundProducts'] as bool) {
            foundProductsForUser = true;
          }
          productsList.addAll(subCollectionResults['products'] as List<Map<String, dynamic>>);
          
          if (foundProductsForUser) {
            usersWithProducts++;
          }
          
          if (kDebugMode) {
            if (foundProductsForUser) {
              print('  ✅ User ${userDoc.id}: Found $userProductCount products total');
            } else {
              print('  ❌ User ${userDoc.id}: No products found in any sub-collections');
            }
            print(''); // Add spacing between users
          }
        } catch (e) {
          if (kDebugMode) {
            print('  ⚠️ Error processing user ${userDoc.id}: $e');
            print('');
          }
        }
      }

      if (kDebugMode) {
        print('=' * 60);
        print('📊 FINAL RESULTS:');
        print('   Total users processed: $totalUsersProcessed');
        print('   Users with products: $usersWithProducts');
        print('   Total products found: ${productsList.length}');
        
        if (productsList.isEmpty) {
          print('');
          print('🚨 NO PRODUCTS FOUND!');
          print('💡 Possible reasons:');
          print('   1. No sub-collections exist under user documents');
          print('   2. Sub-collections exist but are empty');
          print('   3. Sub-collection names don\'t match expected patterns');
          print('   4. Products are stored in a different structure');
          print('');
          print('🔍 To debug further:');
          print('   - Check your Firestore console for the actual structure');
          print('   - Verify sub-collection names under user documents');
          print('   - Ensure product documents have data');
        } else {
          print('   Sample product: ${productsList.first['Name']} (${productsList.first['id']})');
        }
        print('=' * 60);
      }

      return productsList;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Critical error in getAllProductsList: $e');
      }
      rethrow;
    }
  }
  
  /// Comprehensive sub-collection discovery for a user document
  /// Since Firestore client SDK doesn't have listCollections(), we'll systematically try all possible patterns
  static Future<Map<String, dynamic>> _discoverSubCollections(
    DocumentSnapshot userDoc, 
    Map<String, dynamic> userData
  ) async {
    int productCount = 0;
    bool foundProducts = false;
    final products = <Map<String, dynamic>>[];
    final foundCollections = <String>[];
    final emptyCollections = <String>[];
    final testedCollections = <String>[];
    
    if (kDebugMode) {
      print('  🔍 SYSTEMATIC SUB-COLLECTION DISCOVERY for user: ${userDoc.id}');
      print('  ${'=' * 50}');
    }
    
    // First, build comprehensive list of potential sub-collection names
    final potentialNames = <String>{};
    
    // Strategy 1: Extract from productIds array if present
    if (userData.containsKey('productIds') && userData['productIds'] is List) {
      final productIds = List<String>.from(userData['productIds'] as List);
      potentialNames.addAll(productIds);
      if (kDebugMode) {
        print('  📋 Found productIds array: ${productIds.join(", ")}');
      }
    }
    
    // Strategy 2: Common collection names
    potentialNames.addAll([
      'products', 'items', 'inventory', 'goods', 'merchandise', 'catalog',
      'store_items', 'product_list', 'my_products', 'shop_items', 'data',
      'productData', 'medicines', 'drugs', 'stock', 'store', 'shop',
      'product', 'item', 'medicine', 'drug', 'goods_list', 'inventory_items',
      'store_products', 'pharmacy_items', 'medical_supplies', 'supplies',
    ]);
    
    // Strategy 3: Numeric patterns (common for product IDs)
    for (int i = 1; i <= 20; i++) {
      potentialNames.addAll([
        i.toString(), // 1, 2, 3
        i.toString().padLeft(2, '0'), // 01, 02, 03
        i.toString().padLeft(3, '0'), // 001, 002, 003
        'prod$i', 'product$i', 'item$i', // prod1, product1, item1
      ]);
    }
    
    // Strategy 4: Common UUID-like patterns that might exist
    potentialNames.addAll([
      'abcd1234', 'xyz789', '1a2b3c4d', 'test123', 'demo456',
      'sample', 'example', 'default', 'main', 'primary'
    ]);
    
    if (kDebugMode) {
      print('  🎯 Testing ${potentialNames.length} potential sub-collection names...');
      print('');
    }
    
    // Now systematically test each potential collection name
    for (final collectionName in potentialNames.toList()..sort()) {
      testedCollections.add(collectionName);
      
      try {
        final subCollection = userDoc.reference.collection(collectionName);
        final snapshot = await subCollection.get();
        
        if (snapshot.docs.isNotEmpty) {
          if (kDebugMode) {
            print('  ✅ SUB-COLLECTION "$collectionName": ${snapshot.docs.length} documents');
          }
          
          // Check if documents look like products
          int validProducts = 0;
          final collectionProducts = <Map<String, dynamic>>[];
          
          for (final doc in snapshot.docs) {
            final docData = doc.data();
            if (_looksLikeProduct(docData)) {
              final mappedProduct = _mapProductData(
                docData, 
                collectionName, 
                userDoc.id, 
                doc.id, 
                userData
              );
              collectionProducts.add(mappedProduct);
              validProducts++;
              
              if (kDebugMode && validProducts <= 3) {
                print('    📦 Product: ${mappedProduct['Name']} (${doc.id})');
              }
            } else {
              if (kDebugMode) {
                print('    ⚠️ Document ${doc.id} doesn\'t look like product: ${docData.keys.join(", ")}');
              }
            }
          }
          
          if (validProducts > 0) {
            foundCollections.add(collectionName);
            products.addAll(collectionProducts);
            productCount += validProducts;
            foundProducts = true;
            
            if (kDebugMode) {
              print('    📊 Valid products in "$collectionName": $validProducts/${snapshot.docs.length}');
            }
          } else {
            emptyCollections.add(collectionName);
            if (kDebugMode) {
              print('    ❌ No valid products in "$collectionName" (${snapshot.docs.length} non-product documents)');
            }
          }
        } else {
          emptyCollections.add(collectionName);
          if (kDebugMode) {
            print('  ❌ SUB-COLLECTION "$collectionName": EMPTY (no documents)');
          }
        }
      } catch (e) {
        // Most errors are expected (collection doesn't exist), but log permissions issues
        if (kDebugMode && (e.toString().contains('permission') || e.toString().contains('denied'))) {
          print('  🔒 SUB-COLLECTION "$collectionName": PERMISSION DENIED');
        }
        // Silently ignore "not found" errors as they're expected
      }
    }
    
    if (kDebugMode) {
      print('');
      print('  📋 DISCOVERY SUMMARY:');
      print('    🔍 Collections tested: ${testedCollections.length}');
      print('    ✅ Collections with products: ${foundCollections.length}');
      print('    ❌ Empty/non-product collections: ${emptyCollections.length}');
      print('    📦 Total valid products found: $productCount');
      
      if (foundCollections.isNotEmpty) {
        print('    🎯 Product collections: ${foundCollections.join(", ")}');
      }
      
      if (emptyCollections.length <= 10) {
        print('    🚫 Empty collections: ${emptyCollections.join(", ")}');
      } else {
        print('    🚫 Empty collections: ${emptyCollections.take(10).join(", ")}... and ${emptyCollections.length - 10} more');
      }
    }
    
    return {
      'products': products,
      'productCount': productCount,
      'foundProducts': foundProducts,
      'foundCollections': foundCollections,
      'emptyCollections': emptyCollections,
      'testedCollections': testedCollections,
    };
  }
  
  
  /// Check if a document looks like a product based on common fields
  static bool _looksLikeProduct(Map<String, dynamic> data) {
    final productFields = [
      'name', 'Name', 'productName',
      'price', 'Price', 'cost',
      'quantity', 'Quantity', 'stock',
      'category', 'Category',
      'description', 'Description',
      'manufacturer', 'Manufacturer',
      'brand', 'Brand',
      'sku', 'SKU', 'barcode',
    ];
    
    // Check if document has at least 2 product-like fields
    int matchedFields = 0;
    for (final field in productFields) {
      if (data.containsKey(field)) {
        matchedFields++;
        if (matchedFields >= 2) {
          return true;
        }
      }
    }
    
    // Also accept if it has any obvious product identifier
    final obviousFields = ['name', 'Name', 'productName'];
    for (final field in obviousFields) {
      if (data.containsKey(field) && data[field] != null && data[field].toString().isNotEmpty) {
        return true;
      }
    }
    
    return false;
  }

  /// Helper method to map product data with consistent field structure
  static Map<String, dynamic> _mapProductData(
    Map<String, dynamic> productData, 
    String productId, 
    String userId, 
    String documentId, 
    Map<String, dynamic> userData,
  ) {
    return {
      'id': productId, // Use provided product ID
      'userId': userId,
      'documentId': documentId, // Keep original document ID for reference
      
      // Map standard fields with fallbacks
      'Name': productData['Name'] ?? 
              productData['name'] ?? 
              productData['productName'] ?? 
              'Unknown Product',
              
      'Price': productData['Price'] ?? 
              productData['price'] ?? 
              productData['cost'] ?? 
              0,
              
      'Quantity': productData['Quantity'] ?? 
                 productData['quantity'] ?? 
                 productData['stock'] ?? 
                 0,
                 
      'StoreName': productData['StoreName'] ?? 
                  productData['storeName'] ?? 
                  productData['store'] ?? 
                  userData['storeName'] ?? 
                  'Unknown Store',
                  
      'StoreId': productData['StoreId'] ?? 
                productData['storeId'] ?? 
                userId, // Use user ID as store ID fallback
                
      'Category': productData['Category'] ?? 
                 productData['category'] ?? 
                 'Uncategorized',
                 
      'description': productData['description'] ?? 
                    productData['Description'] ?? 
                    '',
                    
      'manufacturer': productData['manufacturer'] ?? 
                     productData['Manufacturer'] ?? 
                     '',
                     
      'StoreLocation': productData['StoreLocation'] ?? 
                      productData['storeLocation'],
                      
      // Include timestamps if available
      'createdAt': productData['createdAt'],
      'updatedAt': productData['updatedAt'],
      
    };
  }

  /// Search products by name or description
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final allProducts = await getAllProductsList();

      if (query.isEmpty) {
        return allProducts;
      }

      final searchQuery = query.toLowerCase().trim();

      final filteredProducts = allProducts.where((product) {
        final name = (product['Name'] ?? '').toString().toLowerCase();
        final description =
            (product['description'] ?? '').toString().toLowerCase();
        final category = (product['Category'] ?? '').toString().toLowerCase();
        final manufacturer =
            (product['manufacturer'] ?? '').toString().toLowerCase();

        return name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            category.contains(searchQuery) ||
            manufacturer.contains(searchQuery);
      }).toList();

      if (kDebugMode) {
        print(
            '🔍 Search for "$query" returned ${filteredProducts.length} results');
      }

      return filteredProducts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching products: $e');
      }
      rethrow;
    }
  }

  /// Search products by category using Firestore query (nested structure)
  static Future<List<Map<String, dynamic>>> searchProductsByCategory(
      String category) async {
    try {
      // For nested structure, we need to get all products first and then filter
      // Direct querying on subcollections is more complex
      final allProducts = await getAllProductsList();
      
      final filteredProducts = allProducts.where((product) {
        final productCategory = (product['Category'] ?? '').toString();
        return productCategory == category;
      }).toList();

      if (kDebugMode) {
        print(
            '🏷️ Category search for "$category" returned ${filteredProducts.length} results');
      }

      return filteredProducts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching products by category: $e');
      }
      rethrow;
    }
  }

  /// Update a product
  static Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final updateData = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _productsRef!.doc(productId).update(updateData);

      if (kDebugMode) {
        print('✅ Product $productId updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating product: $e');
      }
      rethrow;
    }
  }

  /// Delete a product
  static Future<void> deleteProduct(String productId) async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      await _productsRef!.doc(productId).delete();

      if (kDebugMode) {
        print('✅ Product $productId deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting product: $e');
      }
      rethrow;
    }
  }

  /// Delete all products from a collection (be careful with this!)
  static Future<void> deleteAllProducts() async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final snapshot = await _productsRef!.get();
      final batch = _firestore!.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ All products deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting all products: $e');
      }
      rethrow;
    }
  }

  // ===== USER MANAGEMENT =====

  /// Add user data
  static Future<void> addUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      if (_usersRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final userDataWithTimestamp = {
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _usersRef!.doc(userId).set(userDataWithTimestamp);

      if (kDebugMode) {
        print('✅ User $userId added successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding user: $e');
      }
      rethrow;
    }
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      if (_usersRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final snapshot = await _usersRef!.doc(userId).get();

      if (!snapshot.exists) {
        return null;
      }

      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user: $e');
      }
      rethrow;
    }
  }

  /// Update user data
  static Future<void> updateUser(
      String userId, Map<String, dynamic> updates) async {
    try {
      if (_usersRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final updateData = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _usersRef!.doc(userId).update(updateData);

      if (kDebugMode) {
        print('✅ User $userId updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user: $e');
      }
      rethrow;
    }
  }

  // ===== GENERAL DOCUMENT OPERATIONS =====

  /// Check if a document exists
  static Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await _firestore!.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking document existence: $e');
      }
      return false;
    }
  }

  /// Add a document to a collection
  static Future<String> addDocument(
      String collection, Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore!.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Document added successfully with ID: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding document: $e');
      }
      rethrow;
    }
  }

  /// Set a document in a collection (with specific ID)
  static Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore!.collection(collection).doc(docId).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Document set successfully with ID: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting document: $e');
      }
      rethrow;
    }
  }

  /// Get a document from a collection
  static Future<DocumentSnapshot?> getDocument(
      String collection, String docId) async {
    try {
      final doc = await _firestore!.collection(collection).doc(docId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting document: $e');
      }
      return null;
    }
  }

  /// Update a document
  static Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore!.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Document updated successfully: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating document: $e');
      }
      rethrow;
    }
  }

  /// Delete a document
  static Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore!.collection(collection).doc(docId).delete();

      if (kDebugMode) {
        print('✅ Document deleted successfully: $docId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting document: $e');
      }
      rethrow;
    }
  }

  /// Get all documents from a collection
  static Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore!.collection(collection).get();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting collection: $e');
      }
      rethrow;
    }
  }

  /// Query documents with conditions
  static Future<QuerySnapshot> queryDocuments(
    String collection,
    String field,
    dynamic value, {
    String operator = '==',
  }) async {
    try {
      Query query = _firestore!.collection(collection);

      switch (operator) {
        case '==':
          query = query.where(field, isEqualTo: value);
          break;
        case '!=':
          query = query.where(field, isNotEqualTo: value);
          break;
        case '>':
          query = query.where(field, isGreaterThan: value);
          break;
        case '<':
          query = query.where(field, isLessThan: value);
          break;
        case '>=':
          query = query.where(field, isGreaterThanOrEqualTo: value);
          break;
        case '<=':
          query = query.where(field, isLessThanOrEqualTo: value);
          break;
        case 'array-contains':
          query = query.where(field, arrayContains: value);
          break;
        case 'in':
          query = query.where(field, whereIn: value);
          break;
      }

      return await query.get();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error querying documents: $e');
      }
      rethrow;
    }
  }

  // ===== UTILITY METHODS =====

  /// Get database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    try {
      final products = await getAllProductsList();

      final stats = {
        'totalProducts': products.length,
        'inStockProducts': products.where((p) => p['inStock'] == true).length,
        'outOfStockProducts':
            products.where((p) => p['inStock'] == false).length,
      };

      // Count products by category
      final categories = <String, int>{};
      for (final product in products) {
        final category = product['category']?.toString() ?? 'Unknown';
        categories[category] = (categories[category] ?? 0) + 1;
      }

      if (kDebugMode) {
        print('📊 Database stats: $stats');
        print('📊 Categories: $categories');
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting database stats: $e');
      }
      rethrow;
    }
  }

  /// Check Firestore connection
  static Future<bool> checkConnection() async {
    try {
      if (_firestore == null) {
        return false;
      }

      // Try to read from Firestore to check connection
      await _firestore!.collection('test').limit(1).get();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firestore connection check failed: $e');
      }
      return false;
    }
  }
  
  /// Debug method to explore Firestore structure and help identify where products are stored
  static Future<void> exploreFirestoreStructure() async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      if (kDebugMode) {
        print('');
        print('🔬 FIRESTORE STRUCTURE EXPLORATION');
        print('=' * 60);
        print('📊 Analyzing Products collection structure...');
        print('');
      }
      
      final userSnapshot = await _productsRef!.get();
      
      if (userSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('❌ Products collection is completely empty');
          print('💡 You need to add some data to your Products collection first');
        }
        return;
      }
      
      if (kDebugMode) {
        print('📁 Found ${userSnapshot.docs.length} user documents in Products collection:');
      }
      
      for (int i = 0; i < userSnapshot.docs.length && i < 3; i++) {
        final userDoc = userSnapshot.docs[i];
        if (kDebugMode) {
          print('');
          print('👤 User Document ${i + 1}: ${userDoc.id}');
          print('   Document data keys: ${(userDoc.data() as Map<String, dynamic>).keys.join(", ")}');
          
          final userData = userDoc.data() as Map<String, dynamic>;
          
          // Check for embedded products
          if (userData.containsKey('products')) {
            print('   📦 Contains embedded "products" field');
            if (userData['products'] is Map) {
              final productsMap = userData['products'] as Map;
              print('   📊 Embedded products count: ${productsMap.length}');
              if (productsMap.isNotEmpty) {
                print('   🏷️ Sample product keys: ${(productsMap.values.first as Map).keys.join(", ")}');
              }
            }
          }
          
          if (userData.containsKey('productIds')) {
            print('   📋 Contains "productIds" array: ${userData['productIds']}');
          }
          
          // Try to find actual sub-collections by attempting common names
          print('   🔍 Checking for sub-collections...');
          await _exploreSubCollections(userDoc);
        }
      }
      
      if (kDebugMode) {
        print('');
        print('=' * 60);
        print('💡 RECOMMENDATIONS:');
        print('1. Check the above structure analysis');
        print('2. Look for sub-collections that were found');
        print('3. Verify product documents have name/Name fields');
        print('4. If no sub-collections found, products might be embedded in user documents');
        print('=' * 60);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error exploring Firestore structure: $e');
      }
    }
  }
  
  /// Explore sub-collections under a specific user document
  static Future<void> _exploreSubCollections(DocumentSnapshot userDoc) async {
    final testCollections = [
      'products', 'items', 'inventory', 'goods', 'data', 'medicines',
      '1', '01', '001', 'product1', 'item1'
    ];
    
    bool foundAnySubCollection = false;
    
    for (final collectionName in testCollections) {
      try {
        final subCollection = userDoc.reference.collection(collectionName);
        final snapshot = await subCollection.get();
        
        if (snapshot.docs.isNotEmpty) {
          foundAnySubCollection = true;
          if (kDebugMode) {
            print('     ✅ Sub-collection "$collectionName": ${snapshot.docs.length} documents');
            
            // Show sample document structure
            final sampleDoc = snapshot.docs.first;
            final sampleData = sampleDoc.data();
            print('        📄 Sample doc ID: ${sampleDoc.id}');
            print('        🏷️ Sample doc fields: ${sampleData.keys.join(", ")}');
            
            // Check if it looks like a product
            if (_looksLikeProduct(sampleData)) {
              print('        ✅ This looks like product data!');
            } else {
              print('        ⚠️ This doesn\'t look like typical product data');
            }
          }
        }
      } catch (e) {
        // Expected for non-existent collections
      }
    }
    
    if (!foundAnySubCollection && kDebugMode) {
      print('     ❌ No sub-collections found with common names');
    }
  }

  /// Get real-time products stream 
  /// Periodically refreshes using dynamic subcollection discovery
  static Stream<List<Map<String, dynamic>>> getProductsStream() {
    if (_usersRef == null) {
      throw Exception('Firestore service not initialized');
    }

    // Use periodic refresh to dynamically discover subcollections
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      try {
        return await getAllProductsList();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error in products stream: $e');
        }
        return <Map<String, dynamic>>[];
      }
    });
  }

  /// Get real-time user stream
  static Stream<Map<String, dynamic>?> getUserStream(String userId) {
    if (_usersRef == null) {
      throw Exception('Firestore service not initialized');
    }

    return _usersRef!.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return snapshot.data() as Map<String, dynamic>;
    });
  }

  // ===== USER-SPECIFIC PRODUCT OPERATIONS =====

  /// Get products for a specific user from Products collection
  /// Structure: Products (collection) -> User Document -> Product Sub-collections -> Product Documents
  /// Dynamically discovers all sub-collections under the user document
  /// Each sub-collection ID is considered a product ID
  static Future<List<Map<String, dynamic>>> getProductsForUser(String userId) async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      // Get the user document from Products collection
      final userDoc = await _productsRef!.doc(userId).get();
      if (!userDoc.exists) {
        if (kDebugMode) {
          print('User $userId not found in Products collection');
        }
        return [];
      }

      final productsList = <Map<String, dynamic>>[];
      final userData = userDoc.data() as Map<String, dynamic>;
      int userProductCount = 0;
      bool foundProducts = false;

      // Strategy 1: Look for a productIds array in user data
      List<String>? productIds;
      if (userData.containsKey('productIds') && userData['productIds'] is List) {
        productIds = List<String>.from(userData['productIds'] as List);
        if (kDebugMode) {
          print('📂 Found ${productIds.length} product IDs in user data');
        }
      }
      
      // Strategy 2: Look for products map directly in user data
      Map<String, dynamic>? productsMap;
      if (userData.containsKey('products') && userData['products'] is Map) {
        productsMap = Map<String, dynamic>.from(userData['products'] as Map);
        if (kDebugMode) {
          print('📂 Found ${productsMap.length} products in user data products map');
        }
      }
      
      // Strategy 3: Attempt to query all direct subcollections
      // The name of the subcollection is the product ID itself
      if (productIds != null && productIds.isNotEmpty) {
        for (final productId in productIds) {
          try {
            final productSubCollection = userDoc.reference.collection(productId);
            final snapshot = await productSubCollection.get();
            
            if (snapshot.docs.isNotEmpty) {
              foundProducts = true;
              if (kDebugMode) {
                print('📂 User $userId: Found ${snapshot.docs.length} documents in product "$productId" sub-collection');
              }
              
              for (final productDoc in snapshot.docs) {
                final productData = productDoc.data();
                final mappedProduct = _mapProductData(productData, productId, userId, productDoc.id, userData);
                productsList.add(mappedProduct);
                userProductCount++;
                
                if (kDebugMode) {
                  print('✅ Added product: ${mappedProduct['Name']} (ID: ${mappedProduct['id']}) from product ID: $productId');
                }
              }
            }
          } catch (collectionError) {
            // Silently continue to next product ID - this is expected for non-existent collections
            if (kDebugMode && (collectionError.toString().contains('permission') || collectionError.toString().contains('denied'))) {
              print('⚠️ Permission issue accessing product "$productId" for user $userId: $collectionError');
            }
          }
        }
      }
      
      // Strategy 4: If productsMap exists, process it directly (no need for subcollection access)
      if (productsMap != null && productsMap.isNotEmpty) {
        productsMap.forEach((productId, productData) {
          if (productData is Map) {
            final mappedProduct = _mapProductData(
              Map<String, dynamic>.from(productData), 
              productId, 
              userId, 
              productId, // Use productId as document ID since it's a direct map
              userData
            );
            productsList.add(mappedProduct);
            userProductCount++;
            foundProducts = true;
            
            if (kDebugMode) {
              print('✅ Added product: ${mappedProduct['Name']} (ID: $productId) from products map');
            }
          }
        });
      }
      
      // Strategy 5: If previous methods found nothing, attempt to get all subcollections directly
      // This is a backup strategy for when product IDs aren't explicitly listed
      if (!foundProducts) {
        // Dynamically discover subcollections by attempting to query various patterns
        // Since listCollections() is not available in Flutter SDK, we'll try common patterns
        
        // Strategy 5a: Check for numeric subcollection IDs (product IDs are often numeric or UUIDs)
        bool foundNumericCollections = false;
        
        // Try a range of numeric values that might be product IDs
        for (int i = 1; i <= 10; i++) {
          try {
            final testId = i.toString().padLeft(5, '0'); // Try format like 00001, 00002, etc.
            final numericCollection = userDoc.reference.collection(testId);
            final snapshot = await numericCollection.get();
            
            if (snapshot.docs.isNotEmpty) {
              foundNumericCollections = true;
              foundProducts = true;
              if (kDebugMode) {
                print('📂 Found numeric subcollection pattern. Trying more IDs...');
              }
              break; // We found a pattern, will expand search in next step
            }
          } catch (_) {
            // Silently continue if collection doesn't exist
          }
        }
        
        // If we found numeric collections, try more patterns
        if (foundNumericCollections) {
          // Try more comprehensive numeric patterns (could expand with UUID patterns too)
          final patterns = [
            // Try common numeric formats
            ...List.generate(100, (i) => (i+1).toString()), // 1, 2, 3, ...
            ...List.generate(100, (i) => (i+1).toString().padLeft(2, '0')), // 01, 02, ...
            ...List.generate(100, (i) => (i+1).toString().padLeft(3, '0')), // 001, 002, ...
            // Add other patterns if needed
          ];
          
          for (final pattern in patterns) {
            try {
              final numericCollection = userDoc.reference.collection(pattern);
              final snapshot = await numericCollection.get();
              
              if (snapshot.docs.isNotEmpty) {
                if (kDebugMode) {
                  print('📂 User $userId: Found ${snapshot.docs.length} documents in numeric ID "$pattern" sub-collection');
                }
                
                for (final productDoc in snapshot.docs) {
                  final productData = productDoc.data();
                  final mappedProduct = _mapProductData(productData, pattern, userId, productDoc.id, userData);
                  productsList.add(mappedProduct);
                  userProductCount++;
                  
                  if (kDebugMode) {
                    print('✅ Added product: ${mappedProduct['Name']} (ID: $pattern) from numeric pattern');
                  }
                }
              }
            } catch (_) {
              // Silently continue if collection doesn't exist
            }
          }
        }
        
        // Strategy 5b: Try UUID-like patterns if needed (implement if common in your database)
        // This would involve attempting to query collections with UUID-like names
        
        // Strategy 5c: Final fallback - try common subcollection names as a last resort
        if (!foundProducts) {
          final commonSubCollectionNames = [
            'products', 'items', 'inventory', 'goods', 'merchandise', 'catalog',
            'store_items', 'product_list', 'my_products', 'shop_items',
          ];
          
          for (final collectionName in commonSubCollectionNames) {
            try {
              final productSubCollection = userDoc.reference.collection(collectionName);
              final snapshot = await productSubCollection.get();
              
              if (snapshot.docs.isNotEmpty) {
                foundProducts = true;
                if (kDebugMode) {
                  print('📂 User $userId: Found ${snapshot.docs.length} products in "$collectionName" sub-collection');
                }
                
                for (final productDoc in snapshot.docs) {
                  final productData = productDoc.data();
                  final mappedProduct = _mapProductData(productData, collectionName, userId, productDoc.id, userData);
                  productsList.add(mappedProduct);
                  userProductCount++;
                  
                  if (kDebugMode) {
                    print('✅ Added product: ${mappedProduct['Name']} (ID: ${mappedProduct['id']}) from sub-collection: $collectionName');
                  }
                }
              }
            } catch (collectionError) {
              // Silently continue to next collection name - this is expected for non-existent collections
              if (kDebugMode && (collectionError.toString().contains('permission') || collectionError.toString().contains('denied'))) {
                print('⚠️ Permission issue accessing "$collectionName" for user $userId: $collectionError');
              }
            }
          }
        }
      }
      
      if (!foundProducts && kDebugMode) {
        print('⚠️ No products found for user $userId using any discovery method');
      }

      if (kDebugMode) {
        print('👤 Retrieved $userProductCount products for user $userId');
      }

      return productsList;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products for user $userId: $e');
      }
      rethrow;
    }
  }

  /// Add a product to a specific user's subcollection
  static Future<String> addProductToUser(String userId, Map<String, dynamic> product) async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      print('🔥 FirestoreService.addProductToUser: Starting to add product for user $userId');
      print('📦 Product data to add: ${product.toString()}');
      
      final userDoc = _productsRef!.doc(userId);
      final productsSubcollection = userDoc.collection('products');
      
      print('🎯 FirestoreService: Target path = Products/$userId/products/');

      // Use the product data as-is (timestamps already added in AddProductScreen)
      final productData = Map<String, dynamic>.from(product);
      
      print('📝 FirestoreService: Final product data to save: ${productData.toString()}');
      
      // Log each field being saved
      print('📝 FirestoreService: Individual fields:');
      productData.forEach((key, value) {
        print('   $key: $value (${value.runtimeType})');
      });

      final docRef = await productsSubcollection.add(productData);
      final productId = docRef.id;
      
      print('✅ FirestoreService: Product document created with ID: $productId');

      // Update the document with its own ID
      await docRef.update({'id': productId});
      
      print('🔄 FirestoreService: Product document updated with id field');
      
      // Verify the document was saved by reading it back
      final savedDoc = await docRef.get();
      if (savedDoc.exists) {
        final savedData = savedDoc.data();
        print('✅ FirestoreService: Document verification - saved data: ${savedData.toString()}');
      } else {
        print('❌ FirestoreService: Document verification FAILED - document does not exist!');
      }

      if (kDebugMode) {
        print('✅ Product added successfully to user $userId with ID: $productId');
        print('🗂️ Full Firestore path: Products/$userId/products/$productId');
      }

      return productId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding product to user $userId: $e');
      }
      rethrow;
    }
  }

  /// Update a product in a specific user's subcollection
  static Future<void> updateUserProduct(String userId, String productId, Map<String, dynamic> updates) async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final userDoc = _productsRef!.doc(userId);
      final productDoc = userDoc.collection('products').doc(productId);

      final updateData = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await productDoc.update(updateData);

      if (kDebugMode) {
        print('✅ Product $productId updated successfully for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating product $productId for user $userId: $e');
      }
      rethrow;
    }
  }

  /// Delete a product from a specific user's subcollection
  static Future<void> deleteUserProduct(String userId, String productId) async {
    try {
      if (_productsRef == null) {
        throw Exception('Firestore service not initialized');
      }

      final userDoc = _productsRef!.doc(userId);
      final productDoc = userDoc.collection('products').doc(productId);

      await productDoc.delete();

      if (kDebugMode) {
        print('✅ Product $productId deleted successfully from user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting product $productId from user $userId: $e');
      }
      rethrow;
    }
  }
}

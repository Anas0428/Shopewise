// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/products.dart';

class ProductDiscoveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _productsRef =
      _firestore.collection('Products');

  /// Cache for discovered products to avoid repeated API calls
  static final Map<String, List<Product>> _productCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Efficiently discover all products across all users/stores
  /// Uses the new Map-based structure based on working function
  static Future<List<Product>> discoverAllProducts(
      {bool forceRefresh = false}) async {
    try {
      if (kDebugMode) {
        print('🔍 Starting efficient product discovery...');
        print('=' * 60);
      }

      final productsList = <Product>[];
      int totalUsersProcessed = 0;
      int usersWithProducts = 0;

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
        print('🔍 Processing each user for product discovery...');
        print('');
      }

      // Process each user document
      for (final userDoc in userSnapshot.docs) {
        totalUsersProcessed++;
        final userId = userDoc.id;

        if (kDebugMode) {
          print(
              '👤 Processing User $totalUsersProcessed/${userSnapshot.docs.length}: $userId');
        }

        try {
          // Check cache first (unless force refresh)
          if (!forceRefresh && _isCacheValid(userId)) {
            final cachedProducts = _productCache[userId] ?? [];
            if (cachedProducts.isNotEmpty) {
              productsList.addAll(cachedProducts);
              usersWithProducts++;
              if (kDebugMode) {
                print(
                    '  📦 Using cached products: ${cachedProducts.length} items');
              }
              continue;
            }
          }

          // Discover products for this user
          final userProducts = await _discoverUserProducts(userDoc);

          if (userProducts.isNotEmpty) {
            // Cache the results
            _productCache[userId] = userProducts;
            _cacheTimestamps[userId] = DateTime.now();

            productsList.addAll(userProducts);
            usersWithProducts++;

            if (kDebugMode) {
              print('  ✅ Found ${userProducts.length} products (cached)');
            }
          } else {
            if (kDebugMode) {
              print('  ❌ No products found');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('  ⚠️ Error processing user $userId: $e');
          }
        }

        if (kDebugMode) {
          print(''); // Add spacing between users
        }
      }

      if (kDebugMode) {
        print('=' * 60);
        print('📊 DISCOVERY RESULTS:');
        print('   Total users processed: $totalUsersProcessed');
        print('   Users with products: $usersWithProducts');
        print('   Total products found: ${productsList.length}');

        if (productsList.isNotEmpty) {
          print(
              '   Sample product: ${productsList.first.name} (${productsList.first.storeName})');
        }
        print('=' * 60);
      }

      return productsList;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Critical error in product discovery: $e');
      }
      rethrow;
    }
  }

  /// Discover products for a specific user using smart strategies
  static Future<List<Product>> _discoverUserProducts(
      DocumentSnapshot userDoc) async {
    final userId = userDoc.id;
    final userData = userDoc.data() as Map<String, dynamic>? ?? {};
    final products = <Product>[];

    if (kDebugMode) {
      print('  🔍 Discovering products for user: $userId');
    }

    // Strategy 1: Check for embedded products in user document
    final embeddedProducts = await _extractEmbeddedProducts(userDoc, userData);
    if (embeddedProducts.isNotEmpty) {
      products.addAll(embeddedProducts);
      if (kDebugMode) {
        print('  📦 Found ${embeddedProducts.length} embedded products');
        return products; // Short-circuit if we found embedded products
      }
    }

    // Strategy 2: List actual sub-collections (no guessing!)
    final subCollectionProducts =
        await _discoverSubCollections(userDoc, userData);
    if (subCollectionProducts.isNotEmpty) {
      products.addAll(subCollectionProducts);
      if (kDebugMode) {
        print(
            '  📁 Found ${subCollectionProducts.length} products in sub-collections');
      }
    }

    return products;
  }

  /// Extract products embedded directly in user document
  static Future<List<Product>> _extractEmbeddedProducts(
      DocumentSnapshot userDoc, Map<String, dynamic> userData) async {
    final products = <Product>[];

    // Check for common embedded product field names
    final embeddedFields = [
      'products',
      'productList',
      'items',
      'medicines',
      'inventory',
      'goods',
      'merchandise',
      'catalog',
      'store_items'
    ];

    for (final fieldName in embeddedFields) {
      if (userData.containsKey(fieldName)) {
        final fieldData = userData[fieldName];

        if (fieldData is Map) {
          // Products stored as a map
          final productsMap = Map<String, dynamic>.from(fieldData);
          if (kDebugMode) {
            print(
                '    📋 Found embedded "$fieldName" map with ${productsMap.length} items');
          }

          productsMap.forEach((productId, productData) {
            if (productData is Map) {
              final productDataMap = Map<String, dynamic>.from(productData);
              if (_looksLikeProduct(productDataMap)) {
                try {
                  final product = Product.fromFirestore(
                      productDataMap, userDoc.id, productId);
                  if (product.isValid) {
                    products.add(product);
                    if (kDebugMode) {
                      print('      ✅ Added embedded product: ${product.name}');
                    }
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print(
                        '      ⚠️ Error parsing embedded product $productId: $e');
                  }
                }
              }
            }
          });

          if (products.isNotEmpty) {
            if (kDebugMode) {
              print(
                  '    📊 Successfully extracted ${products.length} embedded products');
            }
            return products; // Short-circuit on success
          }
        } else if (fieldData is List) {
          // Products stored as an array
          final productsList = List<Map<String, dynamic>>.from(fieldData);
          if (kDebugMode) {
            print(
                '    📋 Found embedded "$fieldName" list with ${productsList.length} items');
          }

          for (int i = 0; i < productsList.length; i++) {
            final productData = productsList[i];
            if (_looksLikeProduct(productData)) {
              try {
                final product = Product.fromFirestore(
                    productData, userDoc.id, 'embedded_$i');
                if (product.isValid) {
                  products.add(product);
                  if (kDebugMode) {
                    print('      ✅ Added embedded product: ${product.name}');
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('      ⚠️ Error parsing embedded product $i: $e');
                }
              }
            }
          }

          if (products.isNotEmpty) {
            if (kDebugMode) {
              print(
                  '    📊 Successfully extracted ${products.length} embedded products');
            }
            return products; // Short-circuit on success
          }
        }
      }
    }

    return products;
  }

  /// Discover products in actual sub-collections (no guessing!)
  static Future<List<Product>> _discoverSubCollections(
      DocumentSnapshot userDoc, Map<String, dynamic> userData) async {
    final products = <Product>[];

    if (kDebugMode) {
      print('    🔍 Checking for actual sub-collections...');
    }

    // Since Flutter Firestore SDK doesn't have listCollections(),
    // we'll use a smart approach based on actual data patterns

    // Strategy 1: Check if user has productIds array that tells us sub-collection names
    if (userData.containsKey('productIds') && userData['productIds'] is List) {
      final productIds = List<String>.from(userData['productIds'] as List);
      if (kDebugMode) {
        print('    📋 Found productIds array: ${productIds.join(", ")}');
      }

      for (final productId in productIds) {
        final subCollectionProducts =
            await _fetchSubCollectionProducts(userDoc, productId, userData);
        products.addAll(subCollectionProducts);
      }

      if (products.isNotEmpty) {
        if (kDebugMode) {
          print(
              '    📊 Found ${products.length} products in productIds sub-collections');
        }
        return products;
      }
    }

    // Strategy 2: Try to infer sub-collection names from user data patterns
    final inferredCollections = _inferSubCollectionNames(userData);
    if (kDebugMode) {
      print(
          '    🎯 Inferred potential sub-collections: ${inferredCollections.join(", ")}');
    }

    for (final collectionName in inferredCollections) {
      final subCollectionProducts =
          await _fetchSubCollectionProducts(userDoc, collectionName, userData);
      products.addAll(subCollectionProducts);

      // If we found products, we can stop searching (short-circuit)
      if (subCollectionProducts.isNotEmpty) {
        if (kDebugMode) {
          print('    ✅ Found products in "$collectionName", stopping search');
        }
        break;
      }
    }

    return products;
  }

  /// Fetch products from a specific sub-collection
  static Future<List<Product>> _fetchSubCollectionProducts(
      DocumentSnapshot userDoc,
      String collectionName,
      Map<String, dynamic> userData) async {
    final products = <Product>[];

    try {
      final subCollection = userDoc.reference.collection(collectionName);
      final snapshot = await subCollection.get();

      if (snapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          print(
              '      📁 Sub-collection "$collectionName": ${snapshot.docs.length} documents');
        }

        for (final doc in snapshot.docs) {
          final docData = doc.data();
          if (_looksLikeProduct(docData)) {
            try {
              final product =
                  Product.fromFirestore(docData, userDoc.id, doc.id);
              if (product.isValid) {
                products.add(product);
                if (kDebugMode) {
                  print('        ✅ Added product: ${product.name} (${doc.id})');
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('        ⚠️ Error parsing product ${doc.id}: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      // Most errors are expected (collection doesn't exist)
      if (kDebugMode &&
          (e.toString().contains('permission') ||
              e.toString().contains('denied'))) {
        print(
            '      🔒 Permission denied for sub-collection "$collectionName"');
      }
    }

    return products;
  }

  /// Infer potential sub-collection names from user data
  static List<String> _inferSubCollectionNames(Map<String, dynamic> userData) {
    final names = <String>{};

    // Check for any fields that might indicate sub-collection names
    if (userData.containsKey('subCollections')) {
      final subCollections = userData['subCollections'];
      if (subCollections is List) {
        names.addAll(subCollections.map((e) => e.toString()));
      }
    }

    // Add common patterns only if we have evidence they exist
    if (userData.containsKey('hasProducts') &&
        userData['hasProducts'] == true) {
      names.addAll(['products', 'items']);
    }

    if (userData.containsKey('hasInventory') &&
        userData['hasInventory'] == true) {
      names.addAll(['inventory', 'stock']);
    }

    // If no specific hints, try minimal common names
    if (names.isEmpty) {
      names.addAll(['products', 'items', 'data']);
    }

    return names.toList();
  }

  /// Check if a document looks like a product
  static bool _looksLikeProduct(Map<String, dynamic> data) {
    // Must have at least a name field
    if (!data.containsKey('Name') &&
        !data.containsKey('name') &&
        !data.containsKey('productName')) {
      return false;
    }

    // Must have at least one of: price, quantity, category
    final hasPrice = data.containsKey('Price') ||
        data.containsKey('price') ||
        data.containsKey('cost');
    final hasQuantity = data.containsKey('Quantity') ||
        data.containsKey('quantity') ||
        data.containsKey('stock');
    final hasCategory =
        data.containsKey('Category') || data.containsKey('category');

    return hasPrice || hasQuantity || hasCategory;
  }

  /// Check if cache is still valid for a user
  static bool _isCacheValid(String userId) {
    final timestamp = _cacheTimestamps[userId];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheValidity;
  }

  /// Clear cache for a specific user or all users
  static void clearCache([String? userId]) {
    if (userId != null) {
      _productCache.remove(userId);
      _cacheTimestamps.remove(userId);
      if (kDebugMode) {
        print('🗑️ Cleared cache for user: $userId');
      }
    } else {
      _productCache.clear();
      _cacheTimestamps.clear();
      if (kDebugMode) {
        print('🗑️ Cleared all product caches');
      }
    }
  }

  /// Get products for a specific user (with caching)
  static Future<List<Product>> getUserProducts(String userId,
      {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && _isCacheValid(userId)) {
      return _productCache[userId] ?? [];
    }

    try {
      final userDoc = await _productsRef.doc(userId).get();
      if (!userDoc.exists) return [];

      final products = await _discoverUserProducts(userDoc);

      // Cache the results
      _productCache[userId] = products;
      _cacheTimestamps[userId] = DateTime.now();

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products for user $userId: $e');
      }
      return [];
    }
  }

  /// Search products across all users
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await discoverAllProducts();

      if (query.isEmpty) return allProducts;

      final searchQuery = query.toLowerCase().trim();

      return allProducts.where((product) {
        return product.name.toLowerCase().contains(searchQuery) ||
            product.category.toLowerCase().contains(searchQuery) ||
            product.type.toLowerCase().contains(searchQuery) ||
            product.storeName.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching products: $e');
      }
      return [];
    }
  }

  /// Get real-time products stream with periodic refresh
  static Stream<List<Product>> getProductsStream() {
    return Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      try {
        return await discoverAllProducts(forceRefresh: true);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error in products stream: $e');
        }
        return <Product>[];
      }
    });
  }
}

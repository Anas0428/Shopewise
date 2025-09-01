// ignore_for_file: avoid_print, use_rethrow_when_possible

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListWidget extends StatefulWidget {
  final String? searchQuery;
  final VoidCallback? onRefresh;

  const ProductListWidget({
    super.key,
    this.searchQuery,
    this.onRefresh,
  });

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? _lastSearchQuery;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(ProductListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _filterProducts();
    }
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      await getProducts();

      if (mounted) {
        setState(() {
          _filteredProducts = List.from(products);
          _isLoading = false;
        });

        // Apply search filter if there's a query
        if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
          _filterProducts();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load products: $e';
        });
      }
    }
  }

  // Working function based on your database structure
  // Expected Firestore structure: Products/{userId}/products/{productId}
  // This matches the structure created by FirestoreService.addProductToUser()
  Future getProducts() async {
    try {
      // Get all products from all stores using the new Firebase structure
      final userSnapshot =
          await FirebaseFirestore.instance.collection('Products').get();

      print(
          '🔍 ProductListWidget: Found ${userSnapshot.docs.length} user documents in Products collection');

      setState(() {
        products.clear();
      });

      for (var userDoc in userSnapshot.docs) {
        print('👤 ProductListWidget: Processing user ${userDoc.id}');
        try {
          // Get the products subcollection for this user
          final productsSubcollection =
              userDoc.reference.collection('Products');
          final productsSnapshot = await productsSubcollection.get();

          print(
              '  📦 ProductListWidget: Found ${productsSnapshot.docs.length} products for user ${userDoc.id}');

          // Add each product to the main list
          for (var productDoc in productsSnapshot.docs) {
            final data = productDoc.data();
            print(
                '    ✅ ProductListWidget: Adding product ${data['Name']} (${productDoc.id})');
            setState(() {
              products.add({
                "Name": data['Name'] ?? data['name'] ?? 'Unknown Product',
                "Price": data['Price'] ?? data['price'] ?? 0,
                "Quantity": data['Quantity'] ?? data['quantity'] ?? 0,
                "StoreId": data['StoreId'] ?? data['storeId'] ?? userDoc.id,
                "ProductId":
                    data['ProductId'] ?? data['productId'] ?? productDoc.id,
                "Type": data['Type'] ?? data['type'] ?? 'Medicine',
                "Category": data['Category'] ?? data['category'] ?? 'General',
                "StoreName":
                    data['StoreName'] ?? data['storeName'] ?? 'Unknown Store',
                "StoreLocation": data['StoreLocation'] ?? data['storeLocation'],
                "storeEmail": data['storeEmail'] ?? data['email'] ?? '',
                "Expire": data['Expire'] ?? data['expire'],
                "id": productDoc.id,
                "userId": userDoc.id,
              });
            });
          }
        } catch (e) {
          print(
              '❌ ProductListWidget: Error getting products for user ${userDoc.id}: $e');
          continue;
        }
      }

      print('📊 ProductListWidget: Total products loaded: ${products.length}');
    } catch (e) {
      print('❌ ProductListWidget: Error getting all products: $e');
      throw e;
    }
  }

  void _filterProducts() {
    final query = widget.searchQuery?.toLowerCase().trim() ?? '';
    _lastSearchQuery = query;

    if (query.isEmpty) {
      setState(() {
        _filteredProducts = List.from(products);
      });
    } else {
      setState(() {
        _filteredProducts = products.where((product) {
          final name = (product['Name'] ?? '').toString().toLowerCase();
          final category = (product['Category'] ?? '').toString().toLowerCase();
          final type = (product['Type'] ?? '').toString().toLowerCase();
          final storeName =
              (product['StoreName'] ?? '').toString().toLowerCase();

          return name.contains(query) ||
              category.contains(query) ||
              type.contains(query) ||
              storeName.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
    widget.onRefresh?.call();
  }

  void _openEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  void _openMaps(double? latitude, double? longitude, String storeName) async {
    if (latitude == null || longitude == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not available for $storeName')),
        );
      }
      return;
    }

    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading products',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _lastSearchQuery?.isNotEmpty == true
                    ? 'No products found for "$_lastSearchQuery"'
                    : 'No products available yet',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _lastSearchQuery?.isNotEmpty == true
                    ? 'Try a different search term'
                    : 'Check store data or refresh',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshProducts,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Helper functions to safely get values
    String getName() => (product['Name'] ?? 'Unknown Product').toString();
    String getCategory() => (product['Category'] ?? 'General').toString();
    String getType() => (product['Type'] ?? 'Medicine').toString();
    int getQuantity() {
      final qty = product['Quantity'];
      if (qty is int) return qty;
      if (qty is double) return qty.toInt();
      if (qty is String) return int.tryParse(qty) ?? 0;
      return 0;
    }

    String getStoreName() =>
        (product['StoreName'] ?? 'Unknown Store').toString();
    String getStoreEmail() => (product['storeEmail'] ?? '').toString();
    double getPrice() {
      final price = product['Price'];
      if (price is double) return price;
      if (price is int) return price.toDouble();
      if (price is String) return double.tryParse(price) ?? 0.0;
      return 0.0;
    }

    String getFormattedPrice() => 'Rs. ${getPrice().toStringAsFixed(0)}';
    GeoPoint? getStoreLocation() => product['StoreLocation'] as GeoPoint?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product icon/placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medication, // Pill icon for medicines
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name (Prominent)
                  Text(
                    getName(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Category and Type (small caps)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          getCategory().toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          getType().toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Secondary line: Quantity and Store
                  Row(
                    children: [
                      Text(
                        'Quantity: ${getQuantity()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Store: ${getStoreName()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Action buttons
                  if (getStoreEmail().isNotEmpty ||
                      getStoreLocation() != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (getStoreEmail().isNotEmpty)
                          InkWell(
                            onTap: () => _openEmail(getStoreEmail()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 14,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Email Store',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (getStoreEmail().isNotEmpty &&
                            getStoreLocation() != null)
                          const SizedBox(width: 8),
                        if (getStoreLocation() != null)
                          InkWell(
                            onTap: () => _openMaps(
                              getStoreLocation()!.latitude,
                              getStoreLocation()!.longitude,
                              getStoreName(),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'View on Map',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Price (Right side, prominent)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  getFormattedPrice(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 8),
                // Forward arrow for product details
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

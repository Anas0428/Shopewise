import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firestore Service
  FirestoreService.initialize();
  
  runApp(const TestProductsApp());
}

class TestProductsApp extends StatelessWidget {
  const TestProductsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Data Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProductTestScreen(),
    );
  }
}

class ProductTestScreen extends StatefulWidget {
  const ProductTestScreen({super.key});

  @override
  ProductTestScreenState createState() => ProductTestScreenState();
}

class ProductTestScreenState extends State<ProductTestScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final loadedProducts = await FirestoreService.getAllProductsList();
      
      setState(() {
        products = loadedProducts;
        isLoading = false;
      });

      debugPrint('✅ Loaded ${products.length} products');
      for (var product in products) {
        debugPrint('Product: ${product['Name']}, Price: ${product['Price'] ?? product['price']}, Quantity: ${product['Quantity']}');
      }
      
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading products: $e';
        isLoading = false;
      });
      debugPrint('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Data Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isLoading
                ? Colors.orange.shade100
                : errorMessage.isNotEmpty
                    ? Colors.red.shade100
                    : Colors.green.shade100,
            child: Text(
              isLoading
                  ? 'Loading products...'
                  : errorMessage.isNotEmpty
                      ? errorMessage
                      : 'Found ${products.length} products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLoading
                    ? Colors.orange.shade800
                    : errorMessage.isNotEmpty
                        ? Colors.red.shade800
                        : Colors.green.shade800,
              ),
            ),
          ),
          
          // Products List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text('Failed to load products'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: loadProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : products.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No products found'),
                                SizedBox(height: 8),
                                Text('Make sure you have products in your Firebase "Products" collection'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(
                                    product['Name'] ?? 'Unknown Product',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Price: Rs. ${product['Price'] ?? product['price'] ?? 'N/A'}'),
                                      Text('Quantity: ${product['Quantity'] ?? 'N/A'}'),
                                      Text('Category: ${product['Category'] ?? product['category'] ?? 'N/A'}'),
                                      if (product['StoreLocation'] != null)
                                        const Text('Has Location: Yes')
                                      else
                                        const Text('Has Location: No'),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    // Show detailed product info
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(product['Name'] ?? 'Product Details'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: product.entries.map((entry) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Text(
                                                  '${entry.key}: ${entry.value}',
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

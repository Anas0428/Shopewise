import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_database.dart';
import '../widgets/navbar.dart';
import '../models/products.dart';
import 'add_product_screen.dart';

class Search extends StatefulWidget {
  const Search({super.key});
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String fullAddress = ".....";
  final TextEditingController _searchQuery = TextEditingController();
  TextEditingController txt = TextEditingController();
  List<Product> allProducts = [];
  List<Product> nearbyProducts = [];
  List<Product> searchedProducts = [];
  late double userlat;
  late double userlon;
  bool status1 = false;
  bool isLoading = false;

  // Key to force ProductListWidget refresh
  // ignore: unused_field
  final Key _productListKey = UniqueKey();

  int status = 0;

  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    setLocation();
    fetchAllProducts(); // Add this line to fetch products on init
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Scaffold(
                key: _scaffoldKey,
                drawer: const NavBar(),
                floatingActionButton: FloatingActionButton(
                  onPressed: _navigateToAddProduct,
                  backgroundColor: Colors.blue,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                body: Stack(children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40.0),
                            bottomRight: Radius.circular(40.0))),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40.0),
                              bottomRight: Radius.circular(40.0))),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          _scaffoldKey.currentState!
                                              .openDrawer();
                                        },
                                        child: const Icon(Icons.menu_open_sharp,
                                            size: 35, color: Colors.white))),
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: PopupMenuButton(
                                    icon: const Icon(Icons.more_horiz,
                                        size: 25, color: Colors.white),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: const Text("Refresh Products"),
                                        onTap: () {
                                          fetchAllProducts();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Search for',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.055),
                                  ),
                                  Text(
                                    'Your Medicine!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.065),
                                  ),
                                  const SizedBox(height: 10),
                                  Flexible(
                                    child: Container(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        minHeight: 48,
                                      ),
                                      child: TextField(
                                        controller: _searchQuery,
                                        onSubmitted: (value) {},
                                        onChanged: (value) async {
                                          // Filter products based on search query
                                          filterProducts(value);
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.search),
                                          suffixIcon: IconButton(
                                              icon: const Icon(Icons
                                                  .filter_list_off_outlined),
                                              onPressed: () {
                                                _searchQuery.clear();
                                                setState(() {
                                                  searchedProducts =
                                                      allProducts;
                                                });
                                              }),
                                          hintText: "Search",
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0))),
                                          hintStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),

                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.08,
                    right: 20,
                    child: const CircleAvatar(
                      maxRadius: 25,
                      minRadius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("images/man.png"),
                    ),
                  ),

                  // Product List directly under search bar
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.31,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location info
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Available Products",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.055),
                                  ),
                                  if (isLoading)
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      fullAddress,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Total Products: ${searchedProducts.length}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Product List Widget - Now using our fetched and filtered products
                        Expanded(
                          child: searchedProducts.isEmpty && !isLoading
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        "No products found",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Try searching for something else",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: searchedProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = searchedProducts[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        title: Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              product.formattedPrice,
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              product.formattedQuantity,
                                              style: TextStyle(
                                                color: product.quantity > 0
                                                    ? Colors.blue
                                                    : Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "Store: ${product.storeName}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (product.expire != null)
                                              Text(
                                                product.formattedExpiry,
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            product.category,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ])),
          ),
        );
      },
    );
  }

  // Add this method to fetch all products from Firebase
  Future<void> fetchAllProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collectionGroup('Products').get();

      List<Product> products = [];

      for (var doc in querySnapshot.docs) {
        try {
          // Extract user ID from the document path
          final pathSegments = doc.reference.path.split('/');
          final userId = pathSegments[0]; // First segment should be the user ID

          final product = Product.fromFirestore(
            doc.data(),
            userId,
            doc.id,
          );

          if (product.isValid) {
            products.add(product);
          }
        } catch (e) {
          log('Error parsing product ${doc.id}: $e', name: 'SearchScreen');
          continue;
        }
      }

      setState(() {
        allProducts = products;
        searchedProducts = products; // Initially show all products
        isLoading = false;
      });

      log('Fetched ${products.length} products', name: 'SearchScreen');
    } catch (e) {
      log('Error fetching products: $e', name: 'SearchScreen', error: e);
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add this method to filter products based on search query
  void filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        searchedProducts = allProducts;
      } else {
        searchedProducts = allProducts.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.storeName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );

    // If a product was successfully added, refresh the product list
    if (result == true) {
      // Refresh products from database
      await fetchAllProducts();

      // Show a confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product list refreshed!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> setLocation() async {
    try {
      var position = await FlutterApi().getPosition();
      var address =
          await FlutterApi().getAddress(position.latitude, position.longitude);

      setState(() {
        fullAddress = address;
        userlat = position.latitude;
        userlon = position.longitude;
      });
    } catch (e) {
      log('Error setting location: $e', name: 'SearchScreen', error: e);
      setState(() {
        fullAddress = "Location not available";
      });
    }
  }

  // Search Query for Products
  Future<void> searchQuery(int index) async {
    setState(() {
      status = index;
    });

    if (index == 0) return;

    // nearbyProducts
    try {
      var pos = await FlutterApi().getPosition();
      int radius = 5000000;
      nearbyProducts.clear();

      // filter the products based on the location
      for (var product in allProducts) {
        if (product.storeLocation != null) {
          var distance = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              product.storeLocation!.latitude,
              product.storeLocation!.longitude);
          // Check distance
          if (distance / 1000 < radius) {
            // Add nearby product
            nearbyProducts.add(product);
          }
        }
      }

      setState(() {
        searchedProducts = nearbyProducts;
      });
    } catch (e) {
      log('Error filtering nearby products: $e', name: 'SearchScreen', error: e);
    }
  }
}

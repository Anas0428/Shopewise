import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/firebase_database.dart';
import '../widgets/navbar.dart';
import '../widgets/product_list_widget.dart';
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
  List allProducts = [];
  List nearbyProducts = [];
  List searchedProducts = [];
  late double userlat;
  late double userlon;
  bool status1 = false;
  
  // Key to force ProductListWidget refresh
  Key _productListKey = UniqueKey();

  int status = 0;

  late GlobalKey<ScaffoldState> _scaffoldKey;
  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    setLocation();
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
                                top: MediaQuery.of(context).size.height *
                                    0.02),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          _scaffoldKey.currentState!
                                              .openDrawer();
                                        },
                                        child: const Icon(
                                            Icons.menu_open_sharp,
                                            size: 35,
                                            color: Colors.white))),
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: PopupMenuButton(
                                    icon: const Icon(Icons.more_horiz,
                                        size: 25, color: Colors.white),
                                    itemBuilder: (context) => [],
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
                                        fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.055),
                                  ),
                                  Text(
                                    'Your Medicine!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
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
                                        maxWidth: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.9,
                                        minHeight: 48,
                                      ),
                                      child: TextField(
                                        controller: _searchQuery,
                                        onSubmitted: (value) {},
                                        onChanged: (value) async {
                                          // The search is now handled by ProductListWidget
                                          // This TextField just passes the search query
                                          // The ProductListWidget will handle the filtering internally
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.search),
                                          suffixIcon: IconButton(
                                              icon: const Icon(Icons
                                                  .filter_list_off_outlined),
                                              onPressed: () {}),
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
                              Text(
                                "Available Products",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width * 0.055),
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
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Product List Widget
                        Expanded(
                          child: ProductListWidget(
                            key: _productListKey,
                            searchQuery: _searchQuery.text.isEmpty ? null : _searchQuery.text,
                            onRefresh: () {
                              // Clear search when refreshing
                              _searchQuery.clear();
                              setState(() {
                                searchedProducts = allProducts;
                              });
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

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
    
    // If a product was successfully added, refresh the product list
    if (result == true) {
      // Generate a new key to force ProductListWidget to refresh
      setState(() {
        _productListKey = UniqueKey();
      });
      
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
    var position = await FlutterApi().getPosition();
    var address =
        await FlutterApi().getAddress(position.latitude, position.longitude);

    setState(() {
      fullAddress = address;
      userlat = position.latitude;
      userlon = position.longitude;
    });
  }

  // Search Query for Products
  Future<void> searchQuery(int index) async {
    setState(() {
      status = index;
    });

    if (index == 0) return;

    // nearbyProducts
    var pos = await FlutterApi().getPosition();
    int radius = 5000000;
    nearbyProducts.clear();
    // filter the products based on the location
    for (var element in allProducts) {
      if (element["StoreLocation"] != null) {
        var distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            element["StoreLocation"].latitude,
            element["StoreLocation"].longitude);
        // Check distance
        if (distance / 1000 < radius) {
          // Add nearby product
          nearbyProducts.add(element);
        }
      }
    }
  }
}

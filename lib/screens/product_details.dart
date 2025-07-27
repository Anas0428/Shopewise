import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
// Getting Product from Statefull Widget
  double height = 0, width = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    final product = widget.product;
    double lat = product["StoreLocation"].latitude;
    double lon = product["StoreLocation"].longitude;
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Product Details"),
    //   ),
    //   body: Container(
    //     child: Column(
    //       children: [
    //         Text("Category: ${widget.product["Category"]}}"),
    //         Text("ExpireDate: ${widget.product["ExpireDate"]}} "),
    //         Text("Name: ${widget.product["Name"]}}"),
    //         Text("Price: ${widget.product["Price"]}}"),
    //         Text("ProductId: ${widget.product["ProductId"]}}"),
    //         Text("Quantity: ${widget.product["Quantity"]}}"),
    //         Text("StoreId: ${widget.product["StoreId"]}}"),
    //         Text("StoreLocation: ${widget.product["StoreLocation"]}}"),
    //         Text("StoreName: ${widget.product["StoreName"]}}"),
    //         Text("Type: ${widget.product["Type"]}}"),
    //         ElevatedButton(
    //             onPressed: () {
    //               // Open Google Maps
    //             },
    //             child: ElevatedButton(
    //               onPressed: () {
    //                 // String url = "https://www.google.com/maps/@$lat,${lon},10z";
    //                 Uri uri = Uri(
    //                     scheme: 'https',
    //                     host: 'www.google.com',
    //                     path: '/maps',
    //                     queryParameters: {'q': '$lat,$lon'});
    //                 launchUrl(uri);
    //               },
    //               child: Text("Open Google Maps"),
    //             )),
    //       ],
    //     ),
    //   ),
    // );

    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: height * .3,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                    image: AssetImage('images/plants2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: height * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                    padding: EdgeInsets.all(width * 0.05),
                                    child: Icon(Icons.arrow_back_ios_new_sharp,
                                        size: width * 0.06, color: Colors.white)),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                  padding: EdgeInsets.all(width * 0.03),
                                  child: Icon(Icons.more_horiz,
                                      size: width * 0.06, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Container(
                  height: height * .7,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)))),
            ),
          ],
        ),
        Positioned(
          top: height * 0.25,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Name Section
                Row(
                  children: [
                    const Icon(
                      Icons.storefront,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.product["StoreName"]}',
                        style: const TextStyle(
                            color: Colors.black, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 28),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 2.0),
                
                // Product Name and Price Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.product["Name"]}',
                            style: const TextStyle(
                                color: Colors.black, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${widget.product["Category"]}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${widget.product["Price"]}',
                            style: const TextStyle(
                                color: Colors.red, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            '(Per Unit)',
                            style: TextStyle(
                                color: Colors.red, 
                                fontWeight: FontWeight.normal, 
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 2.0),
                
                // Stock and Expiry Section
                Row(
                  children: [
                    const Icon(
                      Icons.production_quantity_limits,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'In Stock:',
                      style: TextStyle(
                          color: Colors.black, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.product["Quantity"]}',
                      style: const TextStyle(
                          color: Colors.green, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Expire Date:',
                      style: TextStyle(
                          color: Colors.black, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '${widget.product["Expire"]}',
                        style: const TextStyle(
                            color: Colors.red, 
                            fontWeight: FontWeight.normal, 
                            fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 2.0),
                
                // Note Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_add,
                      color: Colors.red,
                      size: 20.0,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Note",
                            style: TextStyle(
                                color: Colors.black, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 18),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Do not use medicine without doctor's prescription.",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Maps Button
                Center(
                  child: Container(
                    width: width * 0.7,
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      minHeight: 48, // Minimum touch target
                    ),
                    child: FloatingActionButton.extended(
                      icon: Icon(Icons.navigation, size: width * 0.05),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      label: Text(
                        "See on Maps",
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        Uri uri = Uri(
                            scheme: 'https',
                            host: 'www.google.com',
                            path: '/maps',
                            queryParameters: {'q': '$lat,$lon'});
                        launchUrl(uri);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    )));
  }
}

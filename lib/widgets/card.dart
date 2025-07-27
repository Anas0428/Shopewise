// Card View Class

import 'package:flutter/material.dart';

import 'package:my_project/screens/product_details.dart';

class CardView extends StatelessWidget {
  final Map<String, dynamic> productList;

  const CardView({
    super.key,
    required this.productList,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.01,
      ),
      height: screenHeight * 0.12,
      width: double.infinity, // Use full available width
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 3))
          ]),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.04),
            child: CircleAvatar(
              radius: screenWidth * 0.05,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage("images/box.png"),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.04,
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${productList['Name']}",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Rs. ${productList["Price"]}',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.normal,
                        fontSize: screenWidth * 0.035),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    'In Stock: ${productList["Quantity"]}',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.normal,
                        fontSize: screenWidth * 0.035),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    '${productList["StoreName"]}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: screenWidth * 0.035),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),

          // Tap Button with forward icon for Product Description, blue color with
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.04),
              child: AspectRatio(
                aspectRatio: 1.0, // Keeps button square
                child: SizedBox(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductDetails(
                                    product:
                                        productList, // sending Product Document to the Product Details Page for showing all the details
                                  )));
                    },
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: screenWidth * 0.045,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}












/*Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      child: Card(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.02,
        ),
        shadowColor: Colors.grey[50],
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.grey[50],
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.01,
              ),
              width: MediaQuery.of(context).size.width * 0.055,
              child: SizedBox(
                child: Text(
                  product['name'],
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width / 100,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              transformAlignment: Alignment.center,
              alignment: Alignment.center,
              child: Text(
                "Id: ${product['id']}",
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  color: Color.fromARGB(255, 74, 135, 249),
                  fontWeight: FontWeight.w100,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.06,
              ),
              transformAlignment: Alignment.center,
              alignment: Alignment.center,
              child: Text(
                'Qty: ' + product['quantity'].toString(),
                style: TextStyle(
                  fontFamily: "Montserrat",
                  color: Color.fromARGB(255, 74, 135, 249),
                  fontWeight: FontWeight.w100,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.06,
              ),
              transformAlignment: Alignment.center,
              alignment: Alignment.center,
              child: Text(
                "Rs. ${product['price']}",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  color: Color.fromARGB(255, 231, 79, 87),
                  fontWeight: FontWeight.w100,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.06,
              ),
              child: Card(
                color: Color.fromARGB(255, 74, 135, 249),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.03,
                  height: MediaQuery.of(context).size.height * 0.03,
                  alignment: Alignment.center,
                  transformAlignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      navigate(context, product["id"]);
                    },
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                        fontSize: MediaQuery.of(context).size.width / 110,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.06,
              ),
              child: Card(
                color: Color.fromARGB(255, 255, 125, 125),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.04,
                  height: MediaQuery.of(context).size.height * 0.03,
                  alignment: Alignment.center,
                  transformAlignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // Delete product
                      var productID = product["id"];
                      // Are you sure?
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Are you sure?"),
                            content: Text("This action cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Delete product
                                  if (await deleteProduct(productID) == true) {
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Product deleted, "),
                                      ),
                                    );
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Product()));
                                  }
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                        fontSize: MediaQuery.of(context).size.width / 110,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );*/
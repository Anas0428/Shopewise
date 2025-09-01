// ignore_for_file: avoid_print, camel_case_types, non_constant_identifier_names
// ignore_for_file: constant_identifier_names
// import 'dart:convert';
// import 'package:alert/alert.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'local_auth.dart';
import 'firestore_service.dart';

const api_key = "AIzaSyAeAuqTXFXec3UHa6NFLC9GHaD4IK7RXUg";
const project_id = "searchaholic-86248";
// const api_key = "AIzaSyCjZK5ojHcJQh8Sr0sdMG0Nlnga4D94FME";
// const project_id = "shopwise-86248";

class FlutterApi {
  // Note: Firestore is now initialized in main.dart using FirestoreService.initialize()
  // No need to call old Firestore.initialize() anymore

  // checking login of members - Local credentials checked first, then Firebase
  Future<bool> check_login(String email, String password) async {
    // First, check local credentials
    bool isLocalAuth =
        await LocalAuthService.checkLocalCredentials(email, password);
    if (isLocalAuth) {
      print("Local authentication successful for: $email");
      return Future<bool>.value(true);
    }

    // If local auth fails, proceed with Firebase authentication
    print("Local authentication failed, trying Firebase authentication...");

    // Getting the User Document using modern Firestore API
    try {
      final doc = await FirestoreService.getDocument("appData", email);
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['password'] == password && data['email'] == email) {
          print("Firebase authentication successful for: $email");
          return Future<bool>.value(true);
        } else {
          print("Firebase authentication failed for: $email");
          return Future<bool>.value(false);
        }
      } else {
        print("User not found in Firebase: $email");
        return Future<bool>.value(false);
      }
    } catch (e) {
      print("Firebase authentication error: $e");
      return Future<bool>.value(false);
    }
  }

  // Registration
  Future<bool> register(
      String email, String storeName, String phNo, String password) async {
    try {
      // Checking if the email is already registered
      if (await FirestoreService.documentExists("appData", email)) {
        return Future<bool>.value(false);
      } else {
        // Creating a new document with the email using modern API
        await FirestoreService.setDocument("appData", email, {
          'email': email,
          'name': storeName,
          'phNo': phNo,
          'password': password,
        });
        return Future<bool>.value(true);
      }
    } catch (e) {
      print("Registration error: $e");
      return Future<bool>.value(false);
    }
  }

  // Getting Current Location

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Getting the Address from the Location
  Future<String> getAddress(lat, lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
    Placemark place = placemarks[0];
    String address = "${place.locality}, ${place.country}";
    return address;
  }

  Future<List> getAllProducts() async {
    try {
      print("🔄 FlutterApi: Getting all products from nested structure...");
      
      // Get all user documents from Products collection
      final userSnapshot = await FirestoreService.getCollection("Products");
      final allProducts = <Map<String, dynamic>>[];

      print("📁 FlutterApi: Found ${userSnapshot.docs.length} user documents");

      // Loop through each user document
      for (var userDoc in userSnapshot.docs) {
        try {
          // Get the products subcollection for this user
          final productsSubcollection = userDoc.reference.collection('products');
          final productsSnapshot = await productsSubcollection.get();

          print("👤 FlutterApi: User ${userDoc.id}: Found ${productsSnapshot.docs.length} products");

          // Add each product to the main list
          for (var productDoc in productsSnapshot.docs) {
            final data = productDoc.data();
            data['id'] = productDoc.id; // Add product document ID
            data['userId'] = userDoc.id; // Add user ID for reference
            allProducts.add(data);
          }
        } catch (e) {
          print("⚠️ FlutterApi: Error getting products for user ${userDoc.id}: $e");
          // Continue with other users even if one fails
        }
      }

      print("✅ FlutterApi: Retrieved total of ${allProducts.length} products");
      return Future<List>.value(allProducts);
    } catch (e) {
      print("❌ FlutterApi: Error getting all products: $e");
      return Future<List>.value([]);
    }
  }

  Future<void> searchQuery(
      String query, double latitude, double longitude) async {
    try {
      // Getting the products with productName and within 10 km radius
      final querySnapshot = await FirestoreService.getCollection("Products");

      for (var doc in querySnapshot.docs) {
        final product = doc.data() as Map<String, dynamic>;
        // Checking if the product name contains the query
        if (product['Name']
                ?.toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ==
            true) {
          print(product['Name']);
        }
      }
    } catch (e) {
      print("Error in searchQuery: $e");
    }
  }

  Future<DocumentSnapshot?> getStorePosition(String storeEmail) async {
    try {
      var storeDetails =
          await FirestoreService.getDocument(storeEmail, "Store Details");
      return storeDetails;
    } catch (e) {
      print("Error getting store position: $e");
      return null;
    }
  }

  String getGoogleMapsLink(lattitude, longitude) {
    return "http://www.google.com/maps/place/$lattitude,$longitude";
  }
}

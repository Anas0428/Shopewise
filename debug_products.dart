import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await debugProductData();
}

Future<void> debugProductData() async {
  final firestore = FirebaseFirestore.instance;
  
  debugPrint('🔍 Starting Firebase product data debug...\n');
  
  try {
    // Check both collection names
    await checkCollection(firestore, 'products');
    await checkCollection(firestore, 'Products');
    
    // Check if there are any other collections
    debugPrint('\n📚 Checking all collections in the database...');
    // Note: listCollections() requires admin SDK, so we'll check common names
    final commonNames = ['product', 'PRODUCTS', 'Items', 'items', 'medicines', 'Medicines'];
    for (String name in commonNames) {
      await checkCollection(firestore, name);
    }
    
  } catch (e) {
    debugPrint('❌ Error during debug: $e');
  }
}

Future<void> checkCollection(FirebaseFirestore firestore, String collectionName) async {
  try {
    debugPrint('📋 Checking collection: "$collectionName"');
    
    final snapshot = await firestore.collection(collectionName).limit(5).get();
    
    if (snapshot.docs.isEmpty) {
      debugPrint('   ➜ Collection "$collectionName" is empty or doesn\'t exist');
      return;
    }
    
    debugPrint('   ➜ Found ${snapshot.docs.length} documents (showing first 5)');
    
    for (int i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      final data = doc.data();
      debugPrint('   Document ${i + 1} (ID: ${doc.id}):');
      
      // Print all fields
      data.forEach((key, value) {
        String valueStr;
        if (value is GeoPoint) {
          valueStr = 'GeoPoint(lat: ${value.latitude}, lng: ${value.longitude})';
        } else if (value is Timestamp) {
          valueStr = 'Timestamp(${value.toDate()})';
        } else {
          valueStr = value.toString();
        }
        debugPrint('     $key: $valueStr');
      });
      debugPrint('');
    }
    
    // Check field consistency
    if (snapshot.docs.isNotEmpty) {
      final firstDoc = snapshot.docs.first.data();
      debugPrint('   🔍 Field Analysis:');
      
      // Check critical fields
      final criticalFields = ['Name', 'name', 'Price', 'price', 'Category', 'category', 
                             'Quantity', 'quantity', 'StoreLocation', 'StoreId', 'StoreName'];
      
      for (String field in criticalFields) {
        if (firstDoc.containsKey(field)) {
          debugPrint('     ✅ Found field: $field (type: ${firstDoc[field].runtimeType})');
        }
      }
      
      // List all actual fields
      debugPrint('     📝 All fields in first document:');
      for (String key in firstDoc.keys) {
        debugPrint('       - $key');
      }
    }
    
  } catch (e) {
    debugPrint('   ❌ Error checking collection "$collectionName": $e');
  }
  
  debugPrint('');
}

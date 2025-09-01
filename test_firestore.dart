// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
    
    // Initialize Firestore Service
    FirestoreService.initialize();
    
    // Test getting all products to see debug output
    debugPrint('🔍 Testing getAllProductsList() to identify sub-collection names...');
    final products = await FirestoreService.getAllProductsList();
    
    debugPrint('📊 Total products found: ${products.length}');
    
    if (products.isNotEmpty) {
      debugPrint('📝 Sample product structure:');
      debugPrint(products.first.toString());
    }
    
  } catch (e) {
    debugPrint('❌ Error during test: $e');
  }
}

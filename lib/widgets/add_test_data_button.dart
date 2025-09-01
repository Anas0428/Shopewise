import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddTestDataButton extends StatefulWidget {
  const AddTestDataButton({super.key});

  @override
  State<AddTestDataButton> createState() => _AddTestDataButtonState();
}

class _AddTestDataButtonState extends State<AddTestDataButton> {
  bool _isLoading = false;

  Future<void> _addTestData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add test products
      final testProducts = [
        {
          'Name': 'Paracetamol 500mg',
          'price': 25.5,
          'category': 'Pain Relief',
          'description': 'Effective pain relief and fever reducer',
          'inStock': true,
          'manufacturer': 'PharmaCorp',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'Name': 'Vitamin D3 Tablets',
          'price': 18.9,
          'category': 'Vitamins',
          'description': 'Essential vitamin D supplement',
          'inStock': true,
          'manufacturer': 'VitaHealth',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'Name': 'Aspirin 100mg',
          'price': 12.5,
          'category': 'Pain Relief',
          'description': 'Low-dose aspirin for cardiovascular health',
          'inStock': true,
          'manufacturer': 'CardioMed',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ];

      for (final product in testProducts) {
        await FirestoreService.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test data added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error adding test data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _addTestData,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add_box),
      label: Text(_isLoading ? 'Adding...' : 'Add Test Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

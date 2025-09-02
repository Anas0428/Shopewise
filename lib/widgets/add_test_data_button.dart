import 'package:flutter/material.dart';
import '../utils/migration_helper.dart';

class AddTestDataButton extends StatefulWidget {
  const AddTestDataButton({super.key});

  @override
  State<AddTestDataButton> createState() => _AddTestDataButtonState();
}

class _AddTestDataButtonState extends State<AddTestDataButton> {
  bool _isLoading = false;

  Future<void> _showMigrationOptions() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Centralized Products Migration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Create Sample Products Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _createSampleProducts();
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Create Sample Products'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Migrate from Old Structure Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _migrateFromOldStructure();
              },
              icon: const Icon(Icons.transform),
              label: const Text('Migrate from Old Structure'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Verify Migration Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _verifyMigration();
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Verify Migration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Note: Sample products will be added to the new centralized "products" collection.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSampleProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await MigrationHelper.createSampleProducts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample products created in centralized collection!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error creating sample products: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _migrateFromOldStructure() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Migrate Data'),
        content: const Text(
          'This will migrate products from the old nested structure '
          '(Products/{userId}/products/{productId}) to the new centralized '
          'collection (products/{productId}).\n\n'
          'This process will not delete your old data.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Migrate'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await MigrationHelper.migrateFromNestedStructure();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Migration completed! Check console for details.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Migration error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _verifyMigration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await MigrationHelper.verifyMigration();
      
      if (mounted && !stats.containsKey('error')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Migration Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Products: ${stats['totalProducts']}'),
                Text('Active Products: ${stats['activeProducts']}'),
                Text('Migrated Products: ${stats['migratedProducts']}'),
                Text('Sample Products: ${stats['sampleProducts']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Verification error: ${stats['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Verification error: $e'),
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
      onPressed: _isLoading ? null : _showMigrationOptions,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.settings_backup_restore),
      label: Text(_isLoading ? 'Working...' : 'Migration Tools'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../helpers/sample_data.dart';
import '../widgets/add_test_data_button.dart';

class DebugFirebaseScreen extends StatefulWidget {
  const DebugFirebaseScreen({super.key});

  @override
  State<DebugFirebaseScreen> createState() => _DebugFirebaseScreenState();
}

class _DebugFirebaseScreenState extends State<DebugFirebaseScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Ready';
  Map<String, int>? _dbStats;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking Firebase connection...';
    });

    try {
      final isConnected = await FirestoreService.checkConnection();
      setState(() {
        _isConnected = isConnected;
        _statusMessage = isConnected
            ? '✅ Connected to Firebase'
            : '❌ Not connected to Firebase';
      });

      if (isConnected) {
        await _loadStats();
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Connection error: $e';
        _isConnected = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await FirestoreService.getDatabaseStats();
      setState(() {
        _dbStats = stats;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error loading stats: $e';
      });
    }
  }

  Future<void> _addSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Adding sample data...';
    });

    try {
      await SampleDataHelper.addSampleProducts();
      setState(() {
        _statusMessage = '✅ Sample data added successfully!';
      });
      await _loadStats();
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error adding sample data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSearch() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing search functionality...';
    });

    try {
      await SampleDataHelper.testSearchFunctionality();
      setState(() {
        _statusMessage = '✅ Search tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error during search tests: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Warning'),
        content: const Text(
            'This will delete ALL products from Firebase. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing all data...';
    });

    try {
      await FirestoreService.deleteAllProducts();
      setState(() {
        _statusMessage = '✅ All data cleared successfully!';
        _dbStats = null;
      });
      await _loadStats();
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error clearing data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug Console'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkConnection,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              elevation: 4,
              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _isConnected ? Icons.cloud_done : Icons.cloud_off,
                      size: 48,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isConnected
                          ? 'Firebase Connected'
                          : 'Firebase Disconnected',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Database Statistics
            if (_dbStats != null) ...[
              const Text(
                'Database Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Products',
                    _dbStats!['totalProducts'].toString(),
                    Icons.inventory,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'In Stock',
                    _dbStats!['inStockProducts'].toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Out of Stock',
                    _dbStats!['outOfStockProducts'].toString(),
                    Icons.remove_circle,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Connection',
                    _isConnected ? 'Online' : 'Offline',
                    _isConnected ? Icons.wifi : Icons.wifi_off,
                    _isConnected ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            const Text(
              'Firebase Operations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addSampleData,
              icon: const Icon(Icons.add_box),
              label: const Text('Add Sample Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            const AddTestDataButton(),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testSearch,
              icon: const Icon(Icons.search),
              label: const Text('Test Search Functions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkConnection,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Danger Zone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'These operations cannot be undone. Use with caution.',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

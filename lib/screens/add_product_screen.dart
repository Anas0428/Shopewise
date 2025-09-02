import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeEmailController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _manufacturerController = TextEditingController();

  DateTime? _selectedExpiryDate;
  bool _isLoading = false;

  final List<String> _categories = [
    'Medicine',
    'Tablets',
    'Syrup',
    'Injection',
    'Capsules',
    'Ointment',
    'Drops',
    'Vitamins',
    'Supplements',
    'First Aid',
    'Other'
  ];

  final List<String> _types = [
    'Prescription',
    'Over-the-counter',
    'Generic',
    'Brand',
    'Ayurvedic',
    'Homeopathic'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _storeNameController.dispose();
    _storeEmailController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      helpText: 'Select Expiry Date',
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a unique store ID for this product
      const storeId = 'store_demo_001'; // In a real app, this would come from authentication
      
      log('AddProductScreen: Using storeId = $storeId', name: 'AddProductScreen');
      
      // Create product data for centralized collection
      final productData = <String, dynamic>{
        'Name': _nameController.text.trim(),
        'Price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'Quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
        'Category': _categoryController.text.trim(),
        'Type': _typeController.text.trim(),
        'StoreName': _storeNameController.text.trim(),
        'StoreId': storeId,
        'isActive': true,
      };
      
      // Add optional fields if they have values
      if (_storeEmailController.text.trim().isNotEmpty) {
        productData['storeEmail'] = _storeEmailController.text.trim();
      }
      if (_descriptionController.text.trim().isNotEmpty) {
        productData['description'] = _descriptionController.text.trim();
      }
      if (_manufacturerController.text.trim().isNotEmpty) {
        productData['manufacturer'] = _manufacturerController.text.trim();
      }
      if (_selectedExpiryDate != null) {
        productData['Expire'] = Timestamp.fromDate(_selectedExpiryDate!);
      }
      
      log('AddProductScreen: Raw product data before saving:', name: 'AddProductScreen');
      productData.forEach((key, value) {
        log('  $key: $value (${value.runtimeType})', name: 'AddProductScreen');
      });
      
      log('AddProductScreen: Product data to save: ${productData.toString()}', name: 'AddProductScreen');

      // Save to centralized Firestore collection
      final productId = await FirestoreService.addProduct(productData);
      
      log('AddProductScreen: Product saved with ID: $productId', name: 'AddProductScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added to global collection successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      log('AddProductScreen: Error saving product: $e', name: 'AddProductScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Add New Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProduct,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving product...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_box,
                              size: 48,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add New Product',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fill in the details below to add a product',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Product Information Section
                    _buildSectionCard(
                      title: 'Product Information',
                      icon: Icons.inventory,
                      children: [
                        _buildTextFormField(
                          controller: _nameController,
                          label: 'Product Name *',
                          hint: 'e.g., Paracetamol, Aspirin',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Product name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          controller: _categoryController,
                          label: 'Category *',
                          hint: 'Select category',
                          items: _categories,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Category is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          controller: _typeController,
                          label: 'Type *',
                          hint: 'Select type',
                          items: _types,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Type is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _manufacturerController,
                          label: 'Manufacturer',
                          hint: 'e.g., GSK, Pfizer',
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Brief description of the product',
                          maxLines: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Pricing and Inventory Section
                    _buildSectionCard(
                      title: 'Pricing & Inventory',
                      icon: Icons.attach_money,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _priceController,
                                label: 'Price (Rs.) *',
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Price is required';
                                  }
                                  if (double.tryParse(value.trim()) == null) {
                                    return 'Enter valid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _quantityController,
                                label: 'Quantity *',
                                hint: '0',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Quantity is required';
                                  }
                                  if (int.tryParse(value.trim()) == null) {
                                    return 'Enter valid quantity';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(
                          label: 'Expiry Date',
                          selectedDate: _selectedExpiryDate,
                          onTap: _selectExpiryDate,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Store Information Section
                    _buildSectionCard(
                      title: 'Store Information',
                      icon: Icons.store,
                      children: [
                        _buildTextFormField(
                          controller: _storeNameController,
                          label: 'Store Name *',
                          hint: 'e.g., City Medical Store',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Store name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _storeEmailController,
                          label: 'Store Email',
                          hint: 'store@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && 
                                value.trim().isNotEmpty && 
                                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Enter valid email address';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Required fields note
                    Text(
                      '* Required fields',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          controller.text = newValue ?? '';
        });
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null ? Colors.black : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String category;
  final DateTime? expire;
  final String productId;
  final String storeId;
  final String storeName;
  final String storeEmail;
  final GeoPoint? storeLocation;
  final String type;
  final String userId;
  final String documentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    this.expire,
    required this.productId,
    required this.storeId,
    required this.storeName,
    this.storeEmail = '',
    this.storeLocation,
    required this.type,
    required this.userId,
    required this.documentId,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create a Product from Firestore data
  factory Product.fromFirestore(
      Map<String, dynamic> data, String userId, String documentId) {
    // Parse price with fallback to 0
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    // Parse quantity with fallback to 0
    int parseQuantity(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value.replaceAll(RegExp(r'[^\d]'), ''));
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    // Parse expire date
    DateTime? parseExpire(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return Product(
      id: data['ProductID'] ?? data['productId'] ?? data['id'] ?? documentId,
      name: data['Name'] ??
          data['name'] ??
          data['productName'] ??
          'Unknown Product',
      price: parsePrice(data['Price'] ?? data['price'] ?? data['cost']),
      quantity:
          parseQuantity(data['Quantity'] ?? data['quantity'] ?? data['stock']),
      category: data['Category'] ?? data['category'] ?? 'Uncategorized',
      expire:
          parseExpire(data['Expire'] ?? data['expire'] ?? data['expiryDate']),
      productId: data['ProductID'] ?? data['productId'] ?? documentId,
      storeId: data['StoreId'] ?? data['storeId'] ?? userId,
      storeName: data['StoreName'] ??
          data['storeName'] ??
          data['store'] ??
          'Unknown Store',
      storeEmail:
          data['storeEmail'] ?? data['store_email'] ?? data['email'] ?? '',
      storeLocation: data['StoreLocation'] ?? data['storeLocation'],
      type: data['Type'] ?? data['type'] ?? 'Unknown',
      userId: userId,
      documentId: documentId,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Product to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'ProductID': productId,
      'Name': name,
      'Price': price,
      'Quantity': quantity,
      'Category': category,
      'Expire': expire,
      'StoreId': storeId,
      'StoreName': storeName,
      'storeEmail': storeEmail,
      'StoreLocation': storeLocation,
      'Type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Check if this product looks like valid product data
  bool get isValid {
    return name.isNotEmpty &&
        name != 'Unknown Product' &&
        (price > 0 || quantity > 0);
  }

  /// Get formatted price string
  String get formattedPrice {
    return 'Rs. ${price.toStringAsFixed(0)}';
  }

  /// Get formatted quantity string
  String get formattedQuantity {
    return quantity > 0 ? 'In Stock: $quantity' : 'Out of Stock';
  }

  /// Get formatted expiry date
  String get formattedExpiry {
    if (expire == null) return '';
    return 'Expires: ${expire!.year}-${expire!.month.toString().padLeft(2, '0')}-${expire!.day.toString().padLeft(2, '0')}';
  }

  /// Get store location coordinates if available
  Map<String, double>? get locationCoordinates {
    if (storeLocation == null) return null;
    return {
      'latitude': storeLocation!.latitude,
      'longitude': storeLocation!.longitude,
    };
  }

  /// Copy with modifications
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? category,
    DateTime? expire,
    String? productId,
    String? storeId,
    String? storeName,
    String? storeEmail,
    GeoPoint? storeLocation,
    String? type,
    String? userId,
    String? documentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      expire: expire ?? this.expire,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeEmail: storeEmail ?? this.storeEmail,
      storeLocation: storeLocation ?? this.storeLocation,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      documentId: documentId ?? this.documentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, quantity: $quantity, category: $category, store: $storeName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.documentId == documentId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ documentId.hashCode ^ userId.hashCode;
  }
}

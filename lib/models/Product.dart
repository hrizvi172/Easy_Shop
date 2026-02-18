import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final List<dynamic> images;
  final List<dynamic> colors;
  final int price;
  final String? description;
  final String? category;
  final double? rating;
  final int? stock;
  final String? brand;
  final double? discountPercentage;
  final String? thumbnail;

  Product({
    required this.id,
    required this.images,
    required this.colors,
    required this.title,
    required this.price,
    this.description,
    this.category,
    this.rating,
    this.stock,
    this.brand,
    this.discountPercentage,
    this.thumbnail,
  });

  // Factory constructor for Firebase data (existing format)
  factory Product.fromFirebase({
    required String id,
    required List<dynamic> images,
    required List<dynamic> colors,
    required String title,
    required int price,
  }) {
    return Product(
      id: id,
      images: images,
      colors: colors,
      title: title,
      price: price,
    );
  }

  // Factory constructor for DummyJSON API data
  factory Product.fromDummyJson(Map<String, dynamic> json) {
    // DummyJSON returns price as double, convert to int
    int priceInt = (json['price'] as num).round();

    // DummyJSON returns array of images
    List<dynamic> imagesList = json['images'] ?? [json['thumbnail']];

    // Generate colors based on category or use defaults
    List<dynamic> colorsList = _generateColors(json['category']);

    return Product(
      id: json['id'].toString(),
      title: json['title'] ?? 'Unknown Product',
      images: imagesList,
      colors: colorsList,
      price: priceInt,
      description: json['description'],
      category: json['category'],
      rating: (json['rating'] as num?)?.toDouble(),
      stock: json['stock'],
      brand: json['brand'],
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      thumbnail: json['thumbnail'],
    );
  }

  // Helper method to generate colors based on category
  static List<dynamic> _generateColors(String? category) {
    if (category == null) {
      return [
        const Color(0xFF000000), // Black
        const Color(0xFFFFFFFF), // White
        const Color(0xFF808080), // Gray
      ];
    }

    String lowerCategory = category.toLowerCase();

    // Clothing categories get fashion colors
    if (lowerCategory.contains('shirt') ||
        lowerCategory.contains('dress') ||
        lowerCategory.contains('top')) {
      return [
        const Color(0xFF000000), // Black
        const Color(0xFFFFFFFF), // White
        const Color(0xFF0000FF), // Blue
        const Color(0xFFFF0000), // Red
      ];
    }

    // Electronics get tech colors
    if (lowerCategory.contains('phone') ||
        lowerCategory.contains('laptop') ||
        lowerCategory.contains('tablet')) {
      return [
        const Color(0xFF000000), // Black
        const Color(0xFFFFFFFF), // White
        const Color(0xFF808080), // Gray
        const Color(0xFFC0C0C0), // Silver
      ];
    }

    // Beauty products get vibrant colors
    if (lowerCategory.contains('beauty') ||
        lowerCategory.contains('fragrance')) {
      return [
        const Color(0xFFFF69B4), // Pink
        const Color(0xFFFFD700), // Gold
        const Color(0xFF9370DB), // Purple
      ];
    }

    // Default colors
    return [
      const Color(0xFF000000), // Black
      const Color(0xFFFFFFFF), // White
      const Color(0xFF808080), // Gray
    ];
  }

  // Check if this product needs size selector
  bool needsSizeSelector() {
    if (category == null) return false;

    String lowerCategory = category!.toLowerCase();

    // Clothing items need size selector
    final clothingKeywords = [
      'shirt',
      'dress',
      'top',
      'pant',
      'jean',
      'jacket',
      'coat',
      'sweater',
      'hoodie',
      'clothing',
      'wear',
    ];

    return clothingKeywords.any((keyword) => lowerCategory.contains(keyword));
  }

  // Check if this product is shoes (different size options)
  bool isShoesProduct() {
    if (category == null) return false;

    String lowerCategory = category!.toLowerCase();
    final shoesKeywords = ['shoe', 'sneaker', 'boot', 'sandal', 'footwear'];

    return shoesKeywords.any((keyword) => lowerCategory.contains(keyword));
  }

  // Convert to Map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Title': title,
      'images': images,
      'Colors': colors,
      'Price': price,
      'description': description,
      'category': category,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'discountPercentage': discountPercentage,
    };
  }
}

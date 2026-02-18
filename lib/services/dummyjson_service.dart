import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Product.dart';

class DummyJsonService {
  static const String baseUrl = 'https://dummyjson.com';

  // Get all products with pagination
  static Future<List<Product>> getAllProducts({int limit = 0}) async {
    try {
      String url = limit > 0
          ? '$baseUrl/products?limit=$limit'
          : '$baseUrl/products?limit=0';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> products = data['products'];
        return products.map((json) => Product.fromDummyJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Get all categories
  static Future<List<String>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // DummyJSON returns category objects with slug and name
        List<String> categories = [];
        for (var item in data) {
          if (item is Map && item.containsKey('name')) {
            categories.add(item['name'].toString());
          } else if (item is String) {
            categories.add(_formatCategoryName(item));
          }
        }

        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      // Convert category to API format (slug)
      String apiCategory = _categoryToApiFormat(category);
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$apiCategory'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> products = data['products'];
        return products.map((json) => Product.fromDummyJson(json)).toList();
      } else {
        throw Exception('Failed to load products for category: $category');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  // Get single product by ID
  static Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Product.fromDummyJson(data);
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$query'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> products = data['products'];
        return products.map((json) => Product.fromDummyJson(json)).toList();
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Helper function to format category names for display
  static String _formatCategoryName(String category) {
    if (category.isEmpty) return category;

    // Split by hyphen and capitalize each word
    List<String> words = category.split('-');
    String formatted = words
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');

    return formatted;
  }

  // Helper function to convert display category back to API format (slug)
  static String _categoryToApiFormat(String category) {
    // Convert "Beauty" to "beauty", "Mens Shirts" to "mens-shirts"
    return category.toLowerCase().replaceAll(' ', '-');
  }

  // Check if category is clothing-related (for size selector)
  static bool isClothingCategory(String category) {
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
      'apparel',
      'wear',
      'fashion',
      'mens',
      'womens',
    ];

    String lowerCategory = category.toLowerCase();
    return clothingKeywords.any((keyword) => lowerCategory.contains(keyword));
  }

  // Check if category is shoes-related
  static bool isShoesCategory(String category) {
    final shoesKeywords = ['shoe', 'sneaker', 'boot', 'sandal', 'footwear'];
    String lowerCategory = category.toLowerCase();
    return shoesKeywords.any((keyword) => lowerCategory.contains(keyword));
  }
}

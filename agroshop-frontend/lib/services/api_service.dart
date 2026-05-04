import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_constants.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/cart_item.dart';

class ApiService {
  // Fungsi general untuk menangani respons dari Dosen
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedJson = jsonDecode(response.body);
      
      // Mengekstrak struktur wajib dari backend
      final bool success = decodedJson['success'] ?? false;
      final data = decodedJson['data'];

      if (success) {
        return data; // Hanya kembalikan isian 'data' agar model Flutter aman
      } else {
        throw Exception(decodedJson['message'] ?? 'API Error without message');
      }
    } else {
      throw Exception('Failed to connect to API. Status code: ${response.statusCode}');
    }
  }

  // --- AUTHENTICATION & TOKEN MANAGEMENT --- //

  static const String _tokenKey = 'jwt_token';

  // Fungsi menyimpan token ke memori internal HP
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Fungsi mengambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Fungsi Login
  static Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final decodedJson = jsonDecode(response.body);

      // Karena API Login ini tidak pakai format wrapper dosen, 
      // kita gunakan pengecekan statusCode HTTP bawaan
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ambil token dan user langsung dari root JSON
        final String token = decodedJson['token'];
        final Map<String, dynamic> userData = decodedJson['user'];

        // Simpan token ke SharedPreferences
        await saveToken(token);

        // Kembalikan model User
        return User.fromJson(userData);
      } else {
        // Jika gagal (misal password salah), ambil pesan error-nya
        throw Exception(decodedJson['message'] ?? 'Login gagal');
      }
    } catch (e) {
      debugPrint('Error Login API: $e');
      rethrow; 
    }
  }

  // --- HELPER UNTUK TOKEN BEARER --- //
  
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Memasukkan token secara otomatis
    };
  }

  // --- CART ENDPOINTS --- //

  // Fungsi Tambah ke Keranjang (POST /cart)
  static Future<void> addToCart(int productId, int quantity) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/cart'),
        headers: headers,
        // HANYA mengirimkan productId dan quantity sesuai instruksi backend!
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      // Kita pakai _processResponse karena biasanya endpoint ini pakai format standar dosen
      _processResponse(response); 
    } catch (e) {
      debugPrint('Error addToCart: $e');
      rethrow;
    }
  }

  // Mengambil isi keranjang (GET /cart)
  static Future<List<CartItem>> getCart() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/cart'),
        headers: headers,
      );
      
      // LOG DEBUG: Cek isi token dan respon asli di Debug Console VS Code
      debugPrint('Token used: ${headers['Authorization']}');
      debugPrint('Raw Cart Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);

        // Skenario 1: Backend langsung mengembalikan List [{}, {}]
        if (decodedJson is List) {
          return decodedJson.map((json) => CartItem.fromJson(json)).toList();
        }

        // Skenario 2: Menggunakan format dosen (data: [{}, {}])
        if (decodedJson is Map && decodedJson.containsKey('data')) {
          final data = decodedJson['data'];
          if (data is List) {
            return data.map((json) => CartItem.fromJson(json)).toList();
          }
        }

        // Skenario 3: NestJS mengembalikan objek dengan key 'items'
        if (decodedJson is Map && decodedJson.containsKey('items')) {
          final items = decodedJson['items'];
          if (items is List) {
            return items.map((json) => CartItem.fromJson(json)).toList();
          }
        }

        return []; // Default jika format tidak dikenali
      } else {
        debugPrint('Cart API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getCart Exception: $e');
      return [];
    }
  }

  // Mengubah quantity (PATCH /cart/:id)
  // Asumsi: endpoint backend membutuhkan id dari CartItem, bukan Product
  static Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/cart/$cartItemId'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error updateCartItemQuantity: $e');
      rethrow;
    }
  }

  // Menghapus satu item dari keranjang (DELETE /cart/:id)
  static Future<void> removeCartItem(int cartItemId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/cart/$cartItemId'),
        headers: headers,
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error removeCartItem: $e');
      rethrow;
    }
  }

  // Mengosongkan keranjang (DELETE /cart)
  static Future<void> clearCart() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/cart'),
        headers: headers,
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error clearCart: $e');
      rethrow;
    }
  }

  // --- PUBLIC ENDPOINTS --- //
  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}${AppConstants.endpointCategories}'));
      final data = _processResponse(response);
      
      return (data as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getCategories: $e');
      return []; // Return list kosong jika gagal agar aplikasi tidak crash
    }
  }

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}${AppConstants.endpointProducts}'));
      final data = _processResponse(response);
      
      return (data as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getCategories: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getBanners() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}${AppConstants.endpointBanners}'));
      final data = _processResponse(response);
      return data as List; // Karena belum ada Banner.dart, kita gunakan dynamic list dulu
    } catch (e) {
      debugPrint('Error getCategories: $e');
      return [];
    }
  }
}

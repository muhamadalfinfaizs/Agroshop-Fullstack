import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_constants.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/shipment.dart';

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

  // Fungsi Register
  static Future<void> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      final decodedJson = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(decodedJson['message'] ?? 'Gagal melakukan pendaftaran');
      }
    } catch (e) {
      debugPrint('Error Register API: $e');
      rethrow;
    }
  }

  // Fungsi mengambil profile user dari /auth/profile
  static Future<User> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/profile'),
        headers: headers,
      );

      final decodedJson = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> userData = decodedJson['user'];
        return User.fromJson(userData);
      } else {
        throw Exception(decodedJson['message'] ?? 'Gagal memuat profil');
      }
    } catch (e) {
      debugPrint('Error getProfile API: $e');
      rethrow;
    }
  }

  // Fungsi update profile
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/auth/profile'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      final decodedJson = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(decodedJson['message'] ?? 'Gagal update profil');
      }
    } catch (e) {
      debugPrint('Error updateProfile API: $e');
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

  // --- ADDRESS ENDPOINTS --- //

  static Future<List<Address>> getAddresses() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/addresses'),
        headers: headers,
      );
      final data = _processResponse(response);
      return (data as List).map((json) => Address.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getAddresses: $e');
      return [];
    }
  }

  static Future<void> addAddress(Map<String, dynamic> data) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/addresses'),
        headers: headers,
        body: jsonEncode(data),
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error addAddress: $e');
      rethrow;
    }
  }

  static Future<void> updateAddress(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/addresses/$id'),
        headers: headers,
        body: jsonEncode(data),
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error updateAddress: $e');
      rethrow;
    }
  }

  static Future<void> setDefaultAddress(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${AppConstants.baseUrl}/addresses/$id/default'),
        headers: headers,
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error setDefaultAddress: $e');
      rethrow;
    }
  }

  static Future<void> deleteAddress(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/addresses/$id'),
        headers: headers,
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error deleteAddress: $e');
      rethrow;
    }
  }

  // --- CART ENDPOINTS --- //

  static final ValueNotifier<int> cartBadgeCount = ValueNotifier<int>(0);

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
      // Refresh badge count
      getCart();
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
          final list = decodedJson.map((json) => CartItem.fromJson(json)).toList();
          cartBadgeCount.value = list.length;
          return list;
        }

        // Skenario 2: Menggunakan format dosen (data: [{}, {}])
        if (decodedJson is Map && decodedJson.containsKey('data')) {
          final data = decodedJson['data'];
          if (data is List) {
            final list = data.map((json) => CartItem.fromJson(json)).toList();
            cartBadgeCount.value = list.length;
            return list;
          }
        }

        // Skenario 3: NestJS mengembalikan objek dengan key 'items'
        if (decodedJson is Map && decodedJson.containsKey('items')) {
          final items = decodedJson['items'];
          if (items is List) {
            final list = items.map((json) => CartItem.fromJson(json)).toList();
            cartBadgeCount.value = list.length;
            return list;
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
      getCart();
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
      cartBadgeCount.value = 0;
    } catch (e) {
      debugPrint('Error clearCart: $e');
      rethrow;
    }
  }

  // --- ORDER & CHECKOUT ENDPOINTS --- //

  static Future<void> checkout(int addressId, {List<int>? cartItemIds}) async {
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{'addressId': addressId};
      if (cartItemIds != null && cartItemIds.isNotEmpty) {
        body['cartItemIds'] = cartItemIds;
      }
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/orders/checkout'),
        headers: headers,
        body: jsonEncode(body),
      );
      _processResponse(response);
    } catch (e) {
      debugPrint('Error checkout: $e');
      rethrow;
    }
  }

  static Future<List<Order>> getOrders() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/orders'),
        headers: headers,
      );
      final data = _processResponse(response);
      return (data as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getOrders: $e');
      return [];
    }
  }

  // --- SHIPMENT ENDPOINTS --- //

  static Future<Shipment?> getShipment(String orderCode) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/shipments/orders/$orderCode'),
        headers: headers,
      );
      final data = _processResponse(response);
      return Shipment.fromJson(data);
    } catch (e) {
      debugPrint('Error getShipment: $e');
      return null;
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

  static Future<List<Product>> getProducts({String? search}) async {
    try {
      final url = search != null && search.isNotEmpty 
          ? '${AppConstants.baseUrl}${AppConstants.endpointProducts}?search=$search' 
          : '${AppConstants.baseUrl}${AppConstants.endpointProducts}';
      final response = await http.get(Uri.parse(url));
      final data = _processResponse(response);
      
      return (data as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getProducts: $e');
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

/// Model untuk User sesuai skema backend NestJS
class User {
  final int id;
  final String email;
  final String name;
  final String role; // DEFAULT: FARMER
  final String? phone; // Nullable
  final String? imageUrl; // Nullable
  final String? address; // Nullable

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.imageUrl,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      // Hati-hati di sini: pastikan casting nullable aman
      phone: json['phone'] as String?,
      imageUrl: json['imageUrl'] as String?,
      address: json['address'] as String?,
    );
  }
}
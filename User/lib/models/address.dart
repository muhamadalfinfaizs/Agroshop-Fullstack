class Address {
  final int id;
  final String label;
  final String name;
  final String phone;
  final String detail;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.detail,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      label: json['label'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      detail: json['detail'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'name': name,
      'phone': phone,
      'detail': detail,
      'isDefault': isDefault,
    };
  }
}

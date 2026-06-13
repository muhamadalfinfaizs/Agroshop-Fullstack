class OrderItem {
  final int id;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Backend API sometimes nests product details
    final product = json['product'];
    final pName = product != null ? product['name'] : (json['productName'] ?? json['name'] ?? 'Produk');
    
    return OrderItem(
      id: json['productId'] ?? json['id'] ?? 0,
      productName: pName,
      quantity: json['quantity'] ?? json['qty'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class Order {
  final String id; // or orderCode
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();
    
    // Fallback to various keys to match different backend structures
    final dateStr = json['createdAt'] ?? json['date'];
    
    return Order(
      id: json['id'] ?? json['orderCode'] ?? '',
      totalAmount: (json['totalAmount'] ?? json['totalPrice'] ?? json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'WAITING',
      createdAt: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
      items: itemsList,
    );
  }
}

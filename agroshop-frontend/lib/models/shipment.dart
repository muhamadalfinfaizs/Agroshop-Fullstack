class ShipmentEvent {
  final int? id;
  final String title;
  final String description;
  final String location;
  final String status;
  final DateTime createdAt;

  ShipmentEvent({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  factory ShipmentEvent.fromJson(Map<String, dynamic> json) {
    return ShipmentEvent(
      id: json['id'] as int?,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class Shipment {
  final int id;
  final String orderCode;
  final String courier;
  final String trackingNumber;
  final String status;
  final List<ShipmentEvent> events;

  Shipment({
    required this.id,
    required this.orderCode,
    required this.courier,
    required this.trackingNumber,
    required this.status,
    required this.events,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    var list = json['events'] as List? ?? [];
    List<ShipmentEvent> eventsList = list.map((i) => ShipmentEvent.fromJson(i)).toList();
    
    return Shipment(
      id: json['id'] as int? ?? 0,
      orderCode: json['orderCode'] ?? '',
      courier: json['courier'] ?? '-',
      trackingNumber: json['trackingNumber'] ?? '-',
      status: json['status'] ?? 'WAITING',
      events: eventsList,
    );
  }
}

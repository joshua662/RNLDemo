class Service {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? icon;
  final bool isActive;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.icon,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _toDouble(json['price']),
      icon: json['icon'] as String?,
      isActive: json['is_active'] != false,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

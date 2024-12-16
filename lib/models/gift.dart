class Gift {
  final String id;
  final String name;
  final String category;
  final String status;
  final String description;
  final double price;
  final bool isPledged;

  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.description,
    required this.price,
    required this.isPledged, required String eventId,
  });

  factory Gift.fromMap(String id, Map<String, dynamic> data) {
    return Gift(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'Available',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      isPledged: data['isPledged'] ?? false, eventId: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'status': status,
      'description': description,
      'price': price,
      'isPledged': isPledged,
    };
  }
}

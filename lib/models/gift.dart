class Gift {
  final String id;
  final String name;
  final String category;
  final String description;
  final bool isPledged;
  final double price;
  final String status;
  final String eventId; // Add this field

  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.isPledged,
    required this.price,
    required this.status,
    required this.eventId, // Initialize eventId
  });

  factory Gift.fromMap(String id, Map<String, dynamic> data) {
    return Gift(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      isPledged: data['isPledged'] ?? false,
      price: (data['price'] ?? 0).toDouble(),
      status: data['status'] ?? 'Available',
      eventId: data['eventId'] ?? '', // Parse eventId
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'isPledged': isPledged,
      'price': price,
      'status': status,
      'eventId': eventId, // Add eventId to Firestore
    };
  }
}

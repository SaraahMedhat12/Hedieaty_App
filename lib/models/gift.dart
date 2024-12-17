class Gift {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String status;
  final bool isPledged;

  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.status,
    this.isPledged = false, required String eventId,
  });

  // Convert Firestore document to Gift model
  factory Gift.fromMap(String id, Map<String, dynamic> data) {
    return Gift(
      id: id,
      name: data['name'] ?? 'Unnamed Gift',
      category: data['category'] ?? 'No Category',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: data['status'] ?? 'Available',
      isPledged: data['isPledged'] ?? false, eventId: '',
    );
  }

  // Convert Gift model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'status': status,
      'isPledged': isPledged,
    };
  }
}

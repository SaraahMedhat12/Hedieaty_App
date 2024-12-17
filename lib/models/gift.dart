class Gift {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String status; // Available or Pledged
  final bool isPledged;
  final String eventId;

  Gift({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.status,
    required this.isPledged,
    required this.eventId,
  });

  // Ensure isPledged matches the status field
  factory Gift.fromMap(String id, Map<String, dynamic> data) {
    final status = data['status'] ?? 'Available';
    return Gift(
      id: id,
      name: data['name'] ?? 'Unnamed Gift',
      category: data['category'] ?? 'No Category',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      status: status,
      isPledged: status == 'Pledged', // Automatically set based on status
      eventId: data['eventId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'status': status,
      'isPledged': status == 'Pledged', // Automatically set based on status
      'eventId': eventId,
    };
  }

}

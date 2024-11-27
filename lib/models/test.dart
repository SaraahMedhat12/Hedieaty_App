class User {
  int? id;
  String name;
  String email;
  String preferences;

  User({this.id, required this.name, required this.email, required this.preferences});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'preferences': preferences};
  }
}

class Event {
  int? id;
  String name;
  String date;
  String location;
  String description;
  int userId;

  Event({
    this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
    };
  }
}

class Gift {
  int? id;
  String name;
  String description;
  String category;
  double price;
  String status;
  int eventId;

  Gift({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
    };
  }
}

class Friend {
  int userId;
  int friendId;

  Friend({required this.userId, required this.friendId});

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'friendId': friendId};
  }
}

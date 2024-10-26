class Gift {
  int id;
  String name;
  String category;
  bool isPledged;

  Gift({
    required this.id,
    required this.name,
    required this.category,
    this.isPledged = false,
  });
}

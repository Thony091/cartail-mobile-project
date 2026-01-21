class Category {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });
}

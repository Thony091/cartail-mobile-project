class Category {
  final int id;
  final String name;
  final String description;
  final String slug;
  final int order;
  final bool isActive;
  final String icon;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    required this.order,
    required this.isActive,
    required this.icon,
    this.createdAt,
  });
}

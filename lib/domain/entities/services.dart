
class Services{
  final String id;
  final String name;
  final String description;
  final int minPrice;
  final int maxPrice;
  final bool isActive;
  final List<String> images;

  Services({
    required this.id,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.images,
    required this.isActive,
  });
}
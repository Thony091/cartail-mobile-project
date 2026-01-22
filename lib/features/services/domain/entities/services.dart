class Services{
  final String id;
  final String name;
  final String description;
  final int minPrice;
  final int maxPrice;
  final int durationMinutes;
  final bool requiresReservation;
  final bool isActive;
  final List<String> images;
  final int? categoryId;

  Services({
    required this.id,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.durationMinutes,
    required this.requiresReservation,
    required this.isActive,
    required this.images,
    this.categoryId,
  });
}
class Works {
  final String id;
  final String name;
  final String description;
  final String image;
  final String testimonial;
  final int rating;
  final bool isFeatured;
  final bool isActive;
  final String date;
  final int? vehicleModelId;
  final String beforeImage;
  final String afterImage;

  Works({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.testimonial = '',
    this.rating = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.date = '',
    this.vehicleModelId,
    this.beforeImage = '',
    this.afterImage = '',
  });

}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/domain/entities/category.dart';

// Provider que contiene las categorías base del sistema
final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    Category(
      id: 1,
      name: 'Detailing',
      description: 'Servicios de lavado y detallado profesional de vehículos',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 2,
      name: 'Mecánica',
      description: 'Reparación y mantenimiento mecánico',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 3,
      name: 'Pintura',
      description: 'Servicios de pintura y carrocería',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 4,
      name: 'Neumáticos',
      description: 'Venta y servicio de neumáticos',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 5,
      name: 'Eléctrica',
      description: 'Reparación del sistema eléctrico del vehículo',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 6,
      name: 'Carrocería',
      description: 'Reparación de carrocería y chapa',
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];
});

// Provider para obtener una categoría por ID
final categoryByIdProvider = Provider.family<Category?, int>((ref, id) {
  final categories = ref.watch(categoriesProvider);
  try {
    return categories.firstWhere((category) => category.id == id);
  } catch (e) {
    return null;
  }
});

// Provider para obtener una categoría por nombre
final categoryByNameProvider = Provider.family<Category?, String>((ref, name) {
  final categories = ref.watch(categoriesProvider);
  try {
    return categories.firstWhere(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
});

// Provider para obtener solo categorías activas
final activeCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.where((category) => category.isActive).toList();
});

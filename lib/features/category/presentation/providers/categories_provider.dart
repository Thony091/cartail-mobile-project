import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../../../presentation/presentation_container.dart';

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return CategoriesNotifier(categoryRepository: categoryRepository);
});

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final CategoryRepository categoryRepository;

  CategoriesNotifier({required this.categoryRepository}) : super(CategoriesState()) {
    getCategories();
  }

  Future<void> getCategories() async {
    state = state.copyWith(loading: true, error: '');

    try {
      final categories = await categoryRepository.getCategories();
      state = state.copyWith(categories: categories, loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Error al obtener las categorias',
      );
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await categoryRepository.deleteCategory(id);
      state = state.copyWith(
        categories: state.categories.where((element) => element.id.toString() != id).toList(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<bool> createOrUpdateCategory(Map<String, dynamic> categorySimilar) async {
    try {
      final category = await categoryRepository.createUpdateCategory(categorySimilar);
      final isCategoryInList = state.categories.any((element) => element.id == category.id);

      if (!isCategoryInList) {
        state = state.copyWith(categories: [...state.categories, category]);
        return true;
      }

      state = state.copyWith(
        categories: state.categories
            .map((element) => (element.id == category.id) ? category : element)
            .toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CategoriesState {
  final List<Category> categories;
  final bool loading;
  final String error;

  CategoriesState({
    this.categories = const [],
    this.loading = true,
    this.error = '',
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? loading,
    String? error,
  }) => CategoriesState(
      categories: categories ?? this.categories,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
}

final categoryByIdProvider = Provider.family<Category?, int>((ref, id) {
  final categoriesState = ref.watch(categoriesProvider);
  try {
    return categoriesState.categories.firstWhere((category) => category.id == id);
  } catch (e) {
    return null;
  }
});

final categoryByNameProvider = Provider.family<Category?, String>((ref, name) {
  final categoriesState = ref.watch(categoriesProvider);
  try {
    return categoriesState.categories.firstWhere(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
});

final activeCategoriesProvider = Provider<List<Category>>((ref) {
  final categoriesState = ref.watch(categoriesProvider);
  return categoriesState.categories.where((category) => category.isActive).toList();
});

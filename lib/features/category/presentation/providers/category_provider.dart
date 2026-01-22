import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../../../presentation/presentation_container.dart';

final categoryProvider = StateNotifierProvider.autoDispose.family<CategoryNotifier, CategoryState, String>(
  (ref, categoryId) {
    final categoryRepository = ref.watch(categoryRepositoryProvider);

    return CategoryNotifier(
      categoryRepository: categoryRepository,
      categoryId: categoryId,
    );
  },
);

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryNotifier({
    required this.categoryRepository,
    required String categoryId,
  }) : super(CategoryState(id: categoryId)) {
    getCategory();
  }

  Category newEmptyCategory() {
    return Category(
      id: 0,
      name: '',
      description: '',
      slug: '',
      order: 0,
      isActive: true,
      icon: '',
      createdAt: null,
    );
  }

  Future<void> getCategory() async {
    try {
      if (state.id == 'new') {
        state = state.copyWith(
          category: newEmptyCategory(),
          isLoading: false,
        );
        return;
      }

      final category = await categoryRepository.getCategoryById(state.id);
      state = state.copyWith(
        category: category,
        isLoading: false,
      );
    } catch (e) {
      print('Error al obtener la categoria: $e');
    }
  }
}

class CategoryState {
  final String id;
  final Category? category;
  final bool isLoading;
  final bool isSaving;

  CategoryState({
    required this.id,
    this.category,
    this.isLoading = true,
    this.isSaving = false,
  });

  CategoryState copyWith({
    String? id,
    Category? category,
    bool? isLoading,
    bool? isSaving,
  }) => CategoryState(
      id: id ?? this.id,
      category: category ?? this.category,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
}

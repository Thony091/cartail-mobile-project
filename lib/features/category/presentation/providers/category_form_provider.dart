import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/category.dart';
import '../../../../presentation/presentation_container.dart';

final categoryFormProvider = StateNotifierProvider.autoDispose.family<CategoryFormNotifier, CategoryFormState, Category>(
  (ref, category) {
    final createUpdateCallback = ref.watch(categoriesProvider.notifier).createOrUpdateCategory;

    return CategoryFormNotifier(
      category: category,
      onSubmitCallback: createUpdateCallback,
    );
  },
);

class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  final Future<bool> Function(Map<String, dynamic> categorySimilar)? onSubmitCallback;

  CategoryFormNotifier({
    this.onSubmitCallback,
    required Category category,
  }) : super(
          CategoryFormState(
            id: category.id == 0 ? 'new' : category.id.toString(),
            name: Name.dirty(category.name),
            description: Description.dirty(category.description),
            slug: category.slug,
            order: category.order,
            isActive: category.isActive,
            icon: category.icon,
          ),
        );

  onNameChange(String value) {
    state = state.copyWith(
      name: Name.dirty(value),
      isFormValid: Formz.validate([
        Name.dirty(value),
        Description.dirty(state.description.value),
      ]),
    );
  }

  onDescriptionChange(String value) {
    state = state.copyWith(
      description: Description.dirty(value),
      isFormValid: Formz.validate([
        Name.dirty(state.name.value),
        Description.dirty(value),
      ]),
    );
  }

  onSlugChange(String value) {
    state = state.copyWith(slug: value);
  }

  onOrderChange(int value) {
    state = state.copyWith(order: value);
  }

  onIconChange(String value) {
    state = state.copyWith(icon: value);
  }

  onIsActiveChange(bool value) {
    state = state.copyWith(isActive: value);
  }

  _tochedEverything() {
    state = state.copyWith(
      isFormValid: Formz.validate([
        Name.dirty(state.name.value),
        Description.dirty(state.description.value),
      ]),
    );
  }

  Future<bool> onFormSubmit() async {
    _tochedEverything();
    if (!state.isFormValid) return false;
    if (onSubmitCallback == null) return false;

    final categorySimilar = {
      'id': (state.id == 'new') ? null : state.id,
      'nombre': state.name.value,
      'description': state.description.value,
      'slug': state.slug,
      'orden': state.order,
      'activo': state.isActive,
      'icono': state.icon,
    };

    try {
      return await onSubmitCallback!(categorySimilar);
    } catch (e) {
      return false;
    }
  }
}

class CategoryFormState {
  final bool isFormValid;
  final String? id;
  final Name name;
  final Description description;
  final String slug;
  final int order;
  final bool isActive;
  final String icon;

  CategoryFormState({
    required this.id,
    this.isFormValid = false,
    this.name = const Name.pure(),
    this.description = const Description.pure(),
    this.slug = '',
    this.order = 0,
    this.isActive = true,
    this.icon = '',
  });

  CategoryFormState copyWith({
    bool? isFormValid,
    String? id,
    Name? name,
    Description? description,
    String? slug,
    int? order,
    bool? isActive,
    String? icon,
  }) => CategoryFormState(
      id: id ?? this.id,
      isFormValid: isFormValid ?? this.isFormValid,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      icon: icon ?? this.icon,
    );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../../domain/entities/category.dart';
import '../providers/category_form_provider.dart';
import '../providers/category_provider.dart';

class ModernCategoryDetailPage extends ConsumerStatefulWidget {
  final String categoryId;
  static const name = 'ModernCategoryDetailPage';

  const ModernCategoryDetailPage({super.key, required this.categoryId});

  @override
  ModernCategoryDetailPageState createState() =>
      ModernCategoryDetailPageState();
}

class ModernCategoryDetailPageState
    extends ConsumerState<ModernCategoryDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId == 'new') {
      _isEditMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.userData?.isAdmin ?? false;

    if (!isAdmin) {
      return const ModernScaffoldWithDrawer(
        title: 'Categorías',
        body: Center(
          child: Text('Acceso exclusivo para administradores'),
        ),
      );
    }

    final categoryState = ref.watch(categoryProvider(widget.categoryId));
    final category = categoryState.category;

    if (categoryState.isLoading) {
      return const ModernScaffoldWithDrawer(
        title: 'Cargando...',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (category == null) {
      return const ModernScaffoldWithDrawer(
        title: 'Error',
        body: Center(child: Text('No se pudo cargar la categoría')),
      );
    }

    final isNewCategory = widget.categoryId == 'new';

    return ModernScaffoldWithDrawer(
      title: isNewCategory
          ? 'Crear Categoría'
          : _isEditMode
              ? 'Editar Categoría'
              : 'Detalles de Categoría',
      appBarActions: [
        if (!isNewCategory && !_isEditMode)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => setState(() => _isEditMode = true),
          ),
        if (_isEditMode && !isNewCategory)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _isEditMode = false),
          ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: _CategoryForm(
              category: category,
              isEditMode: _isEditMode,
              isSaving: _isSaving,
              onSave: _saveCategory,
              onCancel: () => context.pop(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory(CategoryFormNotifier notifier) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final isSaved = await notifier.onFormSubmit();

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? 'Categoría guardada' : 'No se pudo guardar la categoría',
        ),
        backgroundColor:
            isSaved ? const Color(0xFF27ae60) : const Color(0xFFe74c3c),
      ),
    );

    if (isSaved) {
      context.pop();
    }
  }
}

class _CategoryForm extends ConsumerWidget {
  final Category category;
  final bool isEditMode;
  final bool isSaving;
  final void Function(CategoryFormNotifier notifier) onSave;
  final VoidCallback onCancel;

  const _CategoryForm({
    required this.category,
    required this.isEditMode,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(categoryFormProvider(category));
    final formNotifier = ref.read(categoryFormProvider(category).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEditMode) ...[
          ModernInputField(
            label: 'Nombre',
            hint: formState.name.value,
            errorMessage: formState.name.errorMessage,
            onChanged: formNotifier.onNameChange,
          ),
          const SizedBox(height: 16),
          ModernInputField(
            label: 'Descripción',
            hint: formState.description.value,
            errorMessage: formState.description.errorMessage,
            maxLines: 4,
            onChanged: formNotifier.onDescriptionChange,
          ),
          const SizedBox(height: 16),
          ModernInputField(
            label: 'Slug',
            hint: formState.slug,
            onChanged: formNotifier.onSlugChange,
          ),
          const SizedBox(height: 16),
          ModernInputField(
            label: 'Orden',
            hint: formState.order.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => formNotifier.onOrderChange(
              int.tryParse(value) ?? 0,
            ),
          ),
          const SizedBox(height: 16),
          ModernInputField(
            label: 'Icono',
            hint: formState.icon,
            onChanged: formNotifier.onIconChange,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: formState.isActive,
            title: const Text('Categoría activa'),
            onChanged: formNotifier.onIsActiveChange,
          ),
          const SizedBox(height: 24),
          ModernButton(
            text: isSaving ? 'Guardando...' : 'Guardar categoría',
            icon: isSaving ? null : Icons.save,
            onPressed: isSaving ? null : () => onSave(formNotifier),
            isLoading: isSaving,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Cancelar',
            style: ModernButtonStyle.secondary,
            onPressed: isSaving ? null : onCancel,
          ),
        ] else ...[
          _CategoryDetailItem(label: 'Nombre', value: formState.name.value),
          _CategoryDetailItem(
            label: 'Descripción',
            value: formState.description.value,
          ),
          _CategoryDetailItem(label: 'Slug', value: formState.slug),
          _CategoryDetailItem(label: 'Orden', value: formState.order.toString()),
          _CategoryDetailItem(label: 'Icono', value: formState.icon),
          _CategoryDetailItem(
            label: 'Estado',
            value: formState.isActive ? 'Activa' : 'Inactiva',
          ),
        ],
      ],
    );
  }
}

class _CategoryDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _CategoryDetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94a3b8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
        ],
      ),
    );
  }
}

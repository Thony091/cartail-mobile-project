import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../../domain/entities/vehicle.dart';
import '../providers/vehicle_form_provider.dart';
import '../providers/vehicle_provider.dart';

class ModernVehicleDetailPage extends ConsumerStatefulWidget {
  final String vehicleId;
  static const name = 'ModernVehicleDetailPage';

  const ModernVehicleDetailPage({super.key, required this.vehicleId});

  @override
  ModernVehicleDetailPageState createState() => ModernVehicleDetailPageState();
}

class ModernVehicleDetailPageState extends ConsumerState<ModernVehicleDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId == 'new') {
      _isEditMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.userData?.isAdmin ?? false;

    if (!isAdmin) {
      return const ModernScaffoldWithDrawer(
        title: 'Modelos de Vehículo',
        body: Center(
          child: Text('Acceso exclusivo para administradores'),
        ),
      );
    }

    final vehicleState = ref.watch(vehicleProvider(widget.vehicleId));
    final vehicle = vehicleState.vehicle;

    if (vehicleState.isLoading) {
      return const ModernScaffoldWithDrawer(
        title: 'Cargando...',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vehicle == null) {
      return const ModernScaffoldWithDrawer(
        title: 'Error',
        body: Center(child: Text('No se pudo cargar el modelo de vehículo')),
      );
    }

    final isNewVehicle = widget.vehicleId == 'new';

    return ModernScaffoldWithDrawer(
      title: isNewVehicle
          ? 'Crear Modelo'
          : _isEditMode
              ? 'Editar Modelo'
              : 'Detalles del Modelo',
      appBarActions: [
        if (!isNewVehicle && !_isEditMode)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => setState(() => _isEditMode = true),
          ),
        if (_isEditMode && !isNewVehicle)
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
            child: _VehicleForm(
              vehicle: vehicle,
              isEditMode: _isEditMode,
              isSaving: _isSaving,
              onSave: _saveVehicle,
              onCancel: () => context.pop(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveVehicle(VehicleFormNotifier notifier) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final isSaved = await notifier.onFormSubmit();

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? 'Modelo guardado' : 'No se pudo guardar el modelo',
        ),
        backgroundColor: isSaved
            ? const Color(0xFF27ae60)
            : const Color(0xFFe74c3c),
      ),
    );

    if (isSaved) {
      context.pop();
    }
  }
}

class _VehicleForm extends ConsumerWidget {
  final Vehicle vehicle;
  final bool isEditMode;
  final bool isSaving;
  final void Function(VehicleFormNotifier notifier) onSave;
  final VoidCallback onCancel;

  const _VehicleForm({
    required this.vehicle,
    required this.isEditMode,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(vehicleFormProvider(vehicle));
    final formNotifier = ref.read(vehicleFormProvider(vehicle).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEditMode) ...[
          ModernInputField(
            label: 'Marca',
            hint: formState.brand.value,
            errorMessage: formState.brand.errorMessage,
            onChanged: formNotifier.onBrandChange,
          ),
          const SizedBox(height: 16),
          ModernInputField(
            label: 'Modelo',
            hint: formState.model.value,
            errorMessage: formState.model.errorMessage,
            onChanged: formNotifier.onModelChange,
          ),
          const SizedBox(height: 16),
          ModernInputField(
            label: 'Año',
            hint: formState.year.value,
            errorMessage: formState.year.value.trim().isEmpty
                ? formState.year.errorMessage
                : (formState.isYearValid
                    ? null
                    : 'Ingresa un año válido (YYYY)'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: formNotifier.onYearChange,
          ),
          const SizedBox(height: 16),
          ModernInputField(
            label: 'Trim',
            hint: formState.trim.value,
            errorMessage: formState.trim.errorMessage,
            onChanged: formNotifier.onTrimChange,
          ),
          const SizedBox(height: 24),
          ModernButton(
            text: isSaving ? 'Guardando...' : 'Guardar modelo',
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
          _VehicleDetailItem(label: 'Marca', value: formState.brand.value),
          _VehicleDetailItem(label: 'Modelo', value: formState.model.value),
          _VehicleDetailItem(label: 'Año', value: formState.year.value),
          _VehicleDetailItem(label: 'Trim', value: formState.trim.value),
          _VehicleDetailItem(label: 'ID', value: vehicle.id.toString()),
        ],
      ],
    );
  }
}

class _VehicleDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _VehicleDetailItem({required this.label, required this.value});

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

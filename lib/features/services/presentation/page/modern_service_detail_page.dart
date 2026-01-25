import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

import 'package:portafolio_project/features/services/presentation/page/modern_service_detail_widgets.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../providers/service_form_provider.dart';
import '../providers/service_provider.dart';

class ModernServiceDetailPage extends ConsumerStatefulWidget {
  final String serviceId;
  final bool startInEditMode;
  static const name = 'ModernServiceDetailPage';

  const ModernServiceDetailPage({
    super.key,
    required this.serviceId,
    this.startInEditMode = false,
  });

  @override
  ModernServiceDetailPageState createState() => ModernServiceDetailPageState();
}

class ModernServiceDetailPageState
    extends ConsumerState<ModernServiceDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _didSetEditMode = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);
    final serviceState = ref.watch(serviceProvider(widget.serviceId));

    // Cuando el servicio se cargue, usar el serviceFormProvider
    final service = serviceState.service;

    if (serviceState.isLoading) {
      return const ModernScaffoldWithDrawer(
        title: 'Cargando...',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (service == null) {
      return const ModernScaffoldWithDrawer(
        title: 'Error',
        body: Center(child: Text('No se pudo cargar el servicio')),
      );
    }

    final serviceNotifier = ref.read(serviceProvider(widget.serviceId).notifier);
    
    ref.listen(serviceFormProvider(service), (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        if (previous?.errorMessage == next.errorMessage) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final isAdmin = authState.session?.user.isAdmin ?? false;
    final isNewService = widget.serviceId == 'new';
    final isEditMode = serviceState.isEditMode;

    if (widget.startInEditMode &&
        !_didSetEditMode &&
        !serviceState.isLoading &&
        !isNewService &&
        !isEditMode) {
      _didSetEditMode = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        serviceNotifier.setEditMode(true);
      });
    }
    return ModernScaffoldWithDrawer(
      title: isNewService
          ? 'Crear Servicio'
          : isEditMode
          ? 'Editar Servicio'
          : 'Detalles del Servicio',
      appBarActions: [
        if (!isNewService && isAdmin && !isEditMode)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => serviceNotifier.setEditMode(true),
          ),
        if (isEditMode && !isNewService)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => serviceNotifier.setEditMode(false),
          ),
      ],
      body: serviceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFF667eea).withValues(alpha: 0.03),
                    const Color(0xFFf093fb).withValues(alpha: 0.03),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                dragStartBehavior: DragStartBehavior.down,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: isEditMode ? 8 : 0,
                  bottom: isEditMode ? 100 : 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isEditMode) ...[
                        // Header con indicador de progreso para modo creación
                        if (widget.serviceId == 'new')
                          FadeInDown(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16, top: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add_business,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Crear Nuevo Servicio',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Completa todos los campos requeridos',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                      // Galería de imágenes con diseño mejorado
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditMode)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10, left: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Color(0xFF667eea),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Imagen del Servicio',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2c3e50),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Color(0xFFe74c3c),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ServiceImageGallery(
                              service: service,
                              isEditMode: isEditMode,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isEditMode ? 28 : 24),

                      // Información básica con header
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditMode)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12, left: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      color: Color(0xFF667eea),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Información Básica',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2c3e50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ServiceBasicInfo(
                              serviceId: widget.serviceId,
                              service: service,
                              isEditMode: isEditMode,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isEditMode ? 24 : 20),

                      // Descripción con header
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditMode)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12, left: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF667eea),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Descripción',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2c3e50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ServiceDescription(
                              isEditMode: isEditMode,
                              serviceId: widget.serviceId,
                              service: service,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isEditMode ? 24 : 20),

                      // Detalles del servicio con header
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditMode)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12, left: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      color: Color(0xFF667eea),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Precios y Detalles',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2c3e50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ServiceDetailsSection(
                              isEditMode: isEditMode,
                              serviceId: widget.serviceId,
                              service: service,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isEditMode ? 24 : 20),

                      // Categoría con header
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditMode)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12, left: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      color: Color(0xFF667eea),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Categoría',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2c3e50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            CategorySelector(
                              serviceId: widget.serviceId,
                              service: service,
                              isEditMode: isEditMode,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isEditMode ? 32 : 32),

                      // Botones de acción con diseño mejorado
                      if (isEditMode)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              // Divider decorativo
                              Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF667eea).withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              ServiceActionButtons(
                                serviceId: widget.serviceId,
                                service: service,
                              ),
                            ],
                          ),
                        )
                      else if (!isAdmin)
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: ServiceUserActions(
                            onReserve: () {
                              context.push(
                                '/reservations?service=${widget.serviceId}',
                              );
                            },
                          ),
                        ),

                      // Espaciado adicional al final
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

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
                  left: 20,
                  right: 20,
                  top: isEditMode ? 16 : 20,
                  bottom: isEditMode ? 120 : 32,
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
                        child: _SectionCard(
                          title: 'Imagen del Servicio',
                          icon: Icons.image_outlined,
                          showHeader: isEditMode,
                          delay: 0,
                          child: ServiceImageGallery(
                            service: service,
                            isEditMode: isEditMode,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Información básica
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _SectionCard(
                          title: 'Información Básica',
                          icon: Icons.edit_note,
                          showHeader: isEditMode,
                          delay: 100,
                          child: ServiceBasicInfo(
                            serviceId: widget.serviceId,
                            service: service,
                            isEditMode: isEditMode,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Descripción
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _SectionCard(
                          title: 'Descripción',
                          icon: Icons.description_outlined,
                          showHeader: isEditMode,
                          delay: 200,
                          child: ServiceDescription(
                            isEditMode: isEditMode,
                            serviceId: widget.serviceId,
                            service: service,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Detalles del servicio
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _SectionCard(
                          title: 'Precios y Detalles',
                          icon: Icons.attach_money,
                          showHeader: isEditMode,
                          delay: 300,
                          child: ServiceDetailsSection(
                            isEditMode: isEditMode,
                            serviceId: widget.serviceId,
                            service: service,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Categoría
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _SectionCard(
                          title: 'Categoría',
                          icon: Icons.category_outlined,
                          showHeader: isEditMode,
                          delay: 400,
                          child: CategorySelector(
                            serviceId: widget.serviceId,
                            service: service,
                            isEditMode: isEditMode,
                          ),
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

/// Widget reutilizable para secciones con header consistente
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool showHeader;
  final int delay;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.showHeader = true,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe2e8f0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF667eea),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: Color(0xFFe2e8f0),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
        ],
      ),
    );
  }
}

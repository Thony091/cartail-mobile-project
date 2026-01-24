import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portafolio_project/features/realized_work/presentation/pages/modern_work_detail_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import '../providers/work_provider.dart';

class ModernWorkDetailPage extends ConsumerStatefulWidget {
  final String workId;
  static const name = 'ModernWorkDetailPage';

  const ModernWorkDetailPage({super.key, required this.workId});

  @override
  ModernWorkDetailPageState createState() => ModernWorkDetailPageState();
}

class ModernWorkDetailPageState extends ConsumerState<ModernWorkDetailPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final workState = ref.watch(workProvider(widget.workId));
    final work = workState.work;

    if (workState.isLoading) {
      return const ModernScaffoldWithDrawer(
        title: 'Cargando...',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (work == null) {
      return const ModernScaffoldWithDrawer(
        title: 'Error',
        body: Center(child: Text('No se pudo cargar el trabajo')),
      );
    }

    final workNotifier = ref.read(workProvider(widget.workId).notifier);
    final isAdmin = authState.userData?.isAdmin ?? false;
    final isNewWork = widget.workId == 'new';
    final isEditMode = workState.isEditMode;

    return ModernScaffoldWithDrawer(
      title: isNewWork
          ? 'Crear Trabajo'
          : isEditMode
              ? 'Editar Trabajo'
              : 'Detalles del Trabajo',
      appBarActions: [
        if (!isNewWork && isAdmin && !isEditMode)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => workNotifier.setEditMode(true),
          ),
        if (isEditMode && !isNewWork)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => workNotifier.setEditMode(false),
          ),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFF667eea).withValues(alpha: 0.03),
              const Color(0xFF764ba2).withValues(alpha: 0.03),
            ],
          ),
        ),
        child: SingleChildScrollView(
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
                  if (widget.workId == 'new')
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
                                    'Crear Nuevo Trabajo',
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
                          padding: EdgeInsets.only(bottom: 12, left: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: Color(0xFF667eea),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Imágenes del Trabajo',
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
                      WorkPhotoGallery(
                        work: work,
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
                      WorkBasicInfo(
                        workId: widget.workId,
                        work: work,
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
                      WorkDescription(
                        isEditMode: isEditMode,
                        workId: widget.workId,
                        work: work,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isEditMode ? 24 : 20),

                // Testimonio y calificación con header
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
                                Icons.rate_review_outlined,
                                color: Color(0xFF667eea),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Testimonio y Calificación',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2c3e50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      WorkTestimonialAndRating(
                        isEditMode: isEditMode,
                        workId: widget.workId,
                        work: work,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isEditMode ? 24 : 20),

                // Fecha con header
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isEditMode)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12, left: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF667eea),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fecha del Trabajo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2c3e50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      WorkDateSection(
                        isEditMode: isEditMode,
                        workId: widget.workId,
                        work: work,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isEditMode ? 32 : 32),

                // Botones de acción con diseño mejorado
                if (isEditMode)
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
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
                        WorkActionButtons(
                          workId: widget.workId,
                          work: work,
                        ),
                      ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_out_works_widgets.dart';

class ModernOurWorksPage extends ConsumerStatefulWidget {
  static const name = 'ModernOurWorksPage';

  const ModernOurWorksPage({super.key});

  @override
  ModernOurWorksPageState createState() => ModernOurWorksPageState();
}

class ModernOurWorksPageState extends ConsumerState<ModernOurWorksPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final worksState = ref.watch(worksProvider);
    // final authState = ref.watch(authProvider);

    final bool isAdmin = false; // authState.userData?.isAdmin ?? false
    final List<WorkData> works = _getSimulatedWorks();

    return ModernScaffoldWithDrawer(
      title: isAdmin ? 'Gestión de Trabajos' : 'Nuestros Trabajos',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.05), const Color(0xFFf8fafc)],
          ),
        ),
        child: Column(
          children: [
            // Tabs de categorías
            WorkCategoryTabs(tabController: _tabController),

            // Contenido de las tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  WorksGrid(
                    works: works,
                    isAdmin: isAdmin,
                    onWorkTap: _showWorkDetail,
                    onRefresh: _refreshWorks,
                    onDeleteConfirmation: _showDeleteWorkConfirmation,
                  ),
                  WorksGrid(
                    works: works
                        .where((w) => w.category == 'Detailing')
                        .toList(),
                    isAdmin: isAdmin,
                    onWorkTap: _showWorkDetail,
                    onRefresh: _refreshWorks,
                    onDeleteConfirmation: _showDeleteWorkConfirmation,
                  ),
                  WorksGrid(
                    works: works
                        .where((w) => w.category == 'Restauración')
                        .toList(),
                    isAdmin: isAdmin,
                    onWorkTap: _showWorkDetail,
                    onRefresh: _refreshWorks,
                    onDeleteConfirmation: _showDeleteWorkConfirmation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? ModernFloatingActionButton(
              icon: Icons.add_a_photo,
              tooltip: 'Agregar Trabajo',
              onPressed: () {
                // Navegar a crear trabajo
              },
            )
          : null,
    );
  }

  Future<void> _refreshWorks() async {
    // Refresh works
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showWorkDetail(WorkData work) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkDetailSheet(work: work),
    );
  }

  Future<bool> _showDeleteWorkConfirmation(WorkData work) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar Trabajo'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${work.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ModernButton(
                text: 'Eliminar',
                style: ModernButtonStyle.danger,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  List<WorkData> _getSimulatedWorks() {
    return [
      WorkData(
        id: '1',
        name: 'Detailing Renault Duster',
        description:
            'Limpieza profunda y encerado completo de Renault Duster 2022. Incluye lavado interior, tratamiento de cueros y protección cerámica.',
        category: 'Detailing',
        image: '',
      ),
      WorkData(
        id: '2',
        name: 'Restauración MINI Cooper',
        description:
            'Restauración completa de MINI Cooper Works. Pintura, detailing premium y modificaciones personalizadas.',
        category: 'Restauración',
        image: '',
      ),
      WorkData(
        id: '3',
        name: 'Protección Cerámica BMW',
        description:
            'Aplicación de protección cerámica premium en BMW Serie 3. Duración de 3 años con garantía.',
        category: 'Detailing',
        image: '',
      ),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/presentation/shared/widgets/widgets.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_out_works_widgets.dart';
import '../providers/works_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/works.dart';

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
    final worksState = ref.watch(worksProvider);
    final authState = ref.watch(authProvider);
    final bool isAdmin = authState.userData?.isAdmin ?? false;
    final List<Works> works = worksState.works;

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
                        .where((w) => getWorkCategory(w) == 'Detailing')
                        .toList(),
                    isAdmin: isAdmin,
                    onWorkTap: _showWorkDetail,
                    onRefresh: _refreshWorks,
                    onDeleteConfirmation: _showDeleteWorkConfirmation,
                  ),
                  WorksGrid(
                    works: works
                        .where((w) => getWorkCategory(w) == 'Restauración')
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
    await ref.read(worksProvider.notifier).getWorks();
  }

  void _showWorkDetail(Works work) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkDetailSheet(work: work),
    );
  }

  Future<bool> _showDeleteWorkConfirmation(Works work) async {
    final confirmed = await showDialog<bool>(
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

    if (!confirmed || !mounted) {
      return false;
    }

    await ref.read(worksProvider.notifier).deleteWork(work.id);
    return true;
  }
}

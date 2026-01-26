import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/data/models/admin_response_models.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';

import '../../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../../shared/presentation/shared/widgets/modern_floating_action_button.dart';
import '../../providers/admin_auth_provider.dart';
import '../providers/admin_password_form_provider.dart';
import '../providers/admin_user_form_provider.dart';
import '../widgets/admin_password_form.dart';
import '../widgets/admin_user_form.dart';
import '../widgets/admin_user_sessions_sheet.dart';
import '../widgets/admin_users_list.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  static const name = 'AdminUsersPage';

  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchValue = '';
  bool _isSearching = false;
  String _pendingSearchValue = '';
  Timer? _searchDebounce;
  String _roleFilter = 'all';
  static const List<String> _roleOptions = [
    'all',
    'admin',
    'operator',
    'user',
  ];

  void _showTopSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final topPadding = MediaQuery.of(context).padding.top;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFe74c3c) : const Color(0xFF27ae60),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0),
        dismissDirection: DismissDirection.up,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AdminUsersListState>(adminUsersListProvider, (previous, next) {
      if (next.errorMessage == null || next.errorMessage!.isEmpty) return;
      if (previous?.errorMessage == next.errorMessage) return;
      _showTopSnackBar(next.errorMessage!, isError: true);
    });

    ref.listen<AdminUserState>(adminUserProvider, (previous, next) {
      if (next.errorMessage == null || next.errorMessage!.isEmpty) return;
      if (previous?.errorMessage == next.errorMessage) return;
      _showTopSnackBar(next.errorMessage!, isError: true);
    });

    final usersState = ref.watch(adminUsersListProvider);
    final impersonationState = ref.watch(adminImpersonationProvider);

    if (_isSearching && !_searchFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Usuarios',
      titleWidget: _isSearching
          ? Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF3498db).withValues(alpha: 0.6),
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    cursorColor: const Color(0xFF2c3e50),
                    keyboardAppearance: Brightness.light,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) => _commitSearch(),
                    style: const TextStyle(
                      color: Color(0xFF2c3e50),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Buscar usuario...',
                      hintStyle: TextStyle(color: Color(0xFF7f8c8d)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            )
          : null,
      appBarActions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _searchDebounce?.cancel();
              setState(() {
                _isSearching = false;
                _searchValue = '';
                _pendingSearchValue = '';
              });
              _searchController.clear();
              _searchFocusNode.unfocus();
              _loadUsers();
            },
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() => _isSearching = true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showRoleFilterDialog,
          ),
        ],
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFF667eea).withValues(alpha: 0.04),
              const Color(0xFF764ba2).withValues(alpha: 0.04),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => _loadUsers(),
          child: CustomScrollView(
            slivers: [
              if (impersonationState.isImpersonating)
                SliverToBoxAdapter(
                  child: FadeInDown(
                    child: _ImpersonationBanner(
                      user: impersonationState.impersonatedUser,
                      onStop: _stopImpersonation,
                    ),
                  ),
                ),

              // Header con estadísticas
              SliverToBoxAdapter(
                child: FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.people_alt_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total de Usuarios',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${usersState.total}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Lista de usuarios
              if (usersState.isLoading && usersState.users.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Cargando usuarios...',
                          style: TextStyle(color: Color(0xFF7f8c8d)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (usersState.users.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: FadeIn(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No se encontraron usuarios',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Intenta con otros criterios de búsqueda',
                            style: TextStyle(color: Color(0xFF7f8c8d)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index.isOdd) {
                        return const SizedBox(height: 12);
                      }
                      final userIndex = index ~/ 2;
                      final user = usersState.users[userIndex];
                      return FadeInUp(
                        delay: Duration(milliseconds: 50 * userIndex),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AdminUserCard(
                            user: user,
                            onOpenActions: () => _showUserActions(user),
                          ),
                        ),
                      );
                    },
                    childCount: usersState.users.length * 2 - 1,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 300),
        child: ModernFloatingActionButton(
          tooltip: 'Crear usuario',
          icon: Icons.person_add,
          onPressed: () => _openUserForm(const AdminUserFormArgs.create()),
        ),
      ),
    );
  }

  Future<void> _loadUsers() async {
    await ref.read(adminUsersListProvider.notifier).loadUsers(
          searchValue: _searchValue.trim().isEmpty ? null : _searchValue.trim(),
          filterField: _roleFilter == 'all' ? null : 'role',
          filterOperator: _roleFilter == 'all' ? null : 'eq',
          filterValue: _roleFilter == 'all' ? null : _roleFilter,
        );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _pendingSearchValue = value;
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _commitSearch();
    });
  }

  void _commitSearch() {
    if (_searchValue == _pendingSearchValue) return;
    setState(() {
      _searchValue = _pendingSearchValue;
    });
    _loadUsers();
  }

  void _showRoleFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por tipo de usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _roleOptions.map((role) {
            final label = role == 'all'
                ? 'Todos'
                : role == 'admin'
                    ? 'Administradores'
                    : role == 'operator'
                        ? 'Operarios'
                        : 'Usuarios';
            return RadioListTile<String>(
              title: Text(label),
              value: role,
              groupValue: _roleFilter,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _roleFilter = value);
                Navigator.pop(context);
                _loadUsers();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _openUserForm(AdminUserFormArgs args) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AdminUserForm(
            args: args,
            onSaved: (ok) {
              // Solo cerrar y recargar si fue exitoso
              if (ok) {
                Navigator.of(context).pop();
                _loadUsers();
                _showTopSnackBar(
                  args.isNewUser
                      ? 'Usuario creado con éxito'
                      : 'Cambios guardados con éxito',
                  isError: false,
                );
              }
              // Si hay error, no cerrar el modal, el error se muestra en el formulario
            },
          ),
        ),
      ),
    );
  }

  void _openPasswordForm(AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AdminPasswordForm(
            args: AdminPasswordFormArgs(
              userId: user.id,
              userEmail: user.email,
            ),
            onSaved: (ok) {
              // Solo cerrar si fue exitoso
              if (ok) {
                Navigator.of(context).pop();
                _showTopSnackBar(
                  'Contraseña actualizada con éxito',
                  isError: false,
                );
              }
              // Si hay error, no cerrar el modal, el error se muestra en el formulario
            },
          ),
        ),
      ),
    );
  }

  void _openUserSessions(AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: AdminUserSessionsSheet(user: user),
      ),
    );
  }

  void _showUserActions(AdminUserModel user) {
    bool isLoading = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> runAction(
            Future<bool> Function() action, {
            required String successMessage,
            required String errorMessage,
            VoidCallback? onSuccess,
          }) async {
            if (isLoading) return;
            setState(() => isLoading = true);
            final ok = await action();
            if (!mounted) return;
            _showTopSnackBar(ok ? successMessage : errorMessage, isError: !ok);
            if (ok) {
              Navigator.of(sheetContext).pop();
              onSuccess?.call();
            } else {
              setState(() => isLoading = false);
            }
          }

          return AbsorbPointer(
            absorbing: isLoading,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667eea).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: Color(0xFF667eea),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Acciones de Usuario',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2c3e50),
                                ),
                              ),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7f8c8d),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ActionTile(
                    icon: Icons.info_outline,
                    title: 'Ver detalles',
                    subtitle: 'Información completa del usuario',
                    color: const Color(0xFF3498db),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _showUserDetails(user.id);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.edit_outlined,
                    title: 'Editar usuario',
                    subtitle: 'Modificar información básica',
                    color: const Color(0xFF667eea),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openUserForm(AdminUserFormArgs.edit(user));
                    },
                  ),
                  _ActionTile(
                    icon: Icons.lock_reset_outlined,
                    title: 'Cambiar contraseña',
                    subtitle: 'Establecer nueva contraseña',
                    color: const Color(0xFFf39c12),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openPasswordForm(user);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.devices_outlined,
                    title: 'Sesiones activas',
                    subtitle: 'Gestionar dispositivos conectados',
                    color: const Color(0xFF9b59b6),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openUserSessions(user);
                    },
                  ),
                  _ActionTile(
                    icon: user.isCurrentlyBanned
                        ? Icons.lock_open_outlined
                        : Icons.block_outlined,
                    title: user.isCurrentlyBanned ? 'Quitar baneo' : 'Banear usuario',
                    subtitle: user.isCurrentlyBanned
                        ? 'Restaurar acceso del usuario'
                        : 'Bloquear acceso temporalmente',
                    color: const Color(0xFFe74c3c),
                    onTap: () async {
                      await runAction(
                        () async {
                          final adminUserNotifier =
                              ref.read(adminUserProvider.notifier);
                          return user.isCurrentlyBanned
                              ? adminUserNotifier.unbanUser(user.id)
                              : adminUserNotifier.banUser(userId: user.id);
                        },
                        successMessage: user.isCurrentlyBanned
                            ? 'Baneo removido con éxito'
                            : 'Usuario baneado',
                        errorMessage: user.isCurrentlyBanned
                            ? 'No se pudo quitar el baneo'
                            : 'No se pudo banear el usuario',
                        onSuccess: _loadUsers,
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.account_circle_outlined,
                    title: 'Impersonar usuario',
                    subtitle: 'Actuar como este usuario',
                    color: const Color(0xFF27ae60),
                    onTap: () async {
                      await runAction(
                        () async => ref
                            .read(adminImpersonationProvider.notifier)
                            .startImpersonation(user.id),
                        successMessage: 'Impersonación iniciada',
                        errorMessage: 'No se pudo iniciar la impersonación',
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _stopImpersonation() async {
    final ok = await ref
        .read(adminImpersonationProvider.notifier)
        .stopImpersonation();

    if (!mounted) return;
    _showTopSnackBar(
      ok ? 'Impersonación detenida' : 'No se pudo detener la impersonación',
      isError: !ok,
    );
  }

  Future<void> _showUserDetails(String userId) async {
    final notifier = ref.read(adminUserProvider.notifier);
    await notifier.getUser(userId);
    final userState = ref.read(adminUserProvider);

    final user = userState.user;
    if (!mounted || user == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFF667eea).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF667eea),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Detalles de Usuario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(icon: Icons.badge_outlined, label: 'ID', value: user.id),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Nombre',
                value: user.name ?? '-',
              ),
              _DetailRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              _DetailRow(
                icon: Icons.shield_outlined,
                label: 'Rol',
                value: (user.role ?? 'user').toUpperCase(),
              ),
              _DetailRow(
                icon: user.isCurrentlyBanned
                    ? Icons.block_outlined
                    : Icons.check_circle_outline,
                label: 'Estado',
                value: user.isCurrentlyBanned ? 'BANEADO' : 'ACTIVO',
                valueColor: user.isCurrentlyBanned
                    ? const Color(0xFFe74c3c)
                    : const Color(0xFF27ae60),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  text: 'Cerrar',
                  icon: Icons.check,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpersonationBanner extends StatelessWidget {
  final AdminUserModel? user;
  final VoidCallback onStop;

  const _ImpersonationBanner({
    required this.user,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFf39c12).withValues(alpha: 0.1),
            const Color(0xFFe67e22).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFf39c12),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFf39c12).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFf39c12),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modo Impersonación Activo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                Text(
                  'Actuando como: ${user?.email ?? 'usuario'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
              ],
            ),
          ),
          ModernButton(
            text: 'Detener',
            icon: Icons.stop_circle_outlined,
            style: ModernButtonStyle.danger,
            onPressed: onStop,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF667eea), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7f8c8d),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF2c3e50),
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

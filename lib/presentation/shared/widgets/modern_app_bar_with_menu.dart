import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class ModernAppBarWithMenu extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const ModernAppBarWithMenu({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).subloc;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ Color(0xFF2c3e50),  Color(0xFF34495e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:  Color(0x4D2c3e50),
            blurRadius: 20,
            offset:  Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Botón de menú o back
              if (leading != null)
                leading!
              else if (automaticallyImplyLeading)
                LeadingButtonWidget(scaffoldKey: scaffoldKey, currentRoute: currentRoute),
                // _buildLeadingButton(context),
              
              if (leading != null || automaticallyImplyLeading)
                const SizedBox(width: 16),
              
              // Título
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Acciones
              if (actions != null) ...[
                const SizedBox(width: 16),
                ...actions!,
              ] else
                const AuthButtonWidget(),
                // const SizedBox(width: 52), // Para centrar el título
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class LeadingButtonWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String currentRoute;
  const LeadingButtonWidget({
    super.key,
    required this.scaffoldKey,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    // final currentRoute = GoRouterState.of(context).subloc;
    
    if (canPop && currentRoute != '/' ) {
      // Mostrar botón de back
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues( alpha: .2 ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18,
          ),
        ),
      );
    } else {
      // Mostrar botón de menú
      return GestureDetector(
        onTap: () {
          if (scaffoldKey?.currentState != null) {
            scaffoldKey!.currentState!.openDrawer();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues( alpha: .2 ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }
  }
}

class AuthButtonWidget extends ConsumerWidget {
  const AuthButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return GestureDetector(
      onTap: authState.authStatus == AuthStatus.authenticated
        ? () => ref.read( authProvider.notifier ).logOut()
        : () => context.push('/login'),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: authState.authStatus == AuthStatus.authenticated
            ? Colors.red.withValues( alpha: .45 )
            : Colors.blueAccent.withValues( alpha: .45 ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          authState.authStatus == AuthStatus.authenticated 
            ? Icons.logout 
            : Icons.person,
          color: Colors.white,
          fontWeight: FontWeight.w700 ,
          size: 20
        ),
      ),
    );
  }
}
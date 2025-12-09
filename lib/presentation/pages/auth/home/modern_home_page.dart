import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/presentation/pages/auth/home/views/admin_body_home_view.dart';
import 'package:portafolio_project/presentation/pages/auth/home/views/user_body_home_view.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'package:portafolio_project/presentation/providers/auth_provider.dart';

class ModernHomePage extends ConsumerStatefulWidget {
  static const name = 'ModernHomePage';
  
  const ModernHomePage({super.key});

  @override
  ModernHomePageState createState() => ModernHomePageState();
}

class ModernHomePageState extends ConsumerState<ModernHomePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return PopScope(
      canPop: false,
      child: ModernScaffoldWithDrawer(
        title: authState.authStatus == AuthStatus.authenticated 
          ? 'Hola ${authState.userData!.nombre}' 
          : 'Bienvenido',
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF667eea).withValues(alpha: .1),
                const Color(0xFFf8fafc),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if ( authState.authStatus == AuthStatus.authenticated && authState.userData!.isAdmin )
                  const AdminBodyHomeView()
                else
                  const UserBodyHomeView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
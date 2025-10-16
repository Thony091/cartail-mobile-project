import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/shared/widgets/side-menu-components/components.dart';

import '../../providers/auth_provider.dart';

class ModernSideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ModernSideMenu({
    super.key,
    required this.scaffoldKey,
  });

  @override
  ModernSideMenuState createState() => ModernSideMenuState();
}

class ModernSideMenuState extends ConsumerState<ModernSideMenu>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    // final authStatus = ref.watch(authProvider).authStatus;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-300 * (1 - _animation.value), 0),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFf8fafc),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues( alpha: .1),
                  blurRadius: 20,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header del menú
                  MenuHeaderWidget(
                    userName: authState.userData?.nombre ?? 'Invitado',
                    isAuthenticated: authState.authStatus == AuthStatus.authenticated,
                    isAdmin: authState.userData?.isAdmin ?? false,
                  ),
                  // _buildMenuHeader(authState.userData!.nombre, authState.authStatus, authState.userData!.isAdmin),
                  // _buildMenuHeader(userName, isAuthenticated, isAdmin),

                  // Opciones del menú
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        MenuSectionWidget(
                        // _buildMenuSection(
                          title: "NAVEGACIÓN",
                          items: [
                            MenuItemData(
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home,
                              title: "Home",
                              onTap: () => context.go('/'),
                              // onTap: () => _navigateTo(context, '/'),
                            ),
                            if ( authState.authStatus == AuthStatus.authenticated  && authState.userData?.isAdmin == true) ...[
                              MenuItemData(
                                icon: Icons.build_outlined,
                                activeIcon: Icons.build,
                                title: "Gest. de Servicios",
                                onTap: () => context.push ('/admin-config-services'),
                                // onTap: () => _navigateTo(context, '/services'),
                              ),
                              MenuItemData(
                                icon: Icons.calendar_today_outlined,
                                activeIcon: Icons.calendar_today,
                                title: "Gest. de Reservas",
                                onTap: () => context.push('/admin-config-reservations'),
                                // onTap: () => _navigateTo(context, '/reservas-config'),
                              ),
                              MenuItemData(
                                icon: Icons.store_mall_directory,
                                activeIcon: Icons.store,
                                title: "Gest. de Productos",
                                onTap: () => context.push('/admin-config-products'),
                                // onTap: () => _navigateTo(context, '/our-works'),
                              ),
                              MenuItemData(
                                icon: Icons.diamond_outlined,
                                activeIcon: Icons.diamond,
                                title: "Gest. de Trabajos",
                                onTap: () => context.push('/admin-config-works'),
                                // onTap: () => _navigateTo(context, '/our-works'),
                              ),
                              MenuItemData(
                                icon: Icons.message_outlined,
                                activeIcon: Icons.message,
                                title: "Gest. de Mensajes",
                                onTap: () => context.push('/messages'),
                                // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernMessagesPage())),
                                // onTap: () => _navigateTo(context, '/messages'),
                              ),
                            ] else ...[
                              MenuItemData(
                                icon: Icons.build_outlined,
                                activeIcon: Icons.build,
                                title: "Servicios",
                                onTap: () => context.push('/services'),
                                // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernServicesPage())),
                                // onTap: () => _navigateTo(context, '/services'),
                              ),
                              MenuItemData(
                                icon: Icons.diamond_outlined,
                                activeIcon: Icons.diamond,
                                title: "Nuestros trabajos",
                                onTap: () => context.push('/our-works'),
                                // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernOurWorksPage())),
                              ),
                              MenuItemData(
                                icon: Icons.calendar_today_outlined,
                                activeIcon: Icons.calendar_today,
                                title: "Agenda tu hora",
                                onTap: () => context.push('/reservations'),
                                // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernReservationsPage())),
                                // onTap: () => _navigateTo(context, '/reservations'),
                              ),
                            ],
                            if ( authState.userData?.isAdmin == false || authState.authStatus == AuthStatus.notAuthenticated || authState.authStatus == AuthStatus.authenticated ) ...[
                              MenuItemData(
                                icon: Icons.store_mall_directory,
                                activeIcon: Icons.store_mall_directory,
                                title: "Productos",
                                onTap: () => context.push('/products'),
                                // onTap: () => context.push('/shoping-cart'),
                                // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernCartPage())),
                              ),
                            ]
                          ]
                        ),

                        if ( authState.authStatus == AuthStatus.authenticated ) ...[
                          MenuSectionWidget(
                            title: "CUENTA",
                            items: [
                            // _buildMenuSection("CUENTA", [
                              MenuItemData(
                                icon: Icons.person_outline,
                                activeIcon: Icons.person,
                                title: "Mi Perfil",
                                // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernProfilePage())),
                                onTap: () => context.push ('/profile-user'),
                              ),
                              MenuItemData(
                                icon: Icons.history,
                                activeIcon: Icons.history,
                                title: "Historial",
                                onTap: () => context.push('/history'),
                                // onTap: () => _navigateTo(context, '/history'),
                              ),
                              if ( authState.userData?.isAdmin == false ) ...[
                                MenuItemData(
                                  icon: Icons.shopping_cart_outlined,
                                  activeIcon: Icons.shopping_cart,
                                  title: "Mi Carrito",
                                  onTap: () => context.push('/shoping-cart'),
                                  // onTap: () => _navigateTo(context, '/cart'),
                                ),
                              ],
                            ]
                          ),
                        ] else ...[
                          if ( authState.userData?.isAdmin == false || authState.authStatus == AuthStatus.notAuthenticated || authState.authStatus == AuthStatus.authenticated ) ...[
                            MenuSectionWidget(
                              title: "CUENTA",
                              items: [
                                  MenuItemData(
                                    icon: Icons.shopping_cart_outlined,
                                    activeIcon: Icons.shopping_cart,
                                    title: "Mi Carrito",
                                    onTap: () => context.push('/shoping-cart'),
                                    // onTap: () => _navigateTo(context, '/cart'),
                                  ),
                                ],
                            )
                          ],
                        ],

                        MenuSectionWidget(
                          title: "SOPORTE",
                          items: [
                          // _buildMenuSection("SOPORTE", [
                            MenuItemData(
                              icon: Icons.help_outline,
                              activeIcon: Icons.help,
                              title: "Ayuda",
                              onTap: () => context.push('/help'),
                              // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernHelpPage())),
                              // onTap: () => _navigateTo(context, '/help'),
                            ),
                            MenuItemData(
                              icon: Icons.info_outline,
                              activeIcon: Icons.info,
                              title: "Acerca de",
                              onTap: () => context.push('/about-us'),
                              // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernAboutPage())),
                              // onTap: () => _navigateTo(context, '/about'),
                            ),
                          ]
                        ),
                      ],
                    ),
                  ),

                  // Footer del menú
                  MenuFooterWidget( isAuthenticated: authState.authStatus == AuthStatus.authenticated ),
                  // _buildMenuFooter(authState.authStatus == AuthStatus.authenticated),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
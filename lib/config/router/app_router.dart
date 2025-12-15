import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/auth/cart-shop/modern_cart_page.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_check_auth_status_screen.dart';
import 'package:portafolio_project/presentation/pages/auth/reservations/modern_config_reservations_page.dart';
import 'package:portafolio_project/presentation/pages/auth/service/modern_config_services_page.dart';
import 'package:portafolio_project/presentation/pages/auth/profile/modern_edit_profile.dart';
import 'package:portafolio_project/presentation/pages/auth/login/components/modern_login_page.dart';
import 'package:portafolio_project/presentation/pages/auth/profile/modern_profile_page.dart';

import '../../presentation/pages/auth/about/modern_about_page.dart';
import '../../presentation/pages/auth/product/modern_config_products_page.dart';
import '../../presentation/pages/auth/realized-works/modern_config_works_page.dart';
import '../../presentation/pages/auth/help/modern_help_page.dart';
import '../../presentation/pages/auth/home/modern_home_page.dart';
import '../../presentation/pages/auth/message/modern_messages_page.dart';
import '../../presentation/pages/auth/realized-works/modern_out_works.dart';
import '../../presentation/pages/auth/product/modern_product_detail_page.dart';
import '../../presentation/pages/auth/register/modern_register_page.dart';
import '../../presentation/pages/auth/reservations/modern_reservations_page.dart';
import '../../presentation/pages/auth/reset-password/modern_reset_password_page.dart';
import '../../presentation/pages/auth/service/modern_service_detail_page.dart';
import '../../presentation/pages/auth/service/modern_service_page.dart';
import '../../presentation/pages/auth/realized-works/modern_work_detail_page.dart';
import '../../presentation/pages/auth/tickets/admin_all_tickets_page.dart';
import '../../presentation/pages/auth/tickets/operator_assigned_tickets_page.dart';
import '../../presentation/pages/auth/history/user_history_page.dart';
import '../../presentation/pages/unfinished/modern_checkout_page.dart';
import '../../presentation/presentation_container.dart';
import 'route_guards.dart';
import 'router.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        name: ModernCheckAuthStatusScreen.name,
        builder: (context, state) => const ModernCheckAuthStatusScreen(),
      ),
      //* Home
      GoRoute(
        path: '/',
        name: ModernHomePage.name,
        builder: (context, state) => const ModernHomePage(),
      ),

      //* Login
      GoRoute(
        path: '/login',
        name: ModernLoginPage.name,
        builder: (context, state) => const ModernLoginPage(),
      ),

      //* Register
      GoRoute(
        path: '/register',
        name: ModernRegisterPage.name,
        builder: (context, state) => const ModernRegisterPage(),
      ),

      //* Reset Password
      GoRoute(
        path: '/reset-password',
        name: ModernResetPasswordPage.name,
        builder: (context, state) => const ModernResetPasswordPage(),
      ),

      //* Pago
      // GoRoute(
      //   path: '/pago',
      //   name: ModernPaymentMethodsPage.name,
      //   builder: (context, state) => const ModernPaymentMethodsPage(),
      // ),

      //* Products
      GoRoute(
        path: '/products',
        name: ModernProductsPage.name,
        builder: (context, state) => const ModernProductsPage(),
      ),

      //* Product Detail
      GoRoute(
        path: '/product/:id',
        name: ModernProductDetailPage.name,
        builder: (context, state) =>
            ModernProductDetailPage(productId: state.params['id'] ?? 'no-id'),
      ),

      //* Reservations
      GoRoute(
        path: '/reservations',
        name: ModernReservationsPage.name,
        builder: (context, state) => const ModernReservationsPage(),
      ),

      //* Services
      GoRoute(
        path: '/services',
        name: ModernServicesPage.name,
        // name: ServicesPage.name,
        builder: (context, state) => const ModernServicesPage(),
        // builder: (context, state) => const ServicesPage(),
      ),
      //* Service Detail
      GoRoute(
        path: '/service/:id',
        name: ModernServiceDetailPage.name,
        builder: (context, state) =>
            ModernServiceDetailPage(serviceId: state.params['id'] ?? 'no-id'),
      ),
      //* Service Edit
      // GoRoute(
      //   path: '/service-edit/:id',
      //   name: ModernServiceDetailPage.name,
      //   builder: (context, state) => ModernServiceDetailPage(
      //   // name: ServiceEditPage.name,
      //   // builder: (context, state) => ServiceEditPage(
      //     serviceId: state.params['id'] ?? 'no-id'
      //   ),
      // ),

      //* Profile
      GoRoute(
        path: '/profile-user',
        name: ModernProfilePage.name,
        builder: (context, state) => const ModernProfilePage(),
      ),
      //* Edit Profile
      GoRoute(
        path: '/edit-user-profile',
        name: ModernEditProfilePage.name,
        builder: (context, state) => const ModernEditProfilePage(),
      ),

      //* Shoping Cart
      GoRoute(
        path: '/shoping-cart',
        name: ModernCartPage.name,
        builder: (context, state) => const ModernCartPage(),
      ),

      //* Our Works
      GoRoute(
        path: '/our-works',
        name: ModernOurWorksPage.name,
        builder: (context, state) => const ModernOurWorksPage(),
      ),
      //* Work Edit
      GoRoute(
        path: '/work-edit/:id',
        name: ModernWorkDetailPage.name,
        builder: (context, state) =>
            ModernWorkDetailPage(workId: state.params['id'] ?? 'no-id'),
      ),

      //* AdminZone
      //* ConfigMessagesPage
      GoRoute(
        path: '/messages',
        name: ModernMessagesPage.name,
        builder: (context, state) => const ModernMessagesPage(),
      ),
      // //* ConfigMessagesResponsePage
      // GoRoute(
      //   path: '/message-response/:id',
      //   name:  ModernMessageResponsePage.name,
      //   // name:  MessageResponsePage.name,
      //   builder: (context, state) =>  ModernMessageResponsePage(
      //   // builder: (context, state) =>  MessageResponsePage(
      //     messageId: state.params['id'] ?? 'no-id'
      //   ),
      // ),
      //* ConfigServicesPage
      GoRoute(
        path: '/admin-config-services',
        name: ModernConfigServicesPage.name,
        builder: (context, state) => const ModernConfigServicesPage(),
      ),
      //* ConfigProductsPage
      GoRoute(
        path: '/admin-config-products',
        name: ModernConfigProductsPage.name,
        builder: (context, state) => const ModernConfigProductsPage(),
      ),

      //* ConfigWorksPage
      GoRoute(
        path: '/admin-config-works',
        name: ModernConfigWorksPage.name,
        builder: (context, state) => const ModernConfigWorksPage(),
      ),
      //* ContactTicketsPage
      GoRoute(
        path: '/admin-contact-tickets',
        name: ModernMessageResponsePage.name,
        builder: (context, state) =>
            ModernMessageResponsePage(messageId: state.params['id'] ?? 'no-id'),
      ),
      //* ReservaionPage
      GoRoute(
        path: '/admin-config-reservations',
        name: ModernConfigReservationsPage.name,
        builder: (context, state) => const ModernConfigReservationsPage(),
      ),
      //* HelpPage
      GoRoute(
        path: '/help',
        name: ModernHelpPage.name,
        builder: (context, state) => const ModernHelpPage(),
      ),
      //* AboutUsPage
      GoRoute(
        path: '/about-us',
        name: ModernAboutPage.name,
        builder: (context, state) => const ModernAboutPage(),
      ),
      //* CheckOutPage
      GoRoute(
        path: '/checkout',
        name: ModernCheckoutPage.name,
        builder: (context, state) => const ModernCheckoutPage(),
      ),
      //* PaymentMethodsPage
      GoRoute(
        path: '/payment-methods',
        name: ModernPaymentMethodsPage.name,
        builder: (context, state) => const ModernPaymentMethodsPage(),
      ),

      //* History Page (for all authenticated users)
      GoRoute(
        path: '/my-history',
        name: UserHistoryPage.name,
        builder: (context, state) => const UserHistoryPage(),
      ),

      //* Operator - Assigned Tickets
      GoRoute(
        path: '/my-assigned-tickets',
        name: OperatorAssignedTicketsPage.name,
        builder: (context, state) => const OperatorAssignedTicketsPage(),
      ),

      //* Admin - All Tickets
      GoRoute(
        path: '/admin-all-tickets',
        name: AdminAllTicketsPage.name,
        builder: (context, state) => const AdminAllTicketsPage(),
      ),
    ],

    redirect: (context, state) {
      final isGoingTo = state.subloc;
      final authStatus = goRouterNotifier.authStatus;
      final userRole = goRouterNotifier.userRole;

      // Permitir splash screen durante verificación
      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
        return null;
      }

      // Redirigir desde splash después de verificación
      if (isGoingTo == '/splash' && authStatus != AuthStatus.checking) {
        return '/';
      }

      // Redirigir desde login/register si ya está autenticado
      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/reset-password') {
          return '/';
        }
      }

      // Verificar permisos basados en rol usando RouteGuards
      if (!RouteGuards.canAccessRoute(isGoingTo, userRole)) {
        return RouteGuards.getRedirectRoute(isGoingTo, userRole);
      }

      return null;
    },
  );
});

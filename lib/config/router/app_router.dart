import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/config/services/firebase/analytics_service.dart';
import 'package:portafolio_project/presentation/pages/auth/cart-shop/modern_cart_page.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_check_auth_status_screen.dart';
import 'package:portafolio_project/presentation/widgets/connectivity_monitoring_dashboard.dart';
import 'package:portafolio_project/features/reservation/presentation/page/modern_config_reservations_page.dart';
import 'package:portafolio_project/features/services/presentation/page/modern_config_services_page.dart';
import 'package:portafolio_project/features/user/presentation/profile/modern_edit_profile.dart';
import 'package:portafolio_project/features/category/presentation/page/modern_config_categories_page.dart';
import 'package:portafolio_project/features/category/presentation/page/modern_category_detail_page.dart';
import 'package:portafolio_project/features/reservation/presentation/models/reservation_payment_session.dart';
import 'package:portafolio_project/features/vehicle/presentation/pages/modern_vehicle_detail_page.dart';
import 'package:portafolio_project/features/vehicle/presentation/pages/modern_vehicles_page.dart';
import 'package:portafolio_project/features/auth/presentation/login/modern_login_page.dart';
import 'package:portafolio_project/features/user/presentation/profile/modern_profile_page.dart';
import 'package:portafolio_project/features/auth/presentation/admin/pages/admin_users_page.dart';

import '../../features/about/modern_about_page.dart';
// import '../../features/product/presentation/product/modern_config_products_page.dart';
import '../../features/realized_work/presentation/pages/modern_config_works_page.dart';
import '../../features/help/modern_help_page.dart';
import '../../features/home/modern_home_page.dart';
import '../../features/message/presentation/pages/modern_messages_page.dart';
import '../../features/realized_work/presentation/pages/modern_out_works.dart';
// import '../../features/product/presentation/product/modern_product_detail_page.dart';
import '../../features/auth/presentation/register/modern_register_page.dart';
import '../../features/reservation/presentation/page/modern_reservations_page.dart';
import '../../features/reservation/presentation/page/reservation_payment_webview_page.dart';
import '../../features/auth/presentation/reset-password/modern_reset_password_page.dart';
import '../../features/services/presentation/page/modern_service_detail_page.dart';
import '../../features/services/presentation/page/modern_service_page.dart';
import '../../features/realized_work/presentation/pages/modern_work_detail_page.dart';
import '../../features/ticket/presentation/pages/admin_all_tickets_page.dart';
import '../../features/ticket/presentation/pages/ticket_detail_page.dart';
import '../../features/ticket/presentation/pages/ticket_edit_page.dart';
import '../../features/ticket/presentation/pages/operator_assigned_tickets_page.dart';
import '../../features/admin/presentation/ticket_assignment/admin_ticket_assignment_page.dart';
import '../../features/slot/presentation/pages/admin_slot_creation_page.dart';
import '../../features/slot/presentation/pages/admin_config_slots_page.dart';
import '../../features/history/user_history_page.dart';
import '../../features/operator/presentation/pages/operator_work_orders_page.dart';
import '../../features/operator/presentation/pages/work_order_detail_page.dart';
import '../../features/operator/presentation/pages/vehicle_reception_page.dart';
import '../../features/operator/presentation/pages/operator_home_page.dart';
import '../../features/payment/presentation/pages/modern_checkout_page.dart';
import '../../features/payment/presentation/pages/add_credit_card_page.dart';
import '../../features/service_tracking/presentation/pages/my_services_page.dart';
import '../../features/service_tracking/presentation/pages/service_detail_page.dart'
    as tracking;
import '../../features/factura/presentation/page/modern_factura_page.dart';
import '../../features/factura/presentation/page/modern_config_facturas_page.dart';
import '../../features/factura/presentation/page/modern_factura_detail_page.dart';
import '../../presentation/presentation_container.dart';
import '../../features/user/domain/entities/user_role.dart';
import 'route_guards.dart';
import 'router.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    observers: [
      AnalyticsService.observer,
    ],
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

      // //* Products - DISABLED: No product module
      // GoRoute(
      //   path: '/products',
      //   name: ModernProductsPage.name,
      //   builder: (context, state) => const ModernProductsPage(),
      // ),

      // //* Product Detail - DISABLED: No product module
      // GoRoute(
      //   path: '/product/:id',
      //   name: ModernProductDetailPage.name,
      //   builder: (context, state) =>
      //       ModernProductDetailPage(productId: state.params['id'] ?? 'no-id'),
      // ),

      //* Reservations
      GoRoute(
        path: '/reservations',
        name: ModernReservationsPage.name,
        builder: (context, state) => const ModernReservationsPage(),
      ),
      GoRoute(
        path: '/reservation-payment',
        name: ReservationPaymentWebViewPage.name,
        builder: (context, state) {
          final session = state.extra;
          if (session is! ReservationPaymentSession) {
            return const ModernReservationsPage();
          }
          return ReservationPaymentWebViewPage(session: session);
        },
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
      //* Service Edit (Admin)
      GoRoute(
        path: '/service-edit/:id',
        name: 'ModernServiceEditPage',
        builder: (context, state) => ModernServiceDetailPage(
          serviceId: state.params['id'] ?? 'no-id',
          startInEditMode: true,
        ),
      ),
      //* Category Edit (Admin)
      GoRoute(
        path: '/category-edit/:id',
        name: ModernCategoryDetailPage.name,
        builder: (context, state) => ModernCategoryDetailPage(
          categoryId: state.params['id'] ?? 'no-id',
        ),
      ),
      //* Vehicle Model Edit (Admin)
      GoRoute(
        path: '/vehicle-edit/:id',
        name: ModernVehicleDetailPage.name,
        builder: (context, state) => ModernVehicleDetailPage(
          vehicleId: state.params['id'] ?? 'no-id',
        ),
      ),

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
      //* Admin Users
      GoRoute(
        path: '/admin-users',
        name: AdminUsersPage.name,
        builder: (context, state) => const AdminUsersPage(),
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
      //* ConfigCategoriesPage
      GoRoute(
        path: '/admin-config-categories',
        name: ModernConfigCategoriesPage.name,
        builder: (context, state) => const ModernConfigCategoriesPage(),
      ),
      //* ConfigVehiclesPage
      GoRoute(
        path: '/admin-config-vehicles',
        name: ModernVehiclesPage.name,
        builder: (context, state) => const ModernVehiclesPage(),
      ),
      // //* ConfigProductsPage - DISABLED: No product module
      // GoRoute(
      //   path: '/admin-config-products',
      //   name: ModernConfigProductsPage.name,
      //   builder: (context, state) => const ModernConfigProductsPage(),
      // ),

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
      //* Add Credit Card
      GoRoute(
        path: '/payment/add-card',
        name: AddCreditCardPage.name,
        builder: (context, state) => const AddCreditCardPage(),
      ),

      //* History Page (for all authenticated users)
      GoRoute(
        path: '/my-history',
        name: UserHistoryPage.name,
        builder: (context, state) => const UserHistoryPage(),
      ),
      //* User - My Invoices
      GoRoute(
        path: '/my-facturas',
        name: ModernFacturaPage.name,
        builder: (context, state) => const ModernFacturaPage(),
      ),

      //* Staff - Facturas
      GoRoute(
        path: '/staff-facturas',
        name: ModernConfigFacturasPage.name,
        builder: (context, state) => const ModernConfigFacturasPage(),
      ),

      //* Factura Detail (Create/Edit)
      GoRoute(
        path: '/factura-edit/:id',
        name: ModernFacturaDetailPage.name,
        builder: (context, state) =>
            ModernFacturaDetailPage(facturaId: state.params['id'] ?? 'no-id'),
      ),

      //* User - My Services (Service Tracking)
      GoRoute(
        path: '/my-services',
        name: MyServicesPage.name,
        builder: (context, state) => const MyServicesPage(),
      ),

      //* User - Service Detail (Service Tracking)
      GoRoute(
        path: '/my-services/:id',
        name: tracking.ServiceTrackingDetailPage.name,
        builder: (context, state) => tracking.ServiceTrackingDetailPage(
            serviceId: state.params['id'] ?? 'no-id'),
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
      //* Admin - Ticket Detail
      GoRoute(
        path: '/admin-ticket/:id',
        name: TicketDetailPage.name,
        builder: (context, state) =>
            TicketDetailPage(ticketId: state.params['id'] ?? 'no-id'),
      ),
      //* Admin - Ticket Edit
      GoRoute(
        path: '/admin-ticket/:id/edit',
        name: TicketEditPage.name,
        builder: (context, state) =>
            TicketEditPage(ticketId: state.params['id'] ?? 'no-id'),
      ),
      //* Admin - Ticket Assignment
      GoRoute(
        path: '/admin-assign-ticket',
        name: AdminTicketAssignmentPage.name,
        builder: (context, state) => const AdminTicketAssignmentPage(),
      ),
      //* Admin - Crear slot
      GoRoute(
        path: '/admin-create-slot',
        name: AdminSlotCreationPage.name,
        builder: (context, state) => const AdminSlotCreationPage(),
      ),
      //* Admin - Gestión de slots
      GoRoute(
        path: '/admin-config-slots',
        name: AdminConfigSlotsPage.name,
        builder: (context, state) => const AdminConfigSlotsPage(),
      ),

      //* Operator - Home
      GoRoute(
        path: '/operator/home',
        name: OperatorHomePage.name,
        builder: (context, state) => const OperatorHomePage(),
      ),

      //* Operator - Work Orders (Ordenes de Trabajo)
      GoRoute(
        path: '/operator/work-orders',
        name: OperatorWorkOrdersPage.name,
        builder: (context, state) => const OperatorWorkOrdersPage(),
      ),

      //* Operator - Work Order Detail
      GoRoute(
        path: '/operator/order/:id',
        name: WorkOrderDetailPage.name,
        builder: (context, state) =>
            WorkOrderDetailPage(orderId: state.params['id'] ?? 'no-id'),
      ),

      //* Operator - Vehicle Reception Checklist
      GoRoute(
        path: '/operator/reception/:id',
        name: VehicleReceptionPage.name,
        builder: (context, state) =>
            VehicleReceptionPage(orderId: state.params['id'] ?? 'no-id'),
      ),

      //* Debug - Connectivity Monitor (Debug mode only)
      if (kDebugMode)
        GoRoute(
          path: '/debug/connectivity',
          name: 'ConnectivityMonitoringDashboard',
          builder: (context, state) => const ConnectivityMonitoringDashboard(),
        ),
    ],

    redirect: (context, state) {
      final isGoingTo = state.subloc;
      final authStatus = goRouterNotifier.authStatus;
      final userRole = goRouterNotifier.userRole;

      // Mientras se verifica la sesión, mantener en splash
      if (authStatus == AuthStatus.checking) {
        return isGoingTo == '/splash' ? null : '/splash';
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

      // Si estamos en una ruta pública de auth y hay un error/deslogueo,
      // no forceamos un redirect; el formulario debe quedarse donde está.
      if (isGoingTo == '/login' ||
          isGoingTo == '/register' ||
          isGoingTo == '/reset-password') {
        return null;
      }

      // Si el usuario acaba de hacer logout (notAuthenticated) y está en una ruta que requiere autenticación
      // o que requiere permisos específicos, redirigir al home
      if (authStatus == AuthStatus.notAuthenticated) {
        if (!RouteGuards.canAccessRoute(isGoingTo, UserRole.guest)) {
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

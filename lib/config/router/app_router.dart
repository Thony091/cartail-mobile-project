import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_cart_page.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_check_auth_status_screen.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_config_reservations_page.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_config_services_page.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_edit_profile.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_login_page.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_profile_page.dart';

import '../../presentation/pages/auth/modern_about_page.dart';
import '../../presentation/pages/auth/modern_config_products_page.dart';
import '../../presentation/pages/auth/modern_config_works_page.dart';
import '../../presentation/pages/auth/modern_help_page.dart';
import '../../presentation/pages/auth/modern_home_page.dart';
import '../../presentation/pages/auth/modern_messages_page.dart';
import '../../presentation/pages/auth/modern_out_works.dart';
import '../../presentation/pages/auth/modern_product_detail_page.dart';
import '../../presentation/pages/auth/modern_register_page.dart';
import '../../presentation/pages/auth/modern_reservations_page.dart';
import '../../presentation/pages/auth/modern_reset_password_page.dart';
import '../../presentation/pages/auth/modern_service_detail_page.dart';
import '../../presentation/pages/auth/modern_service_page.dart';
import '../../presentation/pages/auth/modern_work_detail_page.dart';
import '../../presentation/pages/our_works/our_works_container.dart';
import '../../presentation/pages/unfinished/modern_checkout_page.dart';
import '../../presentation/presentation_container.dart';
import 'router.dart';


final goRouterProvider = Provider( (ref) {

  final goRouterNotifier = ref.read( goRouterNotifierProvider );

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: 
      [
        GoRoute(
          path: '/splash', 
          name: ModernCheckAuthStatusScreen.name, 
          builder: (context, state) => const ModernCheckAuthStatusScreen()
        ),
        //* Home
        GoRoute(
          path: '/',
          name: ModernHomePage.name,
          builder: (context, state) => const ModernHomePage(),
          // name: HomePage.name,
          // builder: (context, state) => const HomePage(),
        ),

        //* Login
        GoRoute(
          path: '/login',
          name: ModernLoginPage.name,
          builder: (context, state) => const ModernLoginPage(),
          // name: LoginPage.name,
          // builder: (context, state) => const LoginPage(),
        ),

        //* Register
        GoRoute(
          path: '/register',
          name: ModernRegisterPage.name,
          builder: (context, state) => const ModernRegisterPage(),
          // name: RegisterPage.name,
          // builder: (context, state) => const RegisterPage(),
        ),

        //* Reset Password
        GoRoute(
          path: '/reset-password',
          name: ModernResetPasswordPage.name,
          // name: ResetPasswordPage.name,
          builder: (context, state) => const ModernResetPasswordPage(),
          // builder: (context, state) => const ResetPasswordPage(),
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
          // name: ProductsPage.name,
          // builder: (context, state) => const ProductsPage(),
        ),
          // routes: 
          //   [
        //* Product Detail
        GoRoute(
          path: '/product/:id',
          name: ModernProductDetailPage.name,
          builder: (context, state) => ModernProductDetailPage(
          // name: ProductDetailPage.name,
          // builder: (context, state) => ProductDetailPage(
            productId: state.params['id'] ?? 'no-id'
          ),
        ),
          //   ],

        //* Reservations
        GoRoute(
          path: '/reservations',
          name: ModernReservationsPage.name,
          // name: ReservationsPage.name,
          builder: (context, state) => const ModernReservationsPage(),
          // builder: (context, state) => const ReservationsPage(),
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
          builder: (context, state) => ModernServiceDetailPage(
            serviceId: state.params['id'] ?? 'no-id'
          ),
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
          // name: ProfileUserPage.name,
          builder: (context, state) => const ModernProfilePage(),
          // builder: (context, state) => const ProfileUserPage(),
        ),
        //* Edit Profile
        GoRoute(
          path: '/edit-user-profile',
          name: ModernEditProfilePage.name,
          // name: EditUserProfilePage.name,
          builder: (context, state) => const ModernEditProfilePage(),
          // builder: (context, state) => const EditUserProfilePage(),
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
          // name: OurWorksPage.name,
          builder: (context, state) => const ModernOurWorksPage(),
          // builder: (context, state) => const OurWorksPage(),
        ),
        //* Work Edit
        GoRoute(
          path: '/work-edit/:id',
          name: ModernWorkDetailPage.name,
          builder: (context, state) => ModernWorkDetailPage(
          // name: OurWorkEditPage.name,
          // builder: (context, state) => OurWorkEditPage(
            workId: state.params['id'] ?? 'no-id'
          ),
        ),

        //* AdminZone
        //* ConfigMessagesPage
        GoRoute(
          path: '/messages',
          name:  ModernMessagesPage.name,
          builder: (context, state) => const ModernMessagesPage(),
          // name:  MessagesPage.name,
          // builder: (context, state) => const MessagesPage(),
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
          builder: (context, state) => ModernMessageResponsePage(
            messageId: state.params['id'] ?? 'no-id'
          ),
          // name: ContactTicketsPage.name,
          // builder: (context, state) => const ContactTicketsPage(),
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


        
      ],

    redirect: (context, state) {

      final isGoingTo = state.subloc;
      final authStatus = goRouterNotifier.authStatus;

      // Permitir acceso a la página de detalles del servicio sin autenticación
      if (isGoingTo.startsWith('/service/')  && authStatus != AuthStatus.authenticated) {
        return null; // No redirigir, permitir el acceso
      }

      if ( isGoingTo == '/splash' && authStatus == AuthStatus.checking ) return null;

      if ( authStatus == AuthStatus.notAuthenticated ) {
        if ( isGoingTo == '/' || isGoingTo == '/login' || isGoingTo == '/register' || isGoingTo == '/reset-password' || isGoingTo == '/services' || isGoingTo == '/service/:id' || isGoingTo == '/our-works' || isGoingTo == '/reservations' || isGoingTo == '/products' || isGoingTo == '/product/:id' || isGoingTo == '/shoping-cart' || isGoingTo == '/checkout' || isGoingTo == '/payment-methods' || isGoingTo == '/help' || isGoingTo == '/about-us') return null;

        return '/';
      }

      if ( authStatus == AuthStatus.authenticated ) {
        if ( isGoingTo == '/login' || isGoingTo == '/register' || isGoingTo == '/splash' || isGoingTo == '/reset-password' ){
          return '/';
        }
      }

      return null;
    }
  );
});
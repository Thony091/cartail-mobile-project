import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/home/views/admin_body_home_view.dart';
import 'package:portafolio_project/features/home/views/operator_body_home_view.dart';
import 'package:portafolio_project/features/home/views/user_body_home_view.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'package:portafolio_project/features/services/presentation/providers/services_provider.dart';
import 'package:portafolio_project/features/category/presentation/providers/categories_provider.dart';
import 'package:portafolio_project/features/message/presentation/providers/messages_provider.dart';
import 'package:portafolio_project/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:portafolio_project/features/ticket/presentation/providers/tickets_provider.dart';
import 'package:portafolio_project/features/realized_work/presentation/providers/works_provider.dart';
import 'package:portafolio_project/features/vehicle/presentation/providers/vehicles_provider.dart';
import 'package:portafolio_project/features/slot/presentation/providers/slots_provider.dart';

class ModernHomePage extends ConsumerStatefulWidget {
  static const name = 'ModernHomePage';

  const ModernHomePage({super.key});

  @override
  ModernHomePageState createState() => ModernHomePageState();
}

class ModernHomePageState extends ConsumerState<ModernHomePage> {
  late final ProviderSubscription _authListener;

  Future<void> _refreshHome() async {
    final authState = ref.read(betterAuthProvider);
    if (!authState.isAuthenticated) {
      await Future.wait([
        ref.read(servicesProvider.notifier).getServices(),
        ref.read(categoriesProvider.notifier).getCategories(),
      ]);
      return;
    }

    if (authState.isAdmin) {
      await Future.wait([
        ref.read(servicesProvider.notifier).getServices(),
        ref.read(messagesProvider.notifier).getMessages(),
        ref.read(reservationProvider.notifier).getReservations(),
        ref.read(ticketsProvider.notifier).getTickets(),
        ref.read(worksProvider.notifier).getWorks(),
        ref.read(vehiclesProvider.notifier).getVehicles(),
        ref.read(slotsProvider.notifier).getSlots(),
        ref.read(categoriesProvider.notifier).getCategories(),
      ]);
      return;
    }

    if (authState.isOperator) {
      await Future.wait([
        ref.read(ticketsProvider.notifier).getTickets(),
        ref.read(worksProvider.notifier).getWorks(),
      ]);
      return;
    }

    await Future.wait([
      ref.read(servicesProvider.notifier).getServices(),
      ref.read(categoriesProvider.notifier).getCategories(),
    ]);
  }

  @override
  void initState() {
    super.initState();

    _authListener = ref.listenManual(
      betterAuthProvider,
      (previous, next) {
        final wasLoggedOut =
            previous?.isAuthenticated == false &&
            next.isAuthenticated == true;

        if (wasLoggedOut) {
          FirebaseAnalytics.instance.logEvent(
            name: 'login_success',
            parameters: {
              'role': next.isAdmin
                ? 'admin'
                : next.isOperator
                  ? 'operator'
                  : 'user',
            },
          );

          FirebaseCrashlytics.instance.setUserIdentifier(
            next.session!.user.id,
          );
        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(betterAuthProvider);

    return PopScope(
      canPop: false,
      child: ModernScaffoldWithDrawer(
        title: authState.isAuthenticated
            ? 'Hola ${authState.session!.user.name}'
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
          child: RefreshIndicator(
            onRefresh: _refreshHome,
            child: SingleChildScrollView(
              keyboardDismissBehavior: 
                ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (authState.isAuthenticated)
                    authState.isAdmin
                      ? const AdminBodyHomeView()
                      : authState.isOperator
                        ? const OperatorBodyHomeView()
                        : const UserBodyHomeView()
                  else
                    const UserBodyHomeView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

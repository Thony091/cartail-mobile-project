import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/admin_auth_provider.dart';
import 'package:portafolio_project/features/home/views/components/components.dart';
import 'package:portafolio_project/features/message/presentation/providers/messages_provider.dart';
import 'package:portafolio_project/features/services/presentation/providers/services_provider.dart';
import 'package:portafolio_project/features/shared/presentation/shared/shared.dart';
import 'package:portafolio_project/features/ticket/presentation/providers/tickets_provider.dart';
import 'package:portafolio_project/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:portafolio_project/features/realized_work/presentation/providers/works_provider.dart';
import 'package:portafolio_project/features/vehicle/presentation/providers/vehicles_provider.dart';

class AdminBodyHomeView extends ConsumerWidget {
  const AdminBodyHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final serviceState = ref.watch( servicesProvider );
    final messageState = ref.watch( messagesProvider );
    final reservationState = ref.watch( reservationProvider );
    final ticketState = ref.watch( ticketsProvider );
    final worksState = ref.watch( worksProvider );
    final vehiclesState = ref.watch( vehiclesProvider );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header del admin
          FadeInDown(
            child: ModernCard(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498db).withValues(alpha: .3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Panel de Administración',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestiona tu negocio desde aquí',
                    style: TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Estadísticas rápidas
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: serviceState.services.length.toString(),
                    label: 'Servicios',
                    icon: Icons.build,
                    color: const Color(0xFF3498db),
                    modalType: DashboardModalType.services,
                  ),
                ),
                const SizedBox(width: 16),
                 Expanded(
                  child: StatCardWidget(
                    value: reservationState.reservations.length.toString(),
                    label: 'Reservas',
                    icon: Icons.calendar_today,
                    color: const Color(0xFFf39c12),
                    modalType: DashboardModalType.reservations,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child:  Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: worksState.works.length.toString(),
                    label: 'Trabajos',
                    icon: Icons.diamond,
                    color: const Color(0xFF9b59b6),
                    modalType: DashboardModalType.works,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: ticketState.tickets.length.toString(),
                    label: 'Tickets',
                    icon: Icons.check_circle,
                    color: const Color(0xFF27ae60),
                    modalType: DashboardModalType.tickets,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child:  Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: messageState.messages.length.toString(),
                    label: 'Mensajes',
                    icon: Icons.mail,
                    color: const Color(0xFFe74c3c),
                    modalType: DashboardModalType.messages,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: '0',
                    label: 'Operarios',
                    icon: Icons.people,
                    color: const Color(0xFF16a085),
                    modalType: DashboardModalType.operators,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: vehiclesState.vehicles.length.toString(),
                    label: 'Vehículos',
                    icon: Icons.directions_car,
                    color: const Color(0xFF8e44ad),
                    modalType: DashboardModalType.vehicles,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: StatCardWidget(
                    value: '0',
                    label: 'Espacios',
                    icon: Icons.schedule,
                    color: Color(0xFF2980b9),
                    modalType: DashboardModalType.slots,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Acciones rápidas del admin
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Servicios',
                      icon: Icons.car_repair,
                      style: ModernButtonStyle.primary,
                      onPressed: () => context.push('/admin-config-services'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Reservas',
                      icon: Icons.calendar_month,
                      style: ModernButtonStyle.warning,
                      onPressed: () =>
                          context.push('/admin-config-reservations'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Trabajos',
                      icon: Icons.diamond,
                      style: ModernButtonStyle.success,
                      onPressed: () => context.push('/admin-config-works'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Tickets',
                      icon: Icons.check_circle,
                      style: ModernButtonStyle.success,
                      onPressed: () => context.push('/admin-all-tickets'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Mensajes',
                      icon: Icons.message,
                      style: ModernButtonStyle.secondary,
                      onPressed: () => context.push('/messages'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Usuarios',
                      icon: Icons.people_alt,
                      style: ModernButtonStyle.primary,
                      onPressed: () => context.push('/admin-users'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Categorías',
                      icon: Icons.category,
                      style: ModernButtonStyle.primary,
                      onPressed: () => context.push('/admin-config-categories'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Vehículos',
                      icon: Icons.directions_car,
                      style: ModernButtonStyle.secondary,
                      onPressed: () => context.push('/admin-config-vehicles'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Gestión de Espacios',
                      icon: Icons.schedule,
                      style: ModernButtonStyle.secondary,
                      onPressed: () => context.push('/admin-config-slots'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

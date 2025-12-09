import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/auth/home/views/components/components.dart';
import 'package:portafolio_project/presentation/shared/shared.dart';

class AdminBodyHomeView extends StatelessWidget {
  const AdminBodyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Estadísticas rápidas
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: const Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: '24',
                    label: 'Servicios',
                    icon: Icons.build,
                    color: Color(0xFF3498db),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: '89',
                    label: 'Reservas',
                    icon: Icons.calendar_today,
                    color: Color(0xFFf39c12),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: const Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: '156',
                    label: 'Completados',
                    icon: Icons.check_circle,
                    color: Color(0xFF27ae60),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: '12',
                    label: 'Mensajes',
                    icon: Icons.mail,
                    color: Color(0xFFe74c3c),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Acciones rápidas del admin
          FadeInUp(
            delay: const Duration(milliseconds: 300),
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
                      onPressed: () => context.push('/admin-config-reservations'),
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
                      text: 'Gestión de Productos',
                      icon: Icons.store_mall_directory,
                      style: ModernButtonStyle.success,
                      onPressed: () => context.push('/admin-config-products'),
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
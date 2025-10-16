import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'package:portafolio_project/presentation/providers/auth_provider.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';

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
                const Color(0xFF667eea).withOpacity(0.1),
                const Color(0xFFf8fafc),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if ( authState.authStatus == AuthStatus.authenticated && authState.userData!.isAdmin )
                  _buildAdminView()
                else
                  _buildUserView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminView() {
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
                          color: const Color(0xFF3498db).withOpacity(0.3),
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
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '24',
                    'Servicios',
                    Icons.build,
                    const Color(0xFF3498db),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '89',
                    'Reservas',
                    Icons.calendar_today,
                    const Color(0xFFf39c12),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '156',
                    'Completados',
                    Icons.check_circle,
                    const Color(0xFF27ae60),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '12',
                    'Mensajes',
                    Icons.mail,
                    const Color(0xFFe74c3c),
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

  Widget _buildUserView() {
    return Column(
      children: [
        // Hero section
        FadeInDown(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'DriveTail',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Detailing Center',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transformamos tu vehículo en una obra maestra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              
              // Servicios destacados
              FadeInLeft(
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nuestros Servicios',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'El detailing es el conjunto de técnicas centradas en la limpieza perfecta del vehículo sin causar deterioro de los materiales que lo componen.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildServiceHighlight(
                        Icons.auto_awesome,
                        'Detailing Profesional',
                        'Limpieza y cuidado experto para tu vehículo',
                        const Color(0xFF3498db),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildServiceHighlight(
                        Icons.build_circle,
                        'Mantenimiento Mecánico',
                        'Reparaciones y mantenimiento preventivo',
                        const Color(0xFFe74c3c),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildServiceHighlight(
                        Icons.format_paint,
                        'Pintura y Carrocería',
                        'Restauración y pintura profesional',
                        const Color(0xFFf39c12),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Ver Todos los Servicios',
                          icon: Icons.arrow_forward,
                          onPressed: () => context.push('/services'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Por qué elegirnos
              FadeInRight(
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿Por qué elegirnos?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFeatureItem(
                        Icons.verified,
                        'Calidad Garantizada',
                        'Los más altos estándares en cada servicio',
                      ),
                      
                      _buildFeatureItem(
                        Icons.schedule,
                        'Agenda Flexible',
                        'Reserva cuando más te convenga',
                      ),
                      
                      _buildFeatureItem(
                        Icons.people,
                        'Equipo Profesional',
                        'Técnicos certificados y experimentados',
                      ),
                      
                      _buildFeatureItem(
                        Icons.workspace_premium,
                        'Productos Premium',
                        'Utilizamos solo productos de alta calidad',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Llamado a la acción
              FadeInUp(
                child: ModernCard(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF27ae60).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          size: 40,
                          color: Color(0xFF27ae60),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¿Listo para comenzar?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Agenda tu cita ahora y transforma tu vehículo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Agendar Cita',
                          icon: Icons.calendar_today,
                          style: ModernButtonStyle.success,
                          onPressed: () => context.push('/reservations'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Ver Nuestros Trabajos',
                          icon: Icons.photo_library,
                          style: ModernButtonStyle.secondary,
                          onPressed: () => context.push('/our-works'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return ModernCard(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHighlight(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2c3e50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7f8c8d),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3498db),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
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
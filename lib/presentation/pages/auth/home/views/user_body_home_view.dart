import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/pages/auth/home/views/components/components.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

class UserBodyHomeView extends StatelessWidget {
  const UserBodyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFF667eea).withValues(alpha: .3),
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
                    color: Colors.white.withValues(alpha: .2),
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
                      
                      const ServiceHighlightWidget(
                        icon: Icons.auto_awesome,
                        title: 'Detailing Profesional',
                        description: 'Limpieza y cuidado experto para tu vehículo',
                        color: Color(0xFF3498db),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const ServiceHighlightWidget(
                        icon: Icons.build_circle,
                        title: 'Mantenimiento Mecánico',
                        description: 'Reparaciones y mantenimiento preventivo',
                        color: Color(0xFFe74c3c),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const ServiceHighlightWidget(
                        icon: Icons.format_paint,
                        title: 'Pintura y Carrocería',
                        description: 'Restauración y pintura profesional',
                        color: Color(0xFFf39c12),
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
                child: const ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Por qué elegirnos?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      FeatureItemWidget(
                        icon: Icons.verified,
                        title: 'Calidad Garantizada',
                        description: 'Los más altos estándares en cada servicio',
                      ),
                      
                      FeatureItemWidget(
                        icon: Icons.schedule,
                        title: 'Agenda Flexible',
                        description: 'Reserva cuando más te convenga',
                      ),
                      
                      FeatureItemWidget(
                        icon: Icons.people,
                        title: 'Equipo Profesional',
                        description: 'Técnicos certificados y experimentados',
                      ),
                      
                      FeatureItemWidget(
                        icon: Icons.workspace_premium,
                        title: 'Productos Premium',
                        description: 'Utilizamos solo productos de alta calidad',
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
                          color: const Color(0xFF27ae60).withValues(alpha: .1),
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
}
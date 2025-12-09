import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation_container.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernHelpPage extends StatelessWidget {
  static const name = 'ModernHelpPage';
  
  const ModernHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScaffoldWithDrawer(
      title: 'Centro de Ayuda',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withValues(alpha: 0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                child: const Text(
                  'Centro de Ayuda',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Encuentra respuestas a las preguntas más frecuentes',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Búsqueda
              FadeInLeft(
                child: const ModernInputField(
                  hint: 'Buscar en la ayuda...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Categorías de ayuda
              FadeInRight(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temas de Ayuda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    HelpCategoryWidget(
                      title: 'Servicios',
                      subtitle: 'Información sobre nuestros servicios de detailing',
                      icon: Icons.build,
                      color: Color(0xFF3498db),
                      questions: [
                        '¿Qué incluye el servicio de detailing premium?',
                        '¿Cuánto tiempo toma cada servicio?',
                        '¿Qué productos utilizan?',
                        '¿Ofrecen garantía en sus servicios?',
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    HelpCategoryWidget(
                      title: 'Reservas',
                      subtitle: 'Todo sobre cómo agendar y gestionar citas',
                      icon: Icons.calendar_today,
                      color: Color(0xFF27ae60),
                      questions: [
                        '¿Cómo puedo agendar una cita?',
                        '¿Puedo cancelar mi reserva?',
                        '¿Con cuánta anticipación debo reservar?',
                        '¿Qué pasa si llego tarde?',
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    HelpCategoryWidget(
                      title: 'Pagos',
                      subtitle: 'Métodos de pago y facturación',
                      icon: Icons.payment,
                      color: Color(0xFFf39c12),
                      questions: [
                        '¿Qué métodos de pago aceptan?',
                        '¿Puedo pagar en cuotas?',
                        '¿Emiten factura?',
                        '¿Manejan planes corporativos?',
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    HelpCategoryWidget(
                      title: 'Cuenta',
                      subtitle: 'Gestión de tu perfil y configuraciones',
                      icon: Icons.person,
                      color: Color(0xFFe74c3c),
                      questions: [
                        '¿Cómo cambio mi contraseña?',
                        '¿Cómo actualizo mis datos?',
                        '¿Puedo eliminar mi cuenta?',
                        '¿Cómo recupero mi contraseña?',
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Contacto
              FadeInUp(
                child: ModernCard(
                  child: Column(
                    children: [
                      const Text(
                        '¿No encontraste lo que buscabas?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Nuestro equipo de soporte está listo para ayudarte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: (){}, 
                            label: const Text(
                              'Contactar',
                              style: TextStyle(fontSize: 14)
                            ),
                            icon: const Icon(Icons.email),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: const Color(0xFF3498db),
                            )
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: (){}, 
                            label: const Text(
                              'WhatsApp', 
                              style: TextStyle(fontSize: 14)
                            ),
                            icon: const Icon(Icons.message),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: const Color(0xFF27ae60),
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class HelpCategoryWidget extends ConsumerWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> questions;
  const HelpCategoryWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.questions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModernCard(
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2c3e50),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7f8c8d),
          ),
        ),
        children: questions.map((question) {
          return ListTile(
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2c3e50),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF7f8c8d),
              size: 16,
            ),
            onTap: () {
              // Navegar a respuesta específica
            },
          );
        }).toList(),
      ),
    );
  }
}
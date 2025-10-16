import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

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
              const Color(0xFF667eea).withOpacity(0.1),
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
                child: ModernInputField(
                  hint: 'Buscar en la ayuda...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Categorías de ayuda
              FadeInRight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temas de Ayuda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildHelpCategory(
                      'Servicios',
                      'Información sobre nuestros servicios de detailing',
                      Icons.build,
                      const Color(0xFF3498db),
                      [
                        '¿Qué incluye el servicio de detailing premium?',
                        '¿Cuánto tiempo toma cada servicio?',
                        '¿Qué productos utilizan?',
                        '¿Ofrecen garantía en sus servicios?',
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildHelpCategory(
                      'Reservas',
                      'Todo sobre cómo agendar y gestionar citas',
                      Icons.calendar_today,
                      const Color(0xFF27ae60),
                      [
                        '¿Cómo puedo agendar una cita?',
                        '¿Puedo cancelar mi reserva?',
                        '¿Con cuánta anticipación debo reservar?',
                        '¿Qué pasa si llego tarde?',
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildHelpCategory(
                      'Pagos',
                      'Métodos de pago y facturación',
                      Icons.payment,
                      const Color(0xFFf39c12),
                      [
                        '¿Qué métodos de pago aceptan?',
                        '¿Puedo pagar en cuotas?',
                        '¿Emiten factura?',
                        '¿Manejan planes corporativos?',
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildHelpCategory(
                      'Cuenta',
                      'Gestión de tu perfil y configuraciones',
                      Icons.person,
                      const Color(0xFFe74c3c),
                      [
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
                          SizedBox(width: 10),
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
                          // Expanded(
                          //   child: ModernButton(
                          //     text: 'Contactar',
                          //     icon: Icons.email,
                          //     onPressed: () {
                          //       // Navegar a contacto
                          //     },
                          //   ),
                          // ),
                          // const SizedBox(width: 12),
                          // Expanded(
                          //   child: ModernButton(
                          //     text: 'WhatsApp',
                          //     style: ModernButtonStyle.success,
                          //     icon: Icons.message,
                          //     onPressed: () {
                          //       // Abrir WhatsApp
                          //     },
                          //   ),
                          // ),
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

  Widget _buildHelpCategory(String title, String subtitle, IconData icon, Color color, List<String> questions) {
    return ModernCard(
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
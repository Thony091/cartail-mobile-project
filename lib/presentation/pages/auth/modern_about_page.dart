import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../presentation_container.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernAboutPage extends StatelessWidget {
  static const name = 'ModernAboutPage';
  
  const ModernAboutPage({super.key});
  _buildValueItem(IconData icon, String title, String subtitle, Color color) {
    return ModernCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffoldWithDrawer(
      title: 'Acerca de DriveTail',
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
            children: [
              // Logo y título principal
              FadeInDown(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF2c3e50), const Color(0xFF34495e)],
                        ),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DriveTail',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const Text(
                      'Centro Automotriz de Excelencia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Nuestra historia
              FadeInLeft(
                child: const ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuestra Historia',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'DriveTail nació en 2020 con la visión de revolucionar el cuidado automotriz en Chile. Comenzamos como un pequeño taller especializado en detailing y hoy somos el centro automotriz de confianza de miles de clientes.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2c3e50),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nuestro compromiso con la excelencia y la innovación nos ha llevado a expandir nuestros servicios, siempre manteniendo los más altos estándares de calidad.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2c3e50),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Valores
              FadeInRight(
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nuestros Valores',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildValueItem(
                        Icons.verified,
                        'Calidad',
                        'Nos comprometemos con la excelencia en cada servicio',
                        const Color(0xFF3498db),
                      ),
                      
                      _buildValueItem(
                        Icons.people,
                        'Confianza',
                        'Construimos relaciones duraderas con nuestros clientes',
                        const Color(0xFF27ae60),
                      ),
                      
                      _buildValueItem(
                        Icons.lightbulb,
                        'Innovación',
                        'Adoptamos las últimas tecnologías y técnicas',
                        const Color(0xFFf39c12),
                      ),
                      
                      _buildValueItem(
                        Icons.eco,
                        'Sostenibilidad',
                        'Cuidamos el medio ambiente en todos nuestros procesos',
                        const Color(0xFF2ecc71),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Estadísticas
              FadeInUp(
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildStatItem(
                        '24',
                        'Servicios',
                        Icons.build,
                        const Color(0xFF3498db),
                      ),
                      
                      _buildStatItem(
                        '156',
                        'Completados',
                        Icons.check_circle,
                        const Color(0xFF27ae60),
                      ),
                      
                      _buildStatItem(
                        '89',
                        'Reservas',
                        Icons.calendar_today,
                        const Color(0xFFf39c12),
                      ),
                      
                      _buildStatItem(
                        '12',
                        'Mensajes',
                        Icons.mail,
                        const Color(0xFFe74c3c),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Contacto
              FadeInDown(
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿No encontraste lo que buscabas?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nuestro equipo de soporte está listo para ayudarte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                          // Expanded(
                          //   child: ModernButton(
                          //     text: 'Contactar',
                          //     icon: Icons.email,
                          //     onPressed: () {
                          //       // Navegar a contacto
                          //     },
                          //   ),
                          // ),
                          // const SizedBox(width: 16),
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

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7f8c8d),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }  
}

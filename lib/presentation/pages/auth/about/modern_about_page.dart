import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:portafolio_project/presentation/pages/auth/about/components/stat_item_widget.dart';
import 'package:portafolio_project/presentation/pages/auth/about/components/value_item_widget.dart';

import '../../../presentation_container.dart';
import '../modern_scaffold_with_drawer.dart';

class ModernAboutPage extends StatelessWidget {
  static const name = 'ModernAboutPage';
  const ModernAboutPage({super.key});

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
              const Color(0xFF667eea).withValues(alpha: .1),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
                        ),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .2),
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
                child: const ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuestros Valores',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      SizedBox(height: 20),
                      ValueItemWidget(
                        icon: Icons.verified,
                        title: 'Calidad',
                        subtitle: 'Nos comprometemos con la excelencia en cada servicio',
                        color: Color(0xFF3498db),
                      ),
                      ValueItemWidget(
                        icon: Icons.people,
                        title: 'Confianza',
                        subtitle: 'Construimos relaciones duraderas con nuestros clientes',
                        color: Color(0xFF27ae60),
                      ),
                      ValueItemWidget(
                        icon: Icons.lightbulb,
                        title: 'Innovación',
                        subtitle: 'Adoptamos las últimas tecnologías y técnicas',
                        color: Color(0xFFf39c12),
                      ),
                      ValueItemWidget(
                        icon: Icons.eco,
                        title: 'Sostenibilidad',
                        subtitle: 'Cuidamos el medio ambiente en todos nuestros procesos',
                        color: Color(0xFF2ecc71),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Estadísticas
              FadeInUp(
                child: const ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      SizedBox(height: 20),
                      StatItemWidget(
                        value: '24',
                        label: 'Servicios',
                        icon: Icons.build,
                        color:Color(0xFF3498db),
                      ),
                      StatItemWidget(
                        value: '156',
                        label: 'Completados',
                        icon: Icons.check_circle,
                        color:Color(0xFF27ae60),
                      ),
                      StatItemWidget(
                        value: '89',
                        label: 'Reservas',
                        icon: Icons.calendar_today,
                        color:Color(0xFFf39c12),
                      ),
                      StatItemWidget(
                        value: '12',
                        label: 'Mensajes',
                        icon: Icons.mail,
                        color:Color(0xFFe74c3c),
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
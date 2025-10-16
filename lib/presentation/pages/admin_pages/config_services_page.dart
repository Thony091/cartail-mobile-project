import 'package:flutter/material.dart';

import '../../presentation_container.dart';

class ConfigServicesPage extends StatelessWidget {
  
  static const name = 'ConfigAdminServices';

  const ConfigServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,
        title: const Text('Configuración de Servicios'),
      ),
      body: const BackgroundImageWidget(
        opacity: 0.1,
        child: Text('Configuración de Servicios')
      ),
    );
  }
}
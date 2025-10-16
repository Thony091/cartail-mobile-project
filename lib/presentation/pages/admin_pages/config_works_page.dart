import 'package:flutter/material.dart';

import '../../presentation_container.dart';

class ConfigWorksPage extends StatelessWidget {

  static const name = 'ConfigAdminWorks';
  
  const ConfigWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,
        title: const Text('Configuración de Trabajos'),
      ),
      body: const BackgroundImageWidget(
        opacity: 0.1,
        child: Text('Configuración de Trabajos')
      ),
    );
  }
}
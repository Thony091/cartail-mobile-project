import 'package:flutter/material.dart';

class ConfigProductsPage extends StatelessWidget {

  static const name = 'ConfigAdminProducts';

  const ConfigProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar productos'),
      ),
      body: const Center(
        child: Text('Configurar productos'),
      ),
    );
  }
}
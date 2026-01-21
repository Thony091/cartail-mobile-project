import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/factura_provider.dart';

class ModernFacturaPage extends ConsumerWidget {
  const ModernFacturaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facturaState = ref.watch(facturaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Facturas')),
      body: facturaState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: facturaState.facturas.length,
              itemBuilder: (context, index) {
                final factura = facturaState.facturas[index];
                return ListTile(
                  title: Text(factura.description),
                  subtitle: Text(factura.id),
                  trailing: Text('\$${factura.total}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Todo: Implement creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

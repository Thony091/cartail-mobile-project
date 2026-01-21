import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/factura_datasource_impl.dart';
import '../../data/repositories/factura_repository_impl.dart';
import '../../domain/repositories/factura_repository.dart';
import '../../../../presentation/presentation_container.dart';

final facturaRepositoryProvider = Provider<FacturaRepository>((ref) {
  final accessToken = ref.watch(authProvider).token;

  final facturaRepository = FacturaRepositoryImpl(
    FacturaDatasourceImpl(accessToken: accessToken),
  );

  return facturaRepository;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/factura_datasource_impl.dart';
import '../../data/repositories/factura_repository_impl.dart';
import '../../domain/repositories/factura_repository.dart';
// import '../../../../presentation/presentation_container.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';

final facturaRepositoryProvider = Provider<FacturaRepository>((ref) {
  final accessToken = ref.watch(betterAuthProvider).token;

  final facturaRepository = FacturaRepositoryImpl(
    FacturaDatasourceImpl(accessToken: accessToken.toString() ),
  );

  return facturaRepository;
});

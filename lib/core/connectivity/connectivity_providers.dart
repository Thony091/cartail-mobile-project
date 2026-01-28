import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants/enviroment.dart';
import 'connectivity_service.dart';
import 'connectivity_status.dart';

/// Riverpod-friendly providers. Uses the `/auth/ok` endpoint which is
/// optimized for fast health checks and returns { ok: true } on success.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final dio = Dio(BaseOptions(baseUrl: Enviroment.baseUrl));
  final service = ConnectivityService(
    probe: HttpConnectivityProbe(dio: dio, path: '/auth/ok'),
  );
  service.start();
  ref.onDispose(service.stop);
  return service;
});

final connectivitySnapshotProvider = StreamProvider<ConnectivitySnapshot>((ref) {
  return ref.watch(connectivityServiceProvider).stream;
});

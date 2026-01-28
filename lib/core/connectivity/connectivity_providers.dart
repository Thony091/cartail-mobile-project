import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants/enviroment.dart';
import 'connectivity_service.dart';
import 'connectivity_status.dart';

/// Riverpod-friendly providers. Replace the probe path if your API exposes
/// a different health-check endpoint.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final dio = Dio(BaseOptions(baseUrl: Enviroment.baseUrl));
  final service = ConnectivityService(
    probe: HttpConnectivityProbe(dio: dio, path: '/health'),
  );
  service.start();
  ref.onDispose(service.stop);
  return service;
});

final connectivitySnapshotProvider = StreamProvider<ConnectivitySnapshot>((ref) {
  return ref.watch(connectivityServiceProvider).stream;
});

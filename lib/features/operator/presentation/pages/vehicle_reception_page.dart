import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'work_order_detail_page.dart';

/// Página de recepción de vehículo con checklist
class VehicleReceptionPage extends ConsumerWidget {
  static const name = 'VehicleReceptionPage';
  final String orderId;

  const VehicleReceptionPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkOrderDetailPage(orderId: orderId);
  }
}

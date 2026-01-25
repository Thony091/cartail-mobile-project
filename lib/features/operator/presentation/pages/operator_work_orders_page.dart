import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ticket/presentation/pages/operator_assigned_tickets_page.dart';

class OperatorWorkOrdersPage extends ConsumerWidget {
  static const name = 'OperatorWorkOrdersPage';

  const OperatorWorkOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const OperatorAssignedTicketsPage();
  }
}

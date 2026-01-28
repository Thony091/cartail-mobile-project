import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/domain/entities/auth_user.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/home/views/components/components.dart';
import 'package:portafolio_project/features/realized_work/presentation/providers/works_provider.dart';
import 'package:portafolio_project/features/shared/presentation/shared/shared.dart';
import 'package:portafolio_project/features/ticket/domain/entities/ticket.dart';
import 'package:portafolio_project/features/ticket/presentation/providers/tickets_provider.dart';

class OperatorBodyHomeView extends ConsumerWidget {
  const OperatorBodyHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(betterAuthProvider);
    final ticketsState = ref.watch(ticketsProvider);
    final worksState = ref.watch(worksProvider);
    final operator = authState.session?.user;
    final operatorId = operator?.id;
    final assignedTickets = operatorId == null
        ? const <Ticket>[]
        : ticketsState.tickets
            .where((ticket) => ticket.idUser == operatorId)
            .toList();
    final assignedInProgress =
        assignedTickets.where((ticket) => ticket.estado.id == 3).length;
    final assignedCompleted =
        assignedTickets
            .where((ticket) => ticket.estado.id == 4 || ticket.estado.id == 5)
            .length;
    final workInProgress =
        worksState.works.where((work) => work.isActive).length;
    final workCompleted =
        worksState.works.where((work) => !work.isActive).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInDown(
            child: _OperatorProfileCard(operator: operator),
          ),
          const SizedBox(height: 24),
          if (ticketsState.isLoading) ...[
            const LinearProgressIndicator(minHeight: 4),
            const SizedBox(height: 16),
          ],
          if (worksState.loading) ...[
            const LinearProgressIndicator(
              minHeight: 4,
              color: Color(0xFF34a853),
            ),
            const SizedBox(height: 16),
          ],
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: assignedTickets.length.toString(),
                    label: 'Tickets asignados',
                    icon: Icons.assignment_ind,
                    color: const Color(0xFF2980b9),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: assignedInProgress.toString(),
                    label: 'En progreso',
                    icon: Icons.work,
                    color: const Color(0xFFf39c12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Expanded(
                  child: StatCardWidget(
                    value: assignedCompleted.toString(),
                    label: 'Tickets cerrados',
                    icon: Icons.check_circle,
                    color: const Color(0xFF27ae60),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: workInProgress.toString(),
                    label: 'Trabajos en curso',
                    icon: Icons.precision_manufacturing,
                    color: const Color(0xFF9b59b6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCardWidget(
                    value: workCompleted.toString(),
                    label: 'Trabajos terminados',
                    icon: Icons.done_all,
                    color: const Color(0xFF16a085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _AssignedTicketsCard(
              tickets: assignedTickets,
              isLoading: ticketsState.isLoading,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            child: _WorkSummaryCard(
              total: worksState.works.length,
              inProgress: workInProgress,
              completed: workCompleted,
              error: worksState.error,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _QuickActionsCard(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OperatorProfileCard extends StatelessWidget {
  final AuthUser? operator;

  const _OperatorProfileCard({
    required this.operator,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = operator?.name ?? operator?.email ?? 'Operario';
    final roleLabel = operator?.role.name == 'operator'
        ? 'Operario'
        : operator?.role.name.capitalize ?? 'Operario';

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1abc9c), Color(0xFF16a085)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.engineering,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel Operario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7f8c8d),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          if (operator?.phone != null && operator!.phone!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Color(0xFF1abc9c)),
                const SizedBox(width: 8),
                Text(
                  operator!.phone!,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          if (operator?.bio != null && operator!.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              operator!.bio!,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7f8c8d)),
            ),
          ],
        ],
      ),
    );
  }
}

class _AssignedTicketsCard extends StatelessWidget {
  final List<Ticket> tickets;
  final bool isLoading;

  const _AssignedTicketsCard({
    required this.tickets,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tickets asignados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/my-assigned-tickets'),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (tickets.isEmpty)
            const Text(
              'Aún no tienes tickets asignados.',
              style: TextStyle(color: Color(0xFF7f8c8d)),
            )
          else ...tickets
              .take(3)
              .map(
                (ticket) => Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.blue.withOpacity(0.12),
                        child: const Icon(
                          Icons.confirmation_number,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        ticket.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        ticket.estado.nombre.isNotEmpty
                            ? ticket.estado.nombre
                            : 'Estado ${ticket.estado.id}',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () => context.push('/my-assigned-tickets'),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _WorkSummaryCard extends StatelessWidget {
  final int total;
  final int inProgress;
  final int completed;
  final String error;

  const _WorkSummaryCard({
    required this.total,
    required this.inProgress,
    required this.completed,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de trabajos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusRow('Total', total.toString(), const Color(0xFF34495e)),
          const SizedBox(height: 8),
          _buildStatusRow(
            'En curso',
            inProgress.toString(),
            const Color(0xFFf39c12),
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Terminados',
            completed.toString(),
            const Color(0xFF27ae60),
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color.withOpacity(.8)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos directos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          // const SizedBox(height: 20),
          // SizedBox(
          //   width: double.infinity,
          //   child: ModernButton(
          //     text: 'Abrir mis tickets',
          //     icon: Icons.label,
          //     style: ModernButtonStyle.warning,
          //     onPressed: () => context.push('/my-assigned-tickets'),
          //   ),
          // ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: 'Órdenes de trabajo',
              icon: Icons.precision_manufacturing,
              style: ModernButtonStyle.primary,
              onPressed: () => context.push('/operator/work-orders'),
            ),
          ),
          // const SizedBox(height: 12),
          // SizedBox(
          //   width: double.infinity,
          //   child: ModernButton(
          //     text: 'Actualizar estado',
          //     icon: Icons.refresh,
          //     style: ModernButtonStyle.secondary,
          //     onPressed: () => context.push('/operator/work-orders'),
          //   ),
          // ),
        ],
      ),
    );
  }
}

extension on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get capitalizeFirst => split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
}

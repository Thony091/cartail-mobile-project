import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/features/auth/presentation/providers/better_auth_provider.dart';
import 'package:portafolio_project/features/home/views/components/components.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

class UserBodyHomeView extends StatelessWidget {
  const UserBodyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero section
        FadeInDown(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withValues(alpha: .3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'DriveTail',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Detailing Center',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transformamos tu vehículo en una obra maestra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Servicios destacados
              FadeInLeft(
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nuestros Servicios',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'El detailing es el conjunto de técnicas centradas en la limpieza perfecta del vehículo sin causar deterioro de los materiales que lo componen.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const ServiceHighlightWidget(
                        icon: Icons.auto_awesome,
                        title: 'Detailing Profesional',
                        description:
                            'Limpieza y cuidado experto para tu vehículo',
                        color: Color(0xFF3498db),
                      ),

                      const SizedBox(height: 16),

                      const ServiceHighlightWidget(
                        icon: Icons.build_circle,
                        title: 'Mantenimiento Mecánico',
                        description: 'Reparaciones y mantenimiento preventivo',
                        color: Color(0xFFe74c3c),
                      ),

                      const SizedBox(height: 16),

                      const ServiceHighlightWidget(
                        icon: Icons.format_paint,
                        title: 'Pintura y Carrocería',
                        description: 'Restauración y pintura profesional',
                        color: Color(0xFFf39c12),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Ver Todos los Servicios',
                          icon: Icons.arrow_forward,
                          onPressed: () => context.push('/services'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Por qué elegirnos
              FadeInRight(
                child: const ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Por qué elegirnos?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      SizedBox(height: 20),

                      FeatureItemWidget(
                        icon: Icons.verified,
                        title: 'Calidad Garantizada',
                        description:
                            'Los más altos estándares en cada servicio',
                      ),

                      FeatureItemWidget(
                        icon: Icons.schedule,
                        title: 'Agenda Flexible',
                        description: 'Reserva cuando más te convenga',
                      ),

                      FeatureItemWidget(
                        icon: Icons.people,
                        title: 'Equipo Profesional',
                        description: 'Técnicos certificados y experimentados',
                      ),

                      FeatureItemWidget(
                        icon: Icons.workspace_premium,
                        title: 'Productos Premium',
                        description:
                            'Utilizamos solo productos de alta calidad',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Llamado a la acción
              FadeInUp(
                child: ModernCard(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF27ae60).withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          size: 40,
                          color: Color(0xFF27ae60),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¿Listo para comenzar?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Agenda tu cita ahora y transforma tu vehículo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Agendar Cita',
                          icon: Icons.calendar_today,
                          style: ModernButtonStyle.success,
                          onPressed: () => context.push('/reservations'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ModernButton(
                          text: 'Ver Nuestros Trabajos',
                          icon: Icons.photo_library,
                          style: ModernButtonStyle.secondary,
                          onPressed: () => context.push('/our-works'),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
              const SizedBox(height: 24),
              FadeInUp(
                child: const MessageFormCard(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessageFormCard extends ConsumerStatefulWidget {
  const MessageFormCard({super.key});

  @override
  ConsumerState<MessageFormCard> createState() => _MessageFormCardState();
}

class _MessageFormCardState extends ConsumerState<MessageFormCard> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _messageController = TextEditingController();

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  void _populateAuthenticatedFields() {
    final authState = ref.read(betterAuthProvider);
    if (authState.isAuthenticated) {
      final name = authState.session!.user.name ?? '';
      final email = authState.session!.user.email;

      _nameController.text = name;
      _emailController.text = email;

      // Sync with provider state after widget tree is done building
      Future.microtask(() {
        ref.read(messageFormProvider.notifier).onNameChange(name);
        ref.read(messageFormProvider.notifier).onEmailChange(email);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    // Populate with authenticated user data if available
    Future.microtask(() => _populateAuthenticatedFields());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(messageFormProvider.notifier);
    final authState = ref.read(betterAuthProvider);
    final success = await notifier.postMessage();
    if (success && mounted) {
      if (authState.isAuthenticated) {
        // Only clear message field for authenticated users
        _messageController.clear();
        notifier.resetMessageOnly();
        // Repopulate authenticated fields
        _populateAuthenticatedFields();
      } else {
        // Clear all fields for non-authenticated users
        _clearFields();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensaje enviado. Gracias por contactarnos.'),
          backgroundColor: Color(0xFF27ae60),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(messageFormProvider);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Quieres contarnos algo?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Envía un mensaje y nuestros administradores te responderán.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7f8c8d),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              errorText: formState.name.errorMessage,
            ),
            onChanged: (value) =>
                ref.read(messageFormProvider.notifier).onNameChange(value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              errorText: formState.email.errorMessage,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) =>
                ref.read(messageFormProvider.notifier).onEmailChange(value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Mensaje',
              errorText: formState.message.errorMessage,
            ),
            maxLines: 4,
            onChanged: (value) =>
                ref.read(messageFormProvider.notifier).onMessageChange(value),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ModernButton(
              text: formState.isPosting ? 'Enviando...' : 'Enviar mensaje',
              isLoading: formState.isPosting,
              onPressed: formState.isPosting ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailto/mailto.dart';
import 'package:portafolio_project/presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:portafolio_project/features/message/presentation/pages/modern_message_response_widgets.dart';
import '../providers/message_provider.dart';
import '../../domain/entities/message.dart';

import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';

class ModernMessageResponsePage extends ConsumerStatefulWidget {
  final String messageId;
  static const name = 'ModernMessageResponsePage';

  const ModernMessageResponsePage({super.key, required this.messageId});

  @override
  ModernMessageResponsePageState createState() =>
      ModernMessageResponsePageState();
}

class ModernMessageResponsePageState
    extends ConsumerState<ModernMessageResponsePage> {
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider(widget.messageId));
    final message = messageState.message;

    return ModernScaffoldWithDrawer(
      title: 'Responder Mensaje',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.email, color: Colors.white),
          tooltip: 'Abrir en cliente de correo',
          onPressed: message == null ? null : () => _openInEmailClient(message),
        ),
      ],
      body: messageState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : message == null
              ? const Center(child: Text('No se encontró el mensaje'))
              : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del mensaje original
              FadeInDown(child: OriginalMessageCard(message: message)),

              const SizedBox(height: 24),

              // Editor de respuesta
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: ResponseEditor(
                  message: message,
                  responseController: _responseController,
                  focusNode: _focusNode,
                  isSending: _isSending,
                  onSaveDraft: _saveDraft,
                  onSendResponse: () => _sendResponse(message),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _saveDraft() {
    // Guardar borrador de respuesta
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Borrador guardado'),
        backgroundColor: Color(0xFF3498db),
      ),
    );
  }

  Future<void> _sendResponse(Message message) async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe una respuesta'),
          backgroundColor: Color(0xFFe74c3c),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final mailtoLink = Mailto(
        to: [message.email],
        subject: 'Re: Tu mensaje - DriveTail',
        body: _responseController.text,
      );

      final uri = Uri.parse(mailtoLink.toString());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);

        // Marcar como respondido
        // ref.read(messageProvider(widget.messageId).notifier).markAsReplied();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente de correo abierto'),
              backgroundColor: Color(0xFF27ae60),
            ),
          );

          // Volver a la lista de mensajes después de un delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.pop();
            }
          });
        }
      } else {
        throw 'No se pudo abrir el cliente de correo';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: const Color(0xFFe74c3c),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _openInEmailClient(Message message) async {
    final mailtoLink = Mailto(
      to: [message.email],
      subject: 'Re: Tu mensaje - DriveTail',
    );

    final uri = Uri.parse(mailtoLink.toString());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

}

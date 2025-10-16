import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';
import '../auth/modern_scaffold_with_drawer.dart';


class ModernMessageResponsePage extends ConsumerStatefulWidget {
  final String messageId;
  static const name = 'ModernMessageResponsePage';
  
  const ModernMessageResponsePage({
    super.key,
    required this.messageId,
  });

  @override
  ModernMessageResponsePageState createState() => ModernMessageResponsePageState();
}

class ModernMessageResponsePageState extends ConsumerState<ModernMessageResponsePage> {
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Cargar mensaje específico
    // ref.read(messageProvider(widget.messageId));
  }

  @override
  void dispose() {
    _responseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final messageState = ref.watch(messageProvider(widget.messageId));
    
    // Datos simulados para el ejemplo - reemplazar con messageState.message
    final message = _getSimulatedMessage();

    return ModernScaffoldWithDrawer(
      title: 'Responder Mensaje',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.email, color: Colors.white),
          tooltip: 'Abrir en cliente de correo',
          onPressed: () => _openInEmailClient(message),
        ),
      ],
      body: Container(
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
              FadeInDown(
                child: _buildOriginalMessageCard(message),
              ),
              
              const SizedBox(height: 24),
              
              // Editor de respuesta
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildResponseEditor(message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginalMessageCard(MessageResponseData message) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498db).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF3498db),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 14,
                            color: Color(0xFF7f8c8d),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              message.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7f8c8d),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: message.isRead
                        ? const Color(0xFF27ae60).withOpacity(0.1)
                        : const Color(0xFF3498db).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        message.isRead ? Icons.check_circle : Icons.circle,
                        size: 14,
                        color: message.isRead
                            ? const Color(0xFF27ae60)
                            : const Color(0xFF3498db),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.isRead ? 'Leído' : 'Nuevo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: message.isRead
                              ? const Color(0xFF27ae60)
                              : const Color(0xFF3498db),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Color(0xFF7f8c8d),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(message.date),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
                if (message.phone != null) ...[
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.phone,
                    size: 14,
                    color: Color(0xFF7f8c8d),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    message.phone!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7f8c8d),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            const Text(
              'Mensaje:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf8fafc),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.message,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2c3e50),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseEditor(MessageResponseData message) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498db).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF3498db),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tu Respuesta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Campo de texto para la respuesta
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _responseController,
                focusNode: _focusNode,
                maxLines: 12,
                decoration: InputDecoration(
                  hintText: 'Escribe tu respuesta aquí...\n\nHola ${message.name},\n\nGracias por contactarnos...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2c3e50),
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Plantillas rápidas
            const Text(
              'Plantillas rápidas:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTemplateChip(
                  'Saludo inicial',
                  'Hola ${message.name},\n\nGracias por contactarnos. ',
                ),
                _buildTemplateChip(
                  'Información recibida',
                  'Hemos recibido tu consulta y la estamos revisando. ',
                ),
                _buildTemplateChip(
                  'Despedida',
                  '\n\nSaludos cordiales,\nEquipo DriveTail',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Guardar Borrador',
                    style: ModernButtonStyle.secondary,
                    icon: Icons.save,
                    onPressed: _saveDraft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ModernButton(
                    text: _isSending ? 'Enviando...' : 'Enviar Respuesta',
                    icon: _isSending ? null : Icons.send,
                    onPressed: _isSending ? null : () => _sendResponse(message),
                    isLoading: _isSending,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String label, String text) {
    return InkWell(
      onTap: () {
        final currentText = _responseController.text;
        _responseController.text = currentText + text;
        _focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF3498db).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3498db).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 16,
              color: Color(0xFF3498db),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3498db),
              ),
            ),
          ],
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

  Future<void> _sendResponse(MessageResponseData message) async {
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

  Future<void> _openInEmailClient(MessageResponseData message) async {
    final mailtoLink = Mailto(
      to: [message.email],
      subject: 'Re: Tu mensaje - DriveTail',
    );

    final uri = Uri.parse(mailtoLink.toString());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} minutos';
      }
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      final months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  MessageResponseData _getSimulatedMessage() {
    return MessageResponseData(
      id: widget.messageId,
      name: 'Carlos Mendoza',
      email: 'carlos@email.com',
      phone: '+56 9 1234 5678',
      message: 'Hola, quisiera consultar por el servicio de detailing para mi auto. ¿Cuánto tiempo demora y cuál es el precio? También me gustaría saber si trabajan los fines de semana.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    );
  }
}

class MessageResponseData {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String message;
  final DateTime date;
  final bool isRead;

  MessageResponseData({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}

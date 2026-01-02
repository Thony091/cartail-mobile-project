import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/modern_card.dart';

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

class OriginalMessageCard extends StatelessWidget {
  final MessageResponseData message;

  const OriginalMessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.phone, size: 14, color: Color(0xFF7f8c8d)),
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
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}

class ResponseEditor extends StatelessWidget {
  final MessageResponseData message;
  final TextEditingController responseController;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSaveDraft;
  final VoidCallback onSendResponse;

  const ResponseEditor({
    super.key,
    required this.message,
    required this.responseController,
    required this.focusNode,
    required this.isSending,
    required this.onSaveDraft,
    required this.onSendResponse,
  });

  @override
  Widget build(BuildContext context) {
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
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: TextField(
                controller: responseController,
                focusNode: focusNode,
                maxLines: 12,
                decoration: InputDecoration(
                  hintText:
                      'Escribe tu respuesta aquí...\n\nHola ${message.name},\n\nGracias por contactarnos...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
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
                TemplateChip(
                  label: 'Saludo inicial',
                  text: 'Hola ${message.name},\n\nGracias por contactarnos. ',
                  responseController: responseController,
                  focusNode: focusNode,
                ),
                TemplateChip(
                  label: 'Información recibida',
                  text: 'Hemos recibido tu consulta y la estamos revisando. ',
                  responseController: responseController,
                  focusNode: focusNode,
                ),
                TemplateChip(
                  label: 'Despedida',
                  text: '\n\nSaludos cordiales,\nEquipo DriveTail',
                  responseController: responseController,
                  focusNode: focusNode,
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
                    onPressed: onSaveDraft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ModernButton(
                    text: isSending ? 'Enviando...' : 'Enviar Respuesta',
                    icon: isSending ? null : Icons.send,
                    onPressed: isSending ? null : onSendResponse,
                    isLoading: isSending,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TemplateChip extends StatelessWidget {
  final String label;
  final String text;
  final TextEditingController responseController;
  final FocusNode focusNode;

  const TemplateChip({
    super.key,
    required this.label,
    required this.text,
    required this.responseController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final currentText = responseController.text;
        responseController.text = currentText + text;
        focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF3498db).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3498db).withOpacity(0.3)),
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
}

import 'package:flutter/material.dart';
import '../../../shared/presentation/shared/widgets/modern_button.dart';
import '../../../shared/presentation/shared/widgets/modern_card.dart';
import '../../../shared/presentation/shared/widgets/modern_input_field.dart';
import '../../domain/entities/message.dart';

class MessageStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const MessageStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF7f8c8d)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;
  final Future<bool> Function(DismissDirection) onConfirmDismiss;

  const MessageCard({
    super.key,
    required this.message,
    required this.onTap,
    required this.onConfirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(message.id),
        direction: DismissDirection.horizontal,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3498db),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Icon(Icons.mark_email_read, color: Colors.white, size: 28),
            ),
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFe74c3c),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white, size: 28),
            ),
          ),
        ),
        confirmDismiss: onConfirmDismiss,
        child: ModernCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              message.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2c3e50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7f8c8d),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2c3e50),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageEmptyState extends StatelessWidget {
  const MessageEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.mail_outline,
              size: 60,
              color: Color(0xFF3498db),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay mensajes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando recibas mensajes aparecerán aquí',
            style: TextStyle(fontSize: 16, color: Color(0xFF7f8c8d)),
          ),
        ],
      ),
    );
  }
}

class SearchMessageDialog extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const SearchMessageDialog({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar Mensajes'),
      content: ModernInputField(
        hint: 'Buscar por nombre, email o contenido...',
        // autofocus: true,
        onChanged: onSearch,
      ),
      actions: [
        TextButton(
          onPressed: () {
            onSearch('');
            Navigator.of(context).pop();
          },
          child: const Text('Limpiar'),
        ),
        ModernButton(
          text: 'Buscar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class MessageDetailsSheet extends StatefulWidget {
  final Message message;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const MessageDetailsSheet({
    super.key,
    required this.message,
    required this.onReply,
    required this.onDelete,
  });

  @override
  State<MessageDetailsSheet> createState() => _MessageDetailsSheetState();
}

class _MessageDetailsSheetState extends State<MessageDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      Text(
                        widget.message.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Contenido del mensaje
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Text(
                  widget.message.message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2c3e50),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Acciones
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Responder',
                    icon: Icons.reply,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onReply();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ModernButton(
                  text: 'Eliminar',
                  style: ModernButtonStyle.danger,
                  icon: Icons.delete,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDelete();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReplyMessageDialog extends StatelessWidget {
  final Message message;
  final VoidCallback onSend;

  const ReplyMessageDialog({
    super.key,
    required this.message,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Responder a ${message.name}'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModernInputField(
            // controller: replyController,
            label: 'Tu respuesta',
            hint: 'Escribe tu respuesta...',
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ModernButton(
          text: 'Enviar',
          onPressed: () {
            Navigator.of(context).pop();
            onSend();
          },
        ),
      ],
    );
  }
}

class DeleteMessageDialog extends StatelessWidget {
  final Message message;

  const DeleteMessageDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar Mensaje'),
      content: Text(
        '¿Estás seguro de que deseas eliminar el mensaje de ${message.name}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ModernButton(
          text: 'Eliminar',
          style: ModernButtonStyle.danger,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

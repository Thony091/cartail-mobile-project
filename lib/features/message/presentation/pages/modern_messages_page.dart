import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_messages_widgets.dart';

class ModernMessagesPage extends StatefulWidget {
  static const name = 'ModernMessagesPage';

  const ModernMessagesPage({super.key});

  @override
  State<ModernMessagesPage> createState() => _ModernMessagesPageState();
}

class _ModernMessagesPageState extends State<ModernMessagesPage> {
  List<MessageData> _messages = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Simular carga de mensajes
    _messages = [
      MessageData(
        id: '1',
        name: 'Carlos Mendoza',
        email: 'carlos@email.com',
        message:
            'Hola, quisiera consultar por el servicio de detailing para mi auto. ¿Cuánto tiempo demora?',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      MessageData(
        id: '2',
        name: 'María González',
        email: 'maria@email.com',
        message:
            'Excelente servicio el que recibí la semana pasada. Mi auto quedó impecable. ¡Totalmente recomendado!',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      MessageData(
        id: '3',
        name: 'Pedro Silva',
        email: 'pedro@email.com',
        message:
            'Necesito cotizar un servicio de pintura completa para mi camioneta. ¿Pueden darme más información?',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isRead: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _messages.where((message) {
      if (_searchQuery.isEmpty) return true;
      return message.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          message.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          message.message.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ModernScaffoldWithDrawer(
      title: 'Gestión de Mensajes',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
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
        child: Column(
          children: [
            // Estadísticas
            Padding(
              padding: const EdgeInsets.all(20),
              child: FadeInDown(
                child: Row(
                  children: [
                    Expanded(
                      child: MessageStatCard(
                        value: '${_messages.where((m) => !m.isRead).length}',
                        label: 'Sin Leer',
                        icon: Icons.mark_email_unread,
                        color: const Color(0xFFe74c3c),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MessageStatCard(
                        value: '${_messages.length}',
                        label: 'Total',
                        icon: Icons.email,
                        color: const Color(0xFF3498db),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista de mensajes
            Expanded(
              child: filteredMessages.isEmpty
                  ? const MessageEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        _loadMessages();
                        setState(() {});
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredMessages.length,
                        itemBuilder: (context, index) {
                          final message = filteredMessages[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 100),
                            child: MessageCard(
                              message: message,
                              onTap: () => _showMessageDetail(message),
                              onConfirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  // Marcar como leído
                                  setState(() {
                                    message.isRead = true;
                                    _showMessageDetail(message);
                                  });
                                  return false;
                                } else {
                                  // Eliminar mensaje
                                  return await _showDeleteConfirmation(message);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchMessageDialog(
        onSearch: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  void _showMessageDetail(MessageData message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageDetailsSheet(
        message: message,
        onReply: () => _showReplyDialog(message),
        onDelete: () async {
          if (await _showDeleteConfirmation(message)) {
            setState(() {
              _messages.removeWhere((m) => m.id == message.id);
            });
          }
        },
        onMarkAsRead: () {
          setState(() {
            message.isRead = true;
          });
        },
      ),
    );
  }

  void _showReplyDialog(MessageData message) {
    showDialog(
      context: context,
      builder: (context) => ReplyMessageDialog(
        message: message,
        onSend: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta enviada'),
              backgroundColor: Color(0xFF27ae60),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(MessageData message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => DeleteMessageDialog(message: message),
        ) ??
        false;
  }
}

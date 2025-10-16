import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/widgets.dart';
import 'modern_scaffold_with_drawer.dart';

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
        message: 'Hola, quisiera consultar por el servicio de detailing para mi auto. ¿Cuánto tiempo demora?',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      MessageData(
        id: '2',
        name: 'María González',
        email: 'maria@email.com',
        message: 'Excelente servicio el que recibí la semana pasada. Mi auto quedó impecable. ¡Totalmente recomendado!',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      MessageData(
        id: '3',
        name: 'Pedro Silva',
        email: 'pedro@email.com',
        message: 'Necesito cotizar un servicio de pintura completa para mi camioneta. ¿Pueden darme más información?',
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
                      child: _buildStatCard(
                        '${_messages.where((m) => !m.isRead).length}',
                        'Sin Leer',
                        Icons.mark_email_unread,
                        const Color(0xFFe74c3c),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        '${_messages.length}',
                        'Total',
                        Icons.email,
                        const Color(0xFF3498db),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Lista de mensajes
            Expanded(
              child: filteredMessages.isEmpty
                  ? _buildEmptyState()
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
                            child: _buildMessageCard(message),
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

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7f8c8d),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(MessageData message) {
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
              child: Icon(
                Icons.mark_email_read, 
                color: Colors.white, 
                size: 28
              ),
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
              child: Icon(
                Icons.delete, 
                color: Colors.white, 
                size: 28
              ),
            ),
          ),
        ),
        confirmDismiss: (direction) async {
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
        child: ModernCard(
          onTap: () => _showMessageDetail(message),
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
                                fontWeight: message.isRead ? FontWeight.w500 : FontWeight.w700,
                                color: const Color(0xFF2c3e50),
                              ),
                            ),
                            if (!message.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFe74c3c),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
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
                  Text(
                    _formatDate(message.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7f8c8d),
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

  Widget _buildEmptyState() {
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
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7f8c8d),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Mensajes'),
        content: ModernInputField(
          hint: 'Buscar por nombre, email o contenido...',
          // autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpiar'),
          ),
          ModernButton(
            text: 'Buscar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showMessageDetail(MessageData message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                          message.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
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
                  Text(
                    _formatDate(message.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7f8c8d),
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
                    message.message,
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
                        _showReplyDialog(message);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ModernButton(
                    text: 'Eliminar',
                    style: ModernButtonStyle.danger,
                    icon: Icons.delete,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (await _showDeleteConfirmation(message)) {
                        setState(() {
                          _messages.removeWhere((m) => m.id == message.id);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
    // Marcar como leído al abrir
    if (!message.isRead) {
      setState(() {
        message.isRead = true;
      });
    }
  }

  void _showReplyDialog(MessageData message) {
    final replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              // Aquí enviarías el email
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Respuesta enviada'),
                  backgroundColor: Color(0xFF27ae60),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(MessageData message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mensaje'),
        content: Text('¿Estás seguro de que deseas eliminar el mensaje de ${message.name}?'),
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
      ),
    ) ?? false;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class MessageData {
  final String id;
  final String name;
  final String email;
  final String message;
  final DateTime date;
  bool isRead;

  MessageData({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.date,
    required this.isRead,
  });
}
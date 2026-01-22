import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/pages/auth/modern_scaffold_with_drawer.dart';
import 'modern_messages_widgets.dart';
import '../providers/messages_provider.dart';
import '../../domain/entities/message.dart';

class ModernMessagesPage extends ConsumerStatefulWidget {
  static const name = 'ModernMessagesPage';

  const ModernMessagesPage({super.key});

  @override
  ConsumerState<ModernMessagesPage> createState() =>
      _ModernMessagesPageState();
}

class _ModernMessagesPageState extends ConsumerState<ModernMessagesPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider);
    final messages = messagesState.messages;
    final filteredMessages = messages.where((message) {
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
                          value: '${messages.length}',
                          label: 'Recibidos',
                          icon: Icons.mark_email_unread,
                          color: const Color(0xFFe74c3c),
                        ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MessageStatCard(
                        value: '${messages.length}',
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
              child: messagesState.isLoading && messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMessages.isEmpty
                      ? const MessageEmptyState()
                      : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(messagesProvider.notifier).getMessages();
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

  void _showMessageDetail(Message message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageDetailsSheet(
        message: message,
        onReply: () => _showReplyDialog(message),
        onDelete: () async {
          if (await _showDeleteConfirmation(message)) {
            await ref.read(messagesProvider.notifier).deleteMessage(message.id);
          }
        },
      ),
    );
  }

  void _showReplyDialog(Message message) {
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

  Future<bool> _showDeleteConfirmation(Message message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => DeleteMessageDialog(message: message),
        ) ??
        false;
  }
}

import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portafolio_project/presentation/presentation_container.dart';

import '../../../config/config.dart';
import 'compornents/card_messages.dart';

class MessagesPage extends ConsumerWidget {

  static const name = 'MessagePage';
  
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final color = AppTheme().getTheme().colorScheme;
    final messageState = ref.watch( messagesProvider );
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primary,
        title: const Text('Mensajes de Contacto'),
        
      ),
      body:  BackgroundImageWidget(
        opacity: 0.1, 
        child: messageState.messages.isEmpty 
        ? FadeInRight(
          child: const Center(
              child: Text(
                'No hay mensajes en este momento', 
                style: TextStyle(fontSize: 17),
              )
            )
          )
        : const _MessageAdminPage(),
      ),
      drawer: SideMenu(scaffoldKey: scaffoldKey),
    );
  }
}

class _MessageAdminPage extends ConsumerStatefulWidget {
  const _MessageAdminPage();

  @override
  _MessageAdminPageState createState() => _MessageAdminPageState();
}

class _MessageAdminPageState extends ConsumerState {

  bool isTimeout = false;

  @override
  void initState() {
    super.initState();
    // Start the timer to wait for 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          isTimeout = true;
        });
      }
    });
  }

  void showSnackbar( BuildContext context ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje Eliminado')
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    final messageState = ref.watch( messagesProvider );
    
    return Padding(
      padding: const EdgeInsets.only( left: 20, top: 10),
      child:  ListView.builder(
        itemCount: messageState.messages.length,
        itemBuilder: ( context, index) {
          final message = messageState.messages[index];
          return Column(
            children:
              [
                FadeInRight(
                  child: MessageCard(
                    message: message,
                    onTapdResponse: () => context.push('/message-response/${message.id}'),
                    onTapDelete: () {
                      showDialog(
                        context: context, 
                        builder: (context){
                          return PopUpPreguntaWidget(
                            pregunta: '¿Estas seguro de eliminar el mensaje?', 
                            // confirmar: () {},
                            confirmar: () => ref.read(messagesProvider.notifier)
                              .deleteMessage(message.id)
                              .then((value) {
                                showSnackbar(context);
                                context.pop();
                              }), 
                            cancelar: () => context.pop()
                          );
                        }
                      );
                    } 
                  ),
                ),
                const SizedBox(height: 10),
              ] 
          );
        },
        
      ),
    );
  }
}
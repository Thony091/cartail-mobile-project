// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/config.dart';
import '../../../../domain/domain.dart';
import '../../../providers/providers.dart';
import '../../../shared/shared.dart';

class AdminCardService extends ConsumerStatefulWidget {

  final Services service;
  final Function()? onTapdEdit;
  final Function()? onTapDelete;

  const AdminCardService({
    super.key,
    required this.service,
    this.onTapdEdit,
    this.onTapDelete,
  });

  @override
  _AdminCardServiceState createState() => _AdminCardServiceState();
}

class _AdminCardServiceState extends ConsumerState<AdminCardService> {

  bool _isDismissed = false;
  bool isVisible = true;
  void showDeleteSnackbar( BuildContext context ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio Eliminado')
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if(_isDismissed){
      return Container();
    }
    return Dismissible(
      key: Key(widget.service.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.blueAccent[100],
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.edit, color: Colors.white, size: 35),
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white, size: 35),
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Acción cuando se desliza de izquierda a derecha (editar)
          widget.onTapdEdit?.call();
          await Future.delayed(const Duration(milliseconds: 300)); // Espera que la animación termine
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // Acción cuando se desliza de derecha a izquierda (eliminar)
          // final shouldDelete = await widget.onTapDelete?.call() ?? false;
          // final shouldDelete = await _showConfirmationDialog(context);
          // if (shouldDelete) {
          //   widget.onTapDelete?.call();
          //   setState(() {
          //     _isDismissed = true;
          //   });
          // }
          // return shouldDelete;
          showDialog(
            context: context, 
            builder: (context){
              return PopUpPreguntaWidget(
                pregunta: '¿Estas seguro de eliminar el servicio?',
                // confirmar: () {},
                confirmar: () => ref.read(servicesProvider.notifier)
                  .deleteService(widget.service.id)
                  .then((value) {
                    showDeleteSnackbar(context);
                    context.pop();
                  }), 
                cancelar: () => context.pop()
              );
            }
          );
        }
        return false;
      },
      child: Hero(
        tag: 'service-${widget.service.id}',
        child: Row(
          children: [
            _ImageViewer(
              images: widget.service.images,
              title: widget.service.name,
              description: widget.service.description,
              minPrice: widget.service.minPrice,
              maxPrice: widget.service.maxPrice,
              onTapdEdit: widget.onTapdEdit,
              onTapDelete: widget.onTapDelete,
            ),
          ],
        ),
      ),
    );
  }
}

  // Future<bool> _showConfirmationDialog(BuildContext context) async {
  //   return await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirmar eliminación'),
  //       content: const Text('¿Estás seguro de que deseas eliminar este servicio?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: const Text('Cancelar'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(true),
  //           child: const Text('Eliminar'),
  //         ),
  //       ],
  //     ),
  //   ) ?? false;
  // }


class _ImageViewer extends StatelessWidget {

  final List<String> images;
  final String title;
  final String description;
  final int minPrice;
  final int maxPrice;
  final Function()? onTapdEdit;
  final Function()? onTapDelete;

  const _ImageViewer({
    required this.images,
    this.title = '', 
    this.description = '',
    this.minPrice = 0,
    this.maxPrice = 0,
    this.onTapdEdit,
    this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    if ( images.isEmpty ) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(width: size.width * 0.93,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 214, 244, 220),
                blurRadius: 5,
                offset: Offset(0, 3)
              ),
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            
                Image.asset('assets/images/no-image.jpg', 
                  fit: BoxFit.cover,
                  height: 110,
                  width: size.width * 0.23,
                ),
                Container(
                  width: size.width * 0.50,
                  padding: const EdgeInsets.only( left: 5, top: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox( height: 10 ),
                      Text(
                        maxLines: 3,
                        description,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox( height: 10 ),
                      Text(
                        'Desde: \$${Formats.formatPriceNumber(minPrice).toString()} - ${Formats.formatPriceNumber(maxPrice).toString()} ',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),

                Row( children:
                  [

                    const SizedBox( width: 10 ),
                    CustomIconButton(
                      onTap: onTapdEdit ?? () {}, 
                      icon: Icons.edit,
                      size: 22,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox( width: 10 ),
                    CustomIconButton(
                      onTap: onTapDelete ?? () {}, 
                      icon: Icons.delete,
                      size: 22,
                      color: Colors.redAccent,
                    ),

                  ]
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(width: size.width * 0.93,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 214, 244, 220),
              blurRadius: 5,
              offset: Offset(0, 3)
            ),
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
              FadeInImage(
                fit: BoxFit.cover,
                height: 110,
                width: size.width * 0.23,
                fadeOutDuration: const Duration(milliseconds: 100),
                fadeInDuration: const Duration(milliseconds: 200),
                image: NetworkImage( images.first ),
                placeholder: const AssetImage('assets/loaders/loader2.gif'),
              ),
              Container(
                width: size.width * 0.50,
                padding: const EdgeInsets.only( left: 5, top: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox( height: 10 ),
                    Text(
                      maxLines: 3,
                      description,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox( height: 10 ),
                    Text(
                      'Desde: \$${minPrice.toStringAsFixed(2)} - ${maxPrice.toStringAsFixed(2)} ',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
              Row( children:
                [
                  const SizedBox( width: 10 ),
                  CustomIconButton(
                    onTap: onTapdEdit ?? () {}, 
                    icon: Icons.edit,
                    size: 22,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox( width: 10 ),
                  CustomIconButton(
                    onTap: onTapDelete ?? () {}, 
                    icon: Icons.delete,
                    size: 22,
                    color: Colors.redAccent,
                  ),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
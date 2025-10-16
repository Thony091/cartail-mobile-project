import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portafolio_project/presentation/providers/providers.dart';
import 'package:portafolio_project/presentation/shared/widgets/custom_product_field.dart';
import 'package:portafolio_project/presentation/shared/widgets/custom_text.dart';
import 'package:portafolio_project/presentation/shared/widgets/pop_up_message_final_widget.dart';

class HomeUserBody extends StatelessWidget {
  const HomeUserBody({
    super.key, 
    required this.size,
    required this.textColumn1,
    required this.textColumn2,
    required this.detailingDescription,
  });

  final Size size;
  final String textColumn1;
  final String textColumn2;
  final String detailingDescription;

  @override
  Widget build(BuildContext context) {

    // final String textTest = loremIpsum(words: 150, paragraphs: 3);
    final size = MediaQuery.of(context).size;
    const String textColumn1 = '¡Transforma tu Renault Duster en una obra maestra sobre ruedas con nuestro servicio de Detailing exclusivo! En Nuestro taller especializado, ofrecemos una experiencia única de embellecimiento y protección de tu vehículo, centrandonos en cada detalle de tu amada Renault Duster.';
    const String textColumn2 = '¡Experimenta  la potencia y el estilo sin igual de tu MINI john Cooper Works llevados al máximo nivel con nuestra transformación exclusiva! En nuestro talle especializado, nos enorgullese ofrecer un servicio personalizado  que resalta la esencia deportiva y elegancia intrinseca de tu MINI JCW.';
    const String detailingDescription = 'El detailing, en el servicio automotriz, es el conjunto de tecnicas centeradas en la limpieza perfecta del vehiculo sin causar deterioro de los materiales que lo componen. Es más, se encarga de solucionar defectos estéticos y proteger el auto ante la mayoria de las agresiones externas.';



    return SafeArea(
      child: SingleChildScrollView( 
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        // reverse: true,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            
              const SizedBox(height: 10,),
      
              FadeInDown(
                child: const CustomTextWithEffect(
                  text: 'Expertos en brillo', 
                  textStyle: TextStyle( 
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    // color: Colors.black
                  )
                ),
              ),
      
              // const Text('Expertos en brillo',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     decoration: TextDecoration.lineThrough,
              //     color: Colors.white54
              //   ),
              // ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
        
                children: [
                  FadeInLeft(
                    child: SizedBox(
                      width: size.width * 0.42,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/brillos/RD1.jpeg',
                              height: 150,
                              width: 300,
                            ),
                            // const SizedBox(height: 3,),
                            Image.asset(
                              'assets/images/brillos/RD5.jpeg',
                              height: 150,
                              width: 300,
                            ),
                            // const SizedBox(height: 3,),
                            Image.asset(
                              'assets/images/brillos/RD4.jpeg',
                              height: 150,
                              width: 300,
                            ),
                            // const SizedBox(height: 3,),
                            const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text( 
                                
                                textColumn1,
                                maxLines: 15,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FadeInRight(
                    child: SizedBox(
                      width: size.width * 0.42,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/brillos/JWC2.jpeg',
                              height: 150,
                              width: 300,
                            ),
                            // const SizedBox(height: 1,),
                            Image.asset(
                              'assets/images/brillos/JWC3.jpeg',
                              height: 150,
                              width: 300,
                            ),
                            // const SizedBox(height: 1,),
                            Image.asset(
                              'assets/images/brillos/JWC4.jpeg',
                              height: 150,
                              width: 300,
                            ),
                            // const SizedBox(height: 1,),
                            const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: SingleChildScrollView(
                                child: Text( 
                                  textColumn2,
                                  maxLines: 13,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox( height: 20,),
        
              FadeInRight(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('¿Que es Detailing?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox( height: 10,),
                        Text( detailingDescription,
                          maxLines: 10,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    )
                  ),
                ),
              ),
              const SizedBox( height: 20, ),
        
              SizedBox(
                height: 350,
                width: double.infinity,
                child: _Map()
              ),
              const SizedBox( height: 20,),
        
              FadeInUp(child: const _ContactUsForm()),
            ],
          ),
        ),
      ),
    );
  }
}


class _ContactUsForm extends ConsumerWidget {
  const _ContactUsForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final messageForm = ref.watch( messageFormProvider );
    final authState = ref.watch( authProvider );

    return FadeInRight(
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 240, 236, 236),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: [
                const Text( 'Contacto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox( height: 7),
                CustomProductField(
                  isBottomField: true,
                  isTopField: true,
                  label: 'Nombre',
                  initialValue: authState.authStatus == AuthStatus.authenticated
                    ? authState.userData!.nombre
                    : '',
                  // obscureText: true,
                  onChanged: ref.read( messageFormProvider.notifier ).onNameChange,
                  errorMessage: messageForm.isFormPosted
                  ? messageForm.name.errorMessage
                  : null,
                ),
                const SizedBox( height: 15,),
                CustomProductField(
                  isBottomField: true,
                  isTopField: true,
                  initialValue: authState.authStatus == AuthStatus.authenticated
                    ? authState.userData!.email
                    : '',
                  label: 'Correo Electrónico',
                  // obscureText: true,
                  onChanged: ref.read( messageFormProvider.notifier ).onEmailChange,
                  errorMessage: messageForm.isFormPosted
                  ? messageForm.email.errorMessage
                  : null,
                ),
                const SizedBox( height: 15,),
                CustomProductField(
                  isBottomField: true,
                  isTopField: true,
                  label: 'Mensaje',
                  hint: 'Escribe tu Mensaje',
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,  
                  // obscureText: true,
                  onChanged: ref.read( messageFormProvider.notifier ).onMessageChange,
                  errorMessage: messageForm.isFormPosted
                    ? messageForm.message.errorMessage
                    : null,
                ),
                const SizedBox( height: 15,),
                ElevatedButton(
                  onPressed: (){ messageForm.isPosting
                    ? null
                    : ref.read( messageFormProvider.notifier ).postMessage().then((value) {
                        if( messageForm.isValid && value == true ) {
                          context.push('/');
                          showDialog(
                            context: context, 
                            builder: (context) => const PopUpMensajeFinalWidget(text: 'Mensaje Enviado Exitosamente!'),
                          );
                        }
                      });
                  },
                  child: const Text('Enviar'),
                ),
              ],
            )
          ),
        )
      ),
    );
  }
}

class _Map extends StatelessWidget {
  _Map();
  final Completer<GoogleMapController> _controller =
    Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-33.538221, -70.661555),
    zoom: 12,
  );

  static const CameraPosition _ARDetailin = CameraPosition(
    // bearing: 192.8334901395799,
    target: LatLng(-33.530395, -70.649066),
    // tilt: 59.440717697143555,
    zoom: 14
  );

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: {
            const Marker(
              markerId: MarkerId('ARDetailin'),
              position: LatLng(-33.530395, -70.649066),
              infoWindow: InfoWindow(
                title: 'ARDetailin',
                snippet: 'Taller de Detallado Automotriz',
              ),
            ),
          }
        ),
        floatingActionButton: SizedBox(
          width: 135,
          height: 40,
          child: FloatingActionButton.extended(
            onPressed: _goToARDetailin,
            label: const Text('To WorkShop!'),
            icon: const Icon(Icons.car_repair_outlined),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Future<void> _goToARDetailin() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_ARDetailin));
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
// import 'package:portafolio_project/presentation/pages/auth/modern_login_page.dart';

import '../../../config/config.dart';
import '../../presentation_container.dart';

class SideMenu extends ConsumerStatefulWidget {
  
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const SideMenu({
    super.key,
    required this.scaffoldKey,
    });

  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {

  int navDrawerIndex = 0;
  final color = AppTheme().getTheme().colorScheme;
  final bool inicioSesion = false;
  
  @override
  Widget build(BuildContext context) {
    
    final authStateProvider = ref.watch( authProvider );
    final authStatus        = ref.watch( authProvider ).authStatus;
    final text              = AppTheme().getTheme().textTheme;
    const iconColor         = Colors.black;
    
    return NavigationDrawer(
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (value) {
        setState(() {
          navDrawerIndex = value;
        });
      },
        
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.goldGradientColors,
                stops: AppTheme.goldGradientStops,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text(
                //   'DriveTail', 
                //   style: TextStyle(
                //     color: Colors.black87,
                //     fontSize: 25,
                //     fontWeight: FontWeight.bold,
                //   )
                // ),
                // const SizedBox(width: 10),
                Image.asset(
                  'assets/logo/logo-third-no-bg.png',
                ),
                // const SizedBox(width: 10),

              ],
            ),
          ),

          //* Iniciar Sesion
          if  ( authStatus != AuthStatus.authenticated ) 
            ListTile(
              leading: const Icon(
                size: 33,
                Icons.person,
                color: iconColor,
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.black54,
              ),
              title: Text(
                'Inicio Sesion',
                style: text.labelLarge,
              ),
              // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ModernLoginPage())),
              onTap: () => context.push('/login'),
            ),

          //* Home
            ListTile(
              leading: const Icon(
                size: 33,
                Icons.home_outlined,
                color: iconColor,
                // color: Color(0xff4981be),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.black54,
              ),
              title: Text(
                'Home',
                style: text.labelLarge,
              ),
              onTap: () => context.push('/'),
            ),

          //* Servicios
          ListTile(
            leading: const Icon(
              size: 33,
              Icons.car_repair,
              color: iconColor,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Colors.black54,
            ),
            title: authStatus == AuthStatus.authenticated && authStateProvider.userData!.isAdmin
              ? Text(
                  'Gest. de Servicios',
                  style: text.labelLarge,
                )
              : Text(
                  'Servicios',
                  style: text.labelLarge,
                ),
            onTap: () => context.push('/services')
              // context.push('/services');,
          ),

          //* Agenda tu hora
          ListTile(
            leading: const Icon(
              size: 33,
              Icons.calendar_month_outlined,
              // FontAwesomeIcons.calendarAlt,
              color: iconColor,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Colors.black54,
            ),
            title: authStatus == AuthStatus.authenticated && authStateProvider.userData!.isAdmin
              ? Text(
                  'Gest. de Reservas',
                  style: text.labelLarge,
                )
              : Text(
                  'Agenda tu hora',
                  style: text.labelLarge,
                ),
            onTap: () { 
              ( authStatus == AuthStatus.authenticated && authStateProvider.userData!.isAdmin )
                ? context.push('/reservas-config')
                : context.push('/reservations');
            },
          ),

          //* Nuestros Trabajos
          ListTile(
            leading: const Icon(
              size: 33,
              Icons.diamond_outlined,
              color: iconColor,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Colors.black54,
            ),
            title: authStatus == AuthStatus.authenticated && authStateProvider.userData!.isAdmin
              ? Text(
                  'Gest. de Trabajos',
                  style: text.labelLarge,
                )
              : Text( 
                  'Nuestros trabajos',
                  style: text.labelLarge,
                ),
            onTap: () => context.push('/our-works'),
          ),

          if ( authStatus == AuthStatus.authenticated && authStateProvider.userData!.isAdmin )
          //* Mensajes
            ListTile(
              leading: const Icon(
                size: 33,
                Icons.message_outlined,
                color: iconColor,
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.black54,
              ),
              title: Text(
                'Gest. de Mensajes',
                style: text.labelLarge,
              ),
              onTap: () => context.push('/messages'),
            ),

          // //* Products
          // ListTile(
          //   leading: const Icon(
          //     size: 33,
          //     Icons.help,
          //     color: Color(0xff4981be),
          //   ),
          //   title: const Text(
          //     'Productos',
          //     style: TextStyle(
          //       color: Colors.black54,
          //       fontFamily: 'Montserrat',
          //       fontWeight: FontWeight.w400,
          //       fontSize: 17
          //     ),
          //   ),
          //   trailing: const Icon(
          //     Icons.arrow_forward_ios_rounded,
          //     size: 15,
          //     color: Colors.black54,
          //   ),
          //   onTap: (){
          //     context.push('/products');
          //   },
          // ),

          //* Cerrar Sesión
          if  ( authStatus == AuthStatus.authenticated )
             ListTile(
              leading: const Icon(
                FontAwesomeIcons.arrowRightFromBracket,
                // FontAwesomeIcons.signOut,
                color: iconColor,
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.black54,
              ),
              title: const Text(
                'Salir',
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  fontSize: 18
                ),
              ),
              onTap: () async => await ref.read( authProvider.notifier ).logOut().then( (_) => context.go('/') ),
                // context.push('/');
            ),
          
          const SizedBox( height: 30, ),
          const Divider( color: Colors.black38, ),
          const SizedBox( height: 30, ),

          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[

            if  ( authStatus == AuthStatus.authenticated )  
              //* Configuración
              TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color(0xfff2f2f2)),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                ),
                icon: const Icon(
                  Icons.settings,
                  size: 29, 
                  color: Color(0xff4981be),
                ),
                label: const Text(
                  'Configuración',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
                onPressed: () async => context.push('/profile-user'),
              ),

              if ( authStatus != AuthStatus.authenticated )
              //* REGISTRAR
              TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color(0xfff2f2f2)),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                ),
                icon: const Icon(
                  Icons.person_add,
                  size: 29, 
                  color: Color(0xff4981be),
                ),
                label: const Text(
                  'Registrar',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
                onPressed: () async {
                  context.push('/register');
                },
              ),

              // //* Carro de Compra
              // TextButton.icon(
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.all(const Color(0xfff2f2f2)),
              //     padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
              //   ),
              //   icon: const Icon(
              //     Icons.shopping_cart_checkout_rounded,
              //     size: 29, 
              //     color: Color(0xff4981be),
              //   ),
              //   label: const Text(
              //     'Mi Carrito',
              //     style: TextStyle(color: Colors.red, fontSize: 15),
              //   ),
              //   onPressed: () async {
              //     context.push('/shoping-cart');
              //   },
              // ),

            ]
          ),
        ],
      
    );
  }
}

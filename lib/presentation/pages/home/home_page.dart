import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/presentation/pages/home/components/body_home.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_app_bar.dart';
import 'package:portafolio_project/presentation/shared/widgets/modern_side_menu.dart';

import '../../../config/theme/theme.dart';
import '../../presentation_container.dart';

class HomePage extends ConsumerStatefulWidget {

  static const name = 'HomePage';

  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage>{
  @override
  Widget build(BuildContext context ) {

    final authStatusProvider  = ref.watch( authProvider );
    final scaffoldKey         = GlobalKey<ScaffoldState>();
    final text                = AppTheme().getTheme().textTheme;

    return  PopScope(
      canPop: false,
      child: Scaffold(
        drawer:  ModernSideMenu(scaffoldKey: scaffoldKey),
        // drawer:  ModernSideMenu(scaffoldKey: scaffoldKey),
        // drawer:  SideMenu(scaffoldKey: scaffoldKey),
        appBar: ModernAppBarWithMenu(
          title: (authStatusProvider.authStatus == AuthStatus.authenticated)
            ? 'Hola ${authStatusProvider.userData!.nombre}'
            : 'Hola Invitado',
            
          // showBackButton: false,
          
        ),
        // appBar: AppBar(
        //   title: Text( (authStatusProvider.authStatus == AuthStatus.authenticated)
        //     ? 'Hola ${authStatusProvider.userData!.nombre}'
        //     : 'Hola Invitado',
        //     style: text.titleLarge,
        //   ),
        //   elevation: 4.0,
        //   flexibleSpace: AppTheme.headerBgColor,
        // ),
        body: const BackgroundImageWidget(
          opacity: .6,
          child: HomeBody()
        ),
      
      ),
    );
  }
}

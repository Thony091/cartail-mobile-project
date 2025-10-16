import 'package:flutter/material.dart';
import 'package:portafolio_project/presentation/shared/widgets/widgets.dart';

class ModernScaffoldWithDrawer extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? appBarActions;

  const ModernScaffoldWithDrawer({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.appBarActions,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: ModernAppBarWithMenu(
          title: title,
          actions: appBarActions,
          scaffoldKey: scaffoldKey,
        ),
        drawer: ModernSideMenu(scaffoldKey: scaffoldKey),
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
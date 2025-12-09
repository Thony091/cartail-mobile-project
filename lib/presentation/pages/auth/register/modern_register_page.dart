import 'package:flutter/material.dart';
import 'package:portafolio_project/presentation/pages/auth/register/components/register_form_widget.dart';
import '../../../shared/widgets/widgets.dart';

class ModernRegisterPage extends StatelessWidget {
  static const name = 'ModernRegisterPage';  
  const ModernRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: ModernAppBarWithMenu(
        title: 'Crear Cuenta',
        automaticallyImplyLeading: true,
      ),
      body: RegisterFormWidget(),
    );
  }
}

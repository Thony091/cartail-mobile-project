import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/logo/logo-prime-no-bg.png',
              width: 140,
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Tu centro automotriz de confianza',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

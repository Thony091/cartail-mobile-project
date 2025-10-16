import 'package:flutter/material.dart';

class MenuHeaderWidget extends StatelessWidget {
  final String userName;
  final bool isAuthenticated;
  final bool isAdmin;

  const MenuHeaderWidget({
    super.key,
    required this.userName,
    required this.isAuthenticated,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2c3e50),
            Color(0xFF34495e),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Logo y nombre de la app
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:  BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3498db),
                      Color(0xFF2980b9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues( alpha: .2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DriveTail',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Centro Automotriz',
                    style: TextStyle(
                      color: Colors.white.withValues( alpha: .8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (isAuthenticated) ...[
            const SizedBox(height: 20),
            // Información del usuario
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues( alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isAdmin ? 'Administrador' : 'Usuario',
                        style: TextStyle(
                          color: Colors.white.withValues( alpha: .8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
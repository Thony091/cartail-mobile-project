import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/modern_button.dart';
import '../../shared/widgets/modern_card.dart';
import '../../shared/widgets/modern_input_field.dart';
import 'modern_scaffold_with_drawer.dart';

class ModernReservationsPage extends ConsumerStatefulWidget {
  static const name = 'ModernReservationsPage';
  
  const ModernReservationsPage({super.key});

  @override
  ModernReservationsPageState createState() => ModernReservationsPageState();
}

class ModernReservationsPageState extends ConsumerState<ModernReservationsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<ServiceOption> _services = [
    ServiceOption('1', 'Detailing Completo', const Color(0xFF3498db)),
    ServiceOption('2', 'Lavado Express', const Color(0xFF27ae60)),
    ServiceOption('3', 'Pulido y Encerado', const Color(0xFFf39c12)),
    ServiceOption('4', 'Limpieza de Motor', const Color(0xFFe74c3c)),
    ServiceOption('5', 'Limpieza de Tapiz', const Color(0xFF9b59b6)),
  ];

  @override
  Widget build(BuildContext context) {
    return ModernScaffoldWithDrawer(
      title: 'Agenda tu Hora',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withValues( alpha: .1 ),
              const Color(0xFFf8fafc),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              FadeInDown(
                child: ModernCard(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF27ae60), Color(0xFF2ecc71)],
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF27ae60).withValues( alpha: .3 ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Agenda tu Servicio!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecciona el servicio y la fecha que prefieras',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Formulario de reserva
              FadeInUp(
                child: ModernCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Datos de la Reserva',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nombre
                        ModernInputField(
                          label: 'Nombre Completo',
                          hint: 'Ingresa tu nombre',
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // RUT
                        ModernInputField(
                          label: 'RUT',
                          hint: '12345678-9',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Por favor ingresa tu RUT';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Email
                        ModernInputField(
                          label: 'Correo Electrónico',
                          hint: 'ejemplo@correo.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Por favor ingresa tu correo';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Servicio
                        const Text(
                          'Selecciona el Servicio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFe2e8f0),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedService,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintText: 'Elige una opción',
                            ),
                            items: _services.map((service) {
                              return DropdownMenuItem(
                                value: service.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: service.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(service.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor selecciona un servicio';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedService = value;
                              });
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Fecha
                        const Text(
                          'Selecciona la Fecha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFe2e8f0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF3498db),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                      : 'Selecciona una fecha',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedDate != null
                                        ? const Color(0xFF2c3e50)
                                        : const Color(0xFF7f8c8d),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Hora
                        const Text(
                          'Selecciona la Hora',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFe2e8f0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF3498db),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Selecciona una hora',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedTime != null
                                        ? const Color(0xFF2c3e50)
                                        : const Color(0xFF7f8c8d),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botón de reservar
                        SizedBox(
                          width: double.infinity,
                          child: ModernButton(
                            text: 'Reservar Ahora',
                            icon: Icons.check_circle,
                            style: ModernButtonStyle.success,
                            isLoading: _isLoading,
                            onPressed: _handleReservation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Información adicional
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Importante',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoItem(
                        Icons.schedule,
                        'Horario de Atención',
                        'Lunes a Viernes: 9:00 - 19:00\nSábados: 9:00 - 14:00',
                      ),
                      
                      _buildInfoItem(
                        Icons.cancel,
                        'Cancelaciones',
                        'Puedes cancelar con 24 horas de anticipación',
                      ),
                      
                      _buildInfoItem(
                        Icons.payment,
                        'Pago',
                        'Se puede pagar en efectivo o tarjeta al momento del servicio',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withValues( alpha: .1 ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3498db),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3498db),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2c3e50),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3498db),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2c3e50),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _handleReservation() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        _showSnackBar('Por favor selecciona una fecha');
        return;
      }
      if (_selectedTime == null) {
        _showSnackBar('Por favor selecciona una hora');
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFe74c3c),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF27ae60).withValues( alpha: .1 ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Color(0xFF27ae60),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Reserva Exitosa!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu reserva ha sido confirmada. Recibirás un correo con los detalles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7f8c8d),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Entendido',
                style: ModernButtonStyle.success,
                onPressed: () {
                  Navigator.of(context).pop();
                  // Limpiar el formulario
                  setState(() {
                    _selectedService = null;
                    _selectedDate = null;
                    _selectedTime = null;
                  });
                  _formKey.currentState?.reset();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceOption {
  final String id;
  final String name;
  final Color color;

  ServiceOption(this.id, this.name, this.color);
}
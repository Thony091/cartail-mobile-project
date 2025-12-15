// class ModernReservationsPage extends StatefulWidget {
//   static const name = 'ModernReservationsPage';
  
//   const ModernReservationsPage({super.key});

//   @override
//   State<ModernReservationsPage> createState() => _ModernReservationsPageState();
// }

// class _ModernReservationsPageState extends State<ModernReservationsPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _rutController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _additionalInfoController = TextEditingController();
  
//   String _selectedService = '';
//   DateTime? _selectedDate;
//   String _selectedTime = '';
//   bool _isLoading = false;

//   final List<String> _services = [
//     'Detailing Premium',
//     'Lavado Completo',
//     'Encerado Protector',
//     'Limpieza Interior',
//     'Protección Cerámica',
//   ];

//   final List<String> _timeSlots = [
//     '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
//     '12:00', '12:30', '14:00', '14:30', '15:00', '15:30',
//     '16:00', '16:30', '17:00', '17:30', '18:00'
//   ];

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _rutController.dispose();
//     _emailController.dispose();
//     _additionalInfoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ModernScaffoldWithDrawer(
//       title: 'Agenda tu Hora',
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               const Color(0xFF667eea).withOpacity(0.1),
//               const Color(0xFFf8fafc),
//             ],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 FadeInDown(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Agenda tu Servicio',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF2c3e50),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Programa tu cita para el servicio automotriz que necesitas',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Color(0xFF7f8c8d),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 32),
                
//                 // Información personal
//                 FadeInLeft(
//                   child: ModernCard(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Información Personal',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF2c3e50),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
                        
//                         ModernInputField(
//                           controller: _nameController,
//                           label: 'Nombre Completo',
//                           hint: 'Tu nombre completo',
//                           prefixIcon: const Icon(Icons.person),
//                           validator: (value) {
//                             if (value?.isEmpty ?? true) {
//                               return 'El nombre es requerido';
//                             }
//                             return null;
//                           },
//                         ),
                        
//                         const SizedBox(height: 20),
                        
//                         ModernInputField(
//                           controller: _rutController,
//                           label: 'RUT',
//                           hint: '12345678-9',
//                           prefixIcon: const Icon(Icons.badge),
//                           validator: (value) {
//                             if (value?.isEmpty ?? true) {
//                               return 'El RUT es requerido';
//                             }
//                             return null;
//                           },
//                         ),
                        
//                         const SizedBox(height: 20),
                        
//                         ModernInputField(
//                           controller: _emailController,
//                           label: 'Correo Electrónico (*)',
//                           hint: 'ejemplo@correo.com',
//                           keyboardType: TextInputType.emailAddress,
//                           prefixIcon: const Icon(Icons.email),
//                           validator: (value) {
//                             if (value?.isEmpty ?? true) {
//                               return 'El correo es requerido';
//                             }
//                             if (!value!.contains('@')) {
//                               return 'Ingresa un correo válido';
//                             }
//                             return null;
//                           },
//                         ),
                        
//                         const SizedBox(height: 20),
                        
//                         ModernInputField(
//                           controller: _phoneController,
//                           label: 'Número de Teléfono (*)',
//                           hint: 'Ej: 987654321',
//                           keyboardType: TextInputType.phone,
//                           prefixIcon: const Icon(Icons.phone),
//                           validator: (value) {
//                             if (value?.isEmpty ?? true) {
//                               return 'El teléfono es requerido';
//                             }
//                             if (value!.length < 9) {
//                               return 'Ingresa un número válido';
//                             }
//                             return null;
//                           },
//                         ),
                        
//                         const SizedBox(height: 20),
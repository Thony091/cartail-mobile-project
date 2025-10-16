import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';
import 'firebase_auth_service.dart';
// import 'push_notifications_service.dart';

class FirebaseService{

  static Future<void> init() async{
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    //* Firebase Auth
    FirebaseAuthService.init();
    
    //* Notificaciones push
    // await PushNotificationsService.initNotifications();

  }

}
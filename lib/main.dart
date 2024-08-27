import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parking_appv1/firebase_options.dart';
import 'package:parking_appv1/screens/login.dart';
import 'package:parking_appv1/screens/dashboard.dart';
import 'package:parking_appv1/screens/manageUser.dart';
import 'package:parking_appv1/screens/parkingHistory.dart';
import 'package:parking_appv1/screens/profileScreen.dart';
import 'package:parking_appv1/screens/editProfile.dart';
import 'package:parking_appv1/screens/parkinout.dart';
import 'package:parking_appv1/screens/camera.dart';

import 'screens/changePassword.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "Parking System",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plate Number Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/dashboard': (context) => Dashboard(
            isAdmin: ModalRoute.of(context)!.settings.arguments as bool),
        '/parkingHistory': (context) {
          // Check if the argument is provided
          final isAdmin =
              ModalRoute.of(context)!.settings.arguments as bool? ?? false;
          return Parkinghistory(isAdmin: isAdmin);
        },
        '/manageUser': (context) => Manageuser(
            isAdmin: ModalRoute.of(context)!.settings.arguments as bool),
        '/profile': (context) => Profilescreen(
            isAdmin: ModalRoute.of(context)!.settings.arguments as bool),
        '/editProfile': (context) => Editprofile(
            isAdmin: ModalRoute.of(context)!.settings.arguments as bool),
        '/changePassword': (context) => Changepassword(
            isAdmin: ModalRoute.of(context)!.settings.arguments as bool),
        '/login': (context) => const LoginPage(),
        '/parkinout': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return Parkinout(
            isAdmin:
                args['isAdmin'] ?? false, // Default to false if not provided
            isParkIn:
                args['isParkIn'] ?? false, // Default to false if not provided
          );
        },
        '/camera': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return CameraScreen(
            vehicleType: args['vehicleType'],
            isParkIn: args['isParkIn'],
            isAdmin: args['isAdmin'] ?? false,
          );
        },
      },
    );
  }
}

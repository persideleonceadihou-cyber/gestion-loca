import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestion_locative/ajout.dart';
import 'package:gestion_locative/conect.dart';
import 'package:gestion_locative/Dashboard.dart';
import 'package:gestion_locative/propretaire.dart';
import 'package:gestion_locative/locataire.dart';
import 'package:gestion_locative/document.dart';
import 'package:gestion_locative/paiement.dart';
import 'package:gestion_locative/profil.dart';
import 'package:gestion_locative/scan.dart';
import 'package:gestion_locative/firebase_options.dart';
import 'package:gestion_locative/PayeCash.dart';
import 'package:gestion_locative/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion locative',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const Home(),
      routes: {
        '/connect': (context) => const Connect(),
        '/dashboard': (context) => const Dashboard(),
        '/paiement': (context) => const Paiement(),
        '/document': (context) => const Document(),
        '/profil': (context) => const Profil(),
        '/scan': (context) => const ScanPage(),
        "/proprietaire": (context) => const Propretaire(),
        "/locataire": (context) => const Locataire(),
        "/ajout": (context) => const Ajout(),
        "/payeCash": (context) => const PayeCashScreen(),
      },
    );
  }
}

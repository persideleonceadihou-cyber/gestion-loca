import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:gestion_locative/mesBiens.dart';
import 'package:gestion_locative/conect.dart';
import 'package:gestion_locative/firebase_options.dart';
import 'package:gestion_locative/propretaire.dart';
import 'package:gestion_locative/locataire.dart';
import 'package:gestion_locative/document.dart';
import 'package:gestion_locative/paiement.dart';
import 'package:gestion_locative/profil.dart';
import 'package:gestion_locative/scan.dart';
import 'package:gestion_locative/PayeCash.dart';
import 'package:gestion_locative/home.dart';
import 'package:gestion_locative/ajoutMaison.dart';
import 'package:gestion_locative/ajout.dart';
import 'package:gestion_locative/Accueil.dart';
import 'package:gestion_locative/tenant_payment_page.dart';
import 'package:gestion_locative/services/fcm_service.dart'; // ← ajout
import 'package:firebase_messaging/firebase_messaging.dart';

// ── Clé globale pour accéder au contexte hors widget ──
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

ThemeData _buildAppTheme() {
  const navy = Color(0xFF1A2B5E);
  const bgPage = Color(0xFFF5F0E8);
  const cream = Color(0xFFF2C94C);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: navy,
    brightness: Brightness.light,
  ).copyWith(
    primary: navy,
    secondary: cream,
    surface: Colors.white,
    error: const Color(0xFF993C1D),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bgPage,
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF149954),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    useMaterial3: true,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
    final String url = Uri.base.toString();

    if (url.contains('/pay') || url.contains('/payer')) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Paiement Loyer',
        theme: _buildAppTheme(),
        home: TenantPaymentPage(
          code: Uri.base.queryParameters['code'] ?? '',
        ),
      ));
      return;
    }
  }

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  // ── Sauvegarder le token FCM si l'utilisateur est connecté ──
  if (!kIsWeb) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FcmService.saveToken(user.uid);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // ← ajout
      title: 'Gestion locative',
      theme: _buildAppTheme(),
      home: const Home(),
      routes: {
        '/connect': (context) => const Connect(),
        '/accueil': (context) => Accueil(userName: "Utilisateur"),
        '/mesBiens': (context) => const MesBiens(),
        '/paiement': (context) => const Paiement(),
        '/document': (context) => const Document(),
        '/profil': (context) => const Profil(),
        '/scan': (context) => const Scan(),
        '/proprietaire': (context) => const Propretaire(),
        '/locataire': (context) => const LocatairesScreen(),
        '/ajout': (context) => const AjoutMaison(),
        '/ajoutLocataire': (context) => const Ajout(),
        '/payeCash': (context) => const PayeCash(),
      },
      builder: (context, child) {
        // ── Écouter les notifications FCM ──
        return _FcmListener(child: child!);
      },
    );
  }
}

// ─────────────────────────────────────────────
// Widget qui écoute les notifications FCM
// ─────────────────────────────────────────────
class _FcmListener extends StatefulWidget {
  final Widget child;
  const _FcmListener({required this.child});

  @override
  State<_FcmListener> createState() => _FcmListenerState();
}

class _FcmListenerState extends State<_FcmListener> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _initFcm();
  }

  void _initFcm() {
    // App au premier plan → snackbar
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final title = msg.notification?.title ?? '';
      final body  = msg.notification?.body  ?? '';

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(body),
            ],
          ),
          backgroundColor: const Color(0xFF149954),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    });

    // Tap sur notif depuis le background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      if (msg.data['type'] == 'paiement_effectue') {
        navigatorKey.currentState?.pushNamed('/paiement');
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

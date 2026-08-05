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
import 'package:gestion_locative/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

String _currentUserDisplayName() {
  final user = FirebaseAuth.instance.currentUser;
  final displayName = user?.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }

  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email.split('@').first;
  }

  return 'Utilisateur';
}

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
  }

  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final Future<void> _initFuture = _initialize();

  Future<void> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FcmService.saveToken(user.uid);
      }
      _initFcm();
    }
  }

  void _initFcm() {
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final title = msg.notification?.title ?? '';
      final body = msg.notification?.body ?? '';
      final messenger = messengerKey.currentState;
      if (messenger == null) return;

      messenger.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(body),
            ],
          ),
          backgroundColor: const Color(0xFF149954),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      if (msg.data['type'] == 'paiement_effectue') {
        navigatorKey.currentState?.pushNamed('/paiement');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _buildAppTheme(),
            home: const _BootstrapLoadingScreen(),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _buildAppTheme(),
            home: _BootstrapErrorScreen(error: snapshot.error.toString()),
          );
        }

        if (kIsWeb) {
          final url = Uri.base.toString();
          if (url.contains('/pay') || url.contains('/payer')) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Paiement Loyer',
              theme: _buildAppTheme(),
              home: TenantPaymentPage(
                code: Uri.base.queryParameters['code'] ?? '',
              ),
            );
          }
        }

        return const MyApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      title: 'Gestion locative',
      theme: _buildAppTheme(),
      home: const Home(),
      routes: {
        '/connect': (context) => const Connect(),
        '/accueil': (context) => Accueil(userName: _currentUserDisplayName()),
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
    );
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132040),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Chargement de l’application...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  final String error;

  const _BootstrapErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132040),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Erreur au démarrage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD0D8F0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

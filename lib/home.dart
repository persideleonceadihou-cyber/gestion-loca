import 'dart:async';

import 'package:flutter/material.dart';

const Color _lightGoldenRodYellow = Color(0xFFFAFAD2);
const Color _deepNavy = Color(0xFF132238);
const Color _softBlue = Color(0xFFDDEAF8);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: _lightGoldenRodYellow),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: _softBlue, width: 4),
                  ),
                  child: Image.asset(
                    'assets/images/logo (2).png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.home_work_outlined,
                        size: 48,
                        color: _deepNavy,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gestion locative',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _deepNavy,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bienvenu sur votre application de gestion de biens immobiliers',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _deepNavy, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 28),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

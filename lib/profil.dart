import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:gestion_locative/conect.dart';
// import 'package:gestion_locative/mesBiens.dart';
// import 'package:gestion_locative/paiement_refonte.dart';
// import 'package:gestion_locative/accueil_refonte.dart';

// ─────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────
class _C {
  static const navy = Color(0xFF1A2B5E);
  static const cream = Color(0xFFF2C94C);
  static const creamLight = Color(0xFFFDF6DC);
  static const bgPage = Color(0xFFF5F0E8);
  static const white = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1A2B5E);
  static const textMuted = Color(0xFF7A6F52);
  static const border = Color(0xFFECE6D6);
  static const redText = Color(0xFFBB2020);
  static const redBg = Color(0xFFFFF0F0);
  static const redBd = Color(0xFFFFCDD2);
}

// ─────────────────────────────────────────────
// Page Profil
// ─────────────────────────────────────────────
class Profil extends StatefulWidget {
  final bool showBottomNav;

  const Profil({super.key, this.showBottomNav = true});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  bool _isPickingPhoto = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Initiales depuis displayName ou email
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Utilisateur';
    final email = user?.email ?? 'utilisateur@gmail.com';
    final initials = _initials(name);

    return Scaffold(
      backgroundColor: _C.bgPage,
      body: Column(
        children: [
          // ── HEADER navy ──────────────────────
          StreamBuilder<DocumentSnapshot>(
            stream: user == null
                ? null
                : FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              return _buildHeader(
                context,
                initials,
                data?['displayName']?.toString() ?? name,
                data?['email']?.toString() ?? email,
                data?['profilePhotoBase64']?.toString(),
              );
            },
          ),
          // ── CORPS ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rows principaux
                  _menuRow(
                    icon: Icons.person_outline,
                    label: 'Informations personnelles',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _menuRow(
                    icon: Icons.home_work_outlined,
                    label: 'Mes Biens(8)',
                    onTap: () {
                      // Navigator.push(context,
                      //   MaterialPageRoute(builder: (_) => const MesBiens()));
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section Sécurité
                  const Text(
                    'Securité',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _C.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _menuRow(
                    icon: Icons.lock_outline,
                    label: 'Mot de passe',
                    onTap: () => _resetPassword(context, email),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: _C.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bouton déconnexion
                  _buildSignOut(context),
                  const SizedBox(height: 12),
                  _buildDeleteAccount(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? _buildBottomNav(context)
          : null,
    );
  }

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    String initials,
    String name,
    String email,
    String? photoBase64,
  ) {
    final photoBytes = _decodePhoto(photoBase64);
    return Container(
      width: double.infinity,
      color: _C.navy,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isPickingPhoto ? null : () => _pickProfilePhoto(context),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: _C.cream,
                  backgroundImage: photoBytes == null
                      ? null
                      : MemoryImage(photoBytes),
                  child: photoBytes == null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _C.navy,
                          ),
                        )
                      : null,
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.navy, width: 2),
                  ),
                  child: _isPickingPhoto
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _C.navy,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_outlined,
                          color: _C.navy,
                          size: 15,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(fontSize: 12, color: Color(0xFFB0BAD0)),
          ),
        ],
      ),
    );
  }

  Uint8List? _decodePhoto(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final payload = value.contains(',') ? value.split(',').last : value;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickProfilePhoto(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isPickingPhoto = true);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 700,
        imageQuality: 70,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final photoData = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName ?? 'Utilisateur',
        'email': user.email ?? '',
        'profilePhotoBase64': photoData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo de profil mise a jour.'),
          backgroundColor: const Color(0xFF3B6D11),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  // ── MENU ROW ──────────────────────────────────────────
  Widget _menuRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.textMain,
                ),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  // ── BOUTON DÉCONNEXION ────────────────────────────────
  Widget _buildSignOut(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
        ),
        child: const Center(
          child: Text(
            'se deconnecter',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _C.redText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDeleteAccount(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.redBd),
        ),
        child: const Center(
          child: Text(
            'Supprimer mon compte',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _C.redText,
            ),
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _C.white,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: _C.navy,
        unselectedItemColor: _C.textMuted,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (i) {
          final routes = [
            '/accueil',
            '/mesBiens',
            '/paiement',
            '/locataire',
            '/profil',
          ];
          if (i == 4) return;
          Navigator.pushReplacementNamed(context, routes[i]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: 'Biens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Paiement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Locataires',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Future<void> _resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email de réinitialisation envoyé à $email'),
          backgroundColor: const Color(0xFF3B6D11),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Erreur'),
          backgroundColor: const Color(0xFF993C1D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Se déconnecter ?',
          style: TextStyle(fontWeight: FontWeight.bold, color: _C.navy),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: _C.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: _C.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.redText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/connect', (route) => false);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer le compte ?',
          style: TextStyle(fontWeight: FontWeight.bold, color: _C.navy),
        ),
        content: const Text(
          'Cette action supprime l’utilisateur Firebase courant et ses données de profil locales. Elle est irréversible.',
          style: TextStyle(color: _C.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: _C.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.redText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // On supprime d'abord le document Firestore lié au compte courant.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await user.delete();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/connect', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'requires-recent-login'
                ? 'Reconnexion requise avant suppression du compte.'
                : (e.message ?? 'Impossible de supprimer le compte'),
          ),
          backgroundColor: const Color(0xFF993C1D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

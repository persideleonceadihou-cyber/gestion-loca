import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_locative/locataire.dart';
import 'package:gestion_locative/mesBiens.dart' as biens;
import 'package:gestion_locative/paiement.dart';
import 'package:gestion_locative/profil.dart';

// ─────────────────────────────────────────────
// Palette fidèle à la maquette Figma
// ─────────────────────────────────────────────
class _C {
  static const navy = Color(0xFF1A2B5E);
  static const creamLight = Color(0xFFFDF6DC);
  static const bgPage = Color(0xFFF5F0E8); // fond général (beige chaud)
  static const white = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1A2B5E);
  static const textMuted = Color(0xFF7A6F52);
  static const border = Color(0xFFECE6D6);

  // Statuts
  static const paidText = Color(0xFF3B6D11);
  static const paidBg = Color(0xFFF0FAE4);
  static const paidBd = Color(0xFFC0DD97);
  static const pendText = Color(0xFF854F0B);
  static const pendBg = Color(0xFFFAEEDA);
  static const pendBd = Color(0xFFF5C97A);
  static const lateText = Color(0xFF993C1D);
  static const lateBg = Color(0xFFFFEBE5);
  static const lateBd = Color(0xFFF5B5A0);
  static const freeText = Color(0xFF1A2B5E);
  static const freeBg = Color(0xFFFDF6DC);
  static const freeBd = Color(0xFFE8C84A);
}

// ─────────────────────────────────────────────
// Modèle locataire
// ─────────────────────────────────────────────
class _Tenant {
  final String initials;
  final Color avatarColor;
  final String name;
  final String room;
  final String status;
  final Color statusText;
  final Color statusBg;
  final Color statusBorder;

  const _Tenant({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.room,
    required this.status,
    required this.statusText,
    required this.statusBg,
    required this.statusBorder,
  });
}

// ─────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────
class Accueil extends StatefulWidget {
  final String userName;
  const Accueil({super.key, required this.userName});

  @override
  State<Accueil> createState() => _AccueilState();
}

class Locataires extends StatelessWidget {
  const Locataires({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(title: const Text("Locataires")),
      body: const Center(child: Text("Liste des locataires ici")),
    );
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(title: const Text("Profil")),
      body: const Center(child: Text("Informations du profil ici")),
    );
  }
}

class AccueilMesBiens extends StatelessWidget {
  const AccueilMesBiens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(title: const Text("Biens")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _bienCard("Maison A", "Calavi", "250 000 FCFA", "Loué"),
          _bienCard("Appartement B", "Plateau", "350 000 FCFA", "Libre"),
          _bienCard("Studio C", "Cadjèhoun", "150 000 FCFA", "En attente"),
        ],
      ),
    );
  }

  Widget _bienCard(String titre, String lieu, String prix, String statut) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _C.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(lieu, style: const TextStyle(color: _C.textMuted)),
                const SizedBox(height: 4),
                Text(
                  prix,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.navy,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _C.creamLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statut,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _C.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 0;

  // ── Données statiques (à remplacer par Firebase) ──
  static const _tenants = [
    _Tenant(
      initials: 'AM',
      avatarColor: Color(0xFFF2C94C),
      name: 'Ama Mensah',
      room: 'Chambre A · Calavi',
      status: 'Payé',
      statusText: _C.paidText,
      statusBg: _C.paidBg,
      statusBorder: _C.paidBd,
    ),
    _Tenant(
      initials: 'KO',
      avatarColor: Color(0xFF2ECC71),
      name: 'Koffi Ouédraogo',
      room: 'Chambre B · Plateau',
      status: 'En attente',
      statusText: _C.pendText,
      statusBg: _C.pendBg,
      statusBorder: _C.pendBd,
    ),
    _Tenant(
      initials: 'AM',
      avatarColor: Color(0xFF5DADE2),
      name: 'Séraphine Bah',
      room: 'Chambre C · Cadjèhoun',
      status: 'Retard',
      statusText: _C.lateText,
      statusBg: _C.lateBg,
      statusBorder: _C.lateBd,
    ),
  ];

  static const _freeTenants = [
    _Tenant(
      initials: '',
      avatarColor: Color(0xFFCCCCCC),
      name: 'Séraphine Bah',
      room: 'Chambre C · Cadjèhoun',
      status: 'Libre',
      statusText: _C.freeText,
      statusBg: _C.freeBg,
      statusBorder: _C.freeBd,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgPage,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildAccueil(),
            const biens.MesBiens(showBottomNav: false),
            const Paiement(showBottomNav: false),
            const LocatairesScreen(showBottomNav: false),
            const Profil(showBottomNav: false),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
  // ── BOTTOM NAV ─────────────────────────────

  // ═══════════════════════════════════════════
  // ACCUEIL
  // ═══════════════════════════════════════════
  Widget _buildAccueil() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildAccueilContent(
        tenants: _tenants,
        freeProperties: _freeTenants,
        propertiesCount: 12,
        tenantsCount: 9,
        monthlyRentTotal: 850000,
      );
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    return StreamBuilder<QuerySnapshot>(
      stream: userDoc
          .collection('biens')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, biensSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: userDoc
              .collection('locataires')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, locatairesSnapshot) {
            final propertyDocs = biensSnapshot.data?.docs ?? [];
            final tenantDocs = locatairesSnapshot.data?.docs ?? [];
            final tenants = tenantDocs
                .map(
                  (doc) =>
                      TenantRecord.fromMap(doc.data() as Map<String, dynamic>),
                )
                .map(_tenantFromRecord)
                .toList();
            final freeProperties = propertyDocs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where((map) => map['isRented'] != true)
                .map(_freePropertyFromMap)
                .toList();
            final rentTotal = propertyDocs.fold<int>(0, (total, doc) {
              final map = doc.data() as Map<String, dynamic>;
              return total + _amountFrom(map['priceNumber'] ?? map['price']);
            });

            return _buildAccueilContent(
              tenants: tenants.take(3).toList(),
              freeProperties: freeProperties.take(3).toList(),
              propertiesCount: propertyDocs.length,
              tenantsCount: tenantDocs.length,
              monthlyRentTotal: rentTotal,
            );
          },
        );
      },
    );
  }

  Widget _buildAccueilContent({
    required List<_Tenant> tenants,
    required List<_Tenant> freeProperties,
    required int propertiesCount,
    required int tenantsCount,
    required int monthlyRentTotal,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER navy ──────────────────────
          _buildHeader(),

          // ── STATS ────────────────────────────
          _buildStats(propertiesCount, tenantsCount, monthlyRentTotal),

          // ── CORPS ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Locataires récents
                _sectionHeader('Locataires récents', 'Voir tout', () {
                  setState(() => _selectedIndex = 3);
                }),
                const SizedBox(height: 10),
                if (tenants.isEmpty)
                  _emptyRow('Aucun locataire enregistre')
                else
                  ...tenants.map(_tenantRow),

                const SizedBox(height: 20),

                // Bien libre
                _sectionHeader('Bien libre', 'Voir tout', () {
                  setState(() => _selectedIndex = 1);
                }),
                const SizedBox(height: 10),
                if (freeProperties.isEmpty)
                  _emptyRow('Aucun bien libre')
                else
                  ...freeProperties.map(_tenantRow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _C.navy,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0BAD0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Avatar
          _profileAvatar(),
        ],
      ),
    );
  }

  // ── STATS ─────────────────────────────────────────────
  Widget _buildStats(
    int propertiesCount,
    int tenantsCount,
    int monthlyRentTotal,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _statCol('$propertiesCount', 'Biens')),
            _vDivider(),
            Expanded(child: _statCol('$tenantsCount', 'Locataires')),
            _vDivider(),
            Expanded(
              child: _statCol(
                _formatCompactAmount(monthlyRentTotal),
                'FCFA/mois',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _C.navy,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _C.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => VerticalDivider(
    color: _C.border,
    width: 1,
    thickness: 1,
    indent: 4,
    endIndent: 4,
  );

  // ── SECTION HEADER ────────────────────────────────────
  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _C.navy,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: _C.navy,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  // ── LIGNE LOCATAIRE ───────────────────────────────────
  Widget _tenantRow(_Tenant t) {
    final bool isFree = t.initials.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: t.avatarColor,
            child: isFree
                ? const Icon(Icons.home_outlined, color: Colors.white, size: 20)
                : Text(
                    t.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _C.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.room,
                  style: const TextStyle(fontSize: 11, color: _C.textMuted),
                ),
              ],
            ),
          ),

          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: t.statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.statusBorder),
            ),
            child: Text(
              t.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: t.statusText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyRow(String label) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Text(
        label,
        style: const TextStyle(color: _C.textMuted, fontSize: 12),
      ),
    );
  }

  Widget _profileAvatar() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _profileAvatarButton(null);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        return _profileAvatarButton(
          _decodePhoto(data?['profilePhotoBase64']?.toString()),
        );
      },
    );
  }

  Widget _profileAvatarButton(Uint8List? photoBytes) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 4),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        backgroundImage: photoBytes == null ? null : MemoryImage(photoBytes),
        child: photoBytes == null
            ? const Icon(Icons.person, color: _C.navy, size: 22)
            : null,
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

  _Tenant _tenantFromRecord(TenantRecord record) {
    return _Tenant(
      initials: record.initials,
      avatarColor: record.statusColor,
      name: record.name,
      room: '${record.roomNumber} - ${record.propertyName}',
      status: record.statusLabel,
      statusText: record.statusColor,
      statusBg: record.statusColor.withValues(alpha: 0.12),
      statusBorder: record.statusColor.withValues(alpha: 0.35),
    );
  }

  _Tenant _freePropertyFromMap(Map<String, dynamic> map) {
    final title = map['title']?.toString() ?? 'Bien libre';
    final type = map['type']?.toString() ?? 'Bien';
    final location = map['location']?.toString() ?? '';
    return _Tenant(
      initials: '',
      avatarColor: _C.freeText,
      name: title,
      room: '$type - $location',
      status: 'Libre',
      statusText: _C.freeText,
      statusBg: _C.freeBg,
      statusBorder: _C.freeBd,
    );
  }

  int _amountFrom(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }

  String _formatCompactAmount(int value) {
    if (value >= 1000000 && value % 1000000 == 0) return '${value ~/ 1000000}M';
    if (value >= 1000 && value % 1000 == 0) return '${value ~/ 1000}K';
    return _formatAmount(value);
  }

  String _formatAmount(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  // ── BOTTOM NAV ────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: _C.white,
        border: Border(top: BorderSide(color: _C.border, width: 1)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: _C.navy,
        unselectedItemColor: _C.textMuted,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Biens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Paiements',
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
}

// ─────────────────────────────────────────────
// Placeholder pages
// ─────────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Placeholder({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: const Color(0xFF1A2B5E).withValues(alpha: 0.25),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2B5E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'En cours de développement',
            style: TextStyle(color: Color(0xFF7A6F52), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

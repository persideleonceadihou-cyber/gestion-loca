import 'package:flutter/material.dart';
import 'package:gestion_locative/Dashboard.dart';
import 'package:gestion_locative/document.dart';
import 'package:gestion_locative/paiement.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  static Future<void> _signOut(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Dashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const profile = _UserProfile(
      name: 'Utilisateur local',
      email: 'local@gestion.app',
      phone: '+229 90 00 00 00',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Deconnexion',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              _ProfileHeaderCard(profile: profile),
              const SizedBox(height: 18),
              const _ProfileStatsRow(),
              const SizedBox(height: 18),
              _ProfileInfoCard(profile: profile),
              const SizedBox(height: 18),
              const _ProfileActionsCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Dashboard()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Paiement()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Document()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Paiement'),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Document',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _UserProfile {
  final String name;
  final String email;
  final String phone;

  const _UserProfile({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class _ProfileHeaderCard extends StatelessWidget {
  final _UserProfile profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF132238), Color(0xFF1C5D99), Color(0xFF4FA3D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 48, color: Color(0xFF132238)),
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gestionnaire locatif',
            style: TextStyle(color: Color(0xFFDCE7F4), fontSize: 14),
          ),
          const SizedBox(height: 14),
          const Text(
            'Suivi des locataires, des contrats, des paiements et des documents depuis un seul tableau de bord.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFDCE7F4), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            title: 'Biens suivis',
            value: '8',
            icon: Icons.home_work_outlined,
            color: Color(0xFFE8F1FF),
            iconColor: Color(0xFF2B7FFF),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ProfileStatCard(
            title: 'Locataires',
            value: '6',
            icon: Icons.groups_2_outlined,
            color: Color(0xFFEAF7EF),
            iconColor: Color(0xFF149954),
          ),
        ),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _ProfileStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF607086),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF132238),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final _UserProfile profile;

  const _ProfileInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations personnelles',
            style: TextStyle(
              color: Color(0xFF132238),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileInfoRow(label: 'Nom complet', value: profile.name),
          _ProfileInfoRow(label: 'Email', value: profile.email),
          _ProfileInfoRow(label: 'Telephone', value: profile.phone),
          const _ProfileInfoRow(
            label: 'Fonction',
            value: 'Administrateur immobilier',
          ),
          const _ProfileInfoRow(label: 'Ville', value: 'Porto-Novo, Benin'),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6C7B8D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF132238),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionsCard extends StatelessWidget {
  const _ProfileActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              color: Color(0xFF132238),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.lock_outline,
            title: 'Securite',
            subtitle: 'Mot de passe et acces',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Rappels de paiement et alertes',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.help_outline,
            title: 'Support',
            subtitle: 'Assistance et aide a l\'utilisation',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.logout_outlined,
            title: 'Deconnexion',
            subtitle: 'Quitter le compte actuel',
            onTap: () => Profil._signOut(context),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF132238)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF132238),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF6C7B8D)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

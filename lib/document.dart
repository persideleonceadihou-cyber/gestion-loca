import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_locative/Dashboard.dart';
import 'package:gestion_locative/locataire.dart';
import 'package:gestion_locative/paiement.dart';
import 'package:gestion_locative/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Document extends StatefulWidget {
  const Document({super.key});

  @override
  State<Document> createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  List<TenantRecord> _tenants = localPreviewTenants;

  @override
  void initState() {
    super.initState();
    _loadTenantDocuments();
  }

  Future<void> _loadTenantDocuments() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedTenants =
        preferences.getStringList(tenantsLocalCacheKey) ?? [];
    final tenants = <TenantRecord>[];

    for (final encodedTenant in encodedTenants) {
      try {
        final decoded = jsonDecode(encodedTenant);
        if (decoded is Map<String, dynamic>) {
          tenants.add(TenantRecord.fromMap(decoded));
        }
      } catch (error) {
        debugPrint('Erreur lecture documents locataires: $error');
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _tenants = tenants.isEmpty ? localPreviewTenants : tenants;
    });
  }

  List<DocumentEntry> get _contractDocuments {
    return _tenants.map((tenant) {
      return DocumentEntry(
        title: tenant.contract.title,
        subtitle: '${tenant.name} - ${tenant.propertyName}',
        date: tenant.contract.dateLabel,
        state: tenant.contract.state,
        icon: Icons.description_outlined,
        tint: const Color(0xFFE8F1FF),
      );
    }).toList();
  }

  List<DocumentEntry> get _inventoryDocuments {
    return _tenants.map((tenant) {
      return DocumentEntry(
        title: tenant.inventory.title,
        subtitle: '${tenant.name} - Chambre ${tenant.roomNumber}',
        date: tenant.inventory.dateLabel,
        state: tenant.inventory.state,
        icon: Icons.home_work_outlined,
        tint: const Color(0xFFFFF5E6),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final contractDocuments = _contractDocuments;
    final inventoryDocuments = _inventoryDocuments;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Documents',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DocumentHero(),
              const SizedBox(height: 18),
              _DocumentOverviewRow(
                contractCount: contractDocuments.length,
                inventoryCount: inventoryDocuments.length,
              ),
              const SizedBox(height: 18),
              _DocumentSection(
                title: 'Contrats',
                subtitle: 'Baux actifs, renouvellements et signatures a suivre',
                accentColor: const Color(0xFF2B7FFF),
                items: contractDocuments,
              ),
              const SizedBox(height: 18),
              _DocumentSection(
                title: 'Etats des lieux',
                subtitle: 'Entrees, sorties et controles de chambres',
                accentColor: const Color(0xFFF39C12),
                items: inventoryDocuments,
              ),
              const SizedBox(height: 18),
              const _UploadPanel(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
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
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Profil()),
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

class DocumentEntry {
  final String title;
  final String subtitle;
  final String date;
  final String state;
  final IconData icon;
  final Color tint;

  const DocumentEntry({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.state,
    required this.icon,
    required this.tint,
  });
}

class _DocumentHero extends StatelessWidget {
  const _DocumentHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF1F6FEB), Color(0xFF63B3ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Espace documentaire',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Retrouvez vos contrats, vos etats des lieux et vos fichiers scannes dans un seul espace clair.',
            style: TextStyle(
              color: Color(0xFFDDEAF8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentOverviewRow extends StatelessWidget {
  final int contractCount;
  final int inventoryCount;

  const _DocumentOverviewRow({
    required this.contractCount,
    required this.inventoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniInfoCard(
            title: 'Contrats',
            value: '$contractCount',
            subtitle: '$contractCount locataires',
            icon: Icons.description_outlined,
            color: const Color(0xFFE8F1FF),
            iconColor: const Color(0xFF2B7FFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniInfoCard(
            title: 'Etats des lieux',
            value: '$inventoryCount',
            subtitle: '$inventoryCount locataires',
            icon: Icons.home_work_outlined,
            color: const Color(0xFFFFF5E6),
            iconColor: const Color(0xFFF39C12),
          ),
        ),
      ],
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _MiniInfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
                    color: Color(0xFF607086),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF132238),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7D8CA0),
                    fontSize: 12,
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

class _DocumentSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<DocumentEntry> items;

  const _DocumentSection({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.items,
  });

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.folder_copy_outlined, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF132238),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6C7B8D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DocumentCard(entry: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentEntry entry;

  const _DocumentCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(entry.icon, color: const Color(0xFF132238)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF132238),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  style: const TextStyle(color: Color(0xFF526072)),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.date,
                  style: const TextStyle(color: Color(0xFF6C7B8D)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              entry.state,
              style: const TextStyle(
                color: Color(0xFF132238),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPanel extends StatefulWidget {
  const _UploadPanel();

  @override
  State<_UploadPanel> createState() => _UploadPanelState();
}

class _UploadPanelState extends State<_UploadPanel> {
  String? _lastScanLabel;

  Future<void> openScan() async {
    final label = await Navigator.of(context).pushNamed<String>('/scan');

    if (label == null || !mounted) {
      return;
    }

    setState(() {
      _lastScanLabel = label;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document scanne ajoute.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF132238),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scanner ou ajouter un document',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pour l\'instant les actions sont pretes cote interface. Vous pourrez ensuite les brancher a l\'upload ou au scanner.',
            style: TextStyle(color: Color(0xFFD4DFEA), height: 1.4),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: openScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF132238),
                ),
                child: const Text('Scanner'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF5C7FA3)),
                ),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Envoyer'),
              ),
            ],
          ),
          if (_lastScanLabel != null) ...[
            const SizedBox(height: 14),
            Text(
              _lastScanLabel!,
              style: const TextStyle(
                color: Color(0xFFD4DFEA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

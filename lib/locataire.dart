import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_locative/ajout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantDocument {
  final String title;
  final String reference;
  final String dateLabel;
  final String state;

  const TenantDocument({
    required this.title,
    required this.reference,
    required this.dateLabel,
    required this.state,
  });

  factory TenantDocument.fromMap(Map<String, dynamic>? map) {
    return TenantDocument(
      title: _readString(map, 'title', fallback: 'Document'),
      reference: _readString(map, 'reference', fallback: 'Sans reference'),
      dateLabel: _readString(map, 'dateLabel', fallback: 'Date non renseignee'),
      state: _readString(map, 'state', fallback: 'Non renseigne'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'reference': reference,
      'dateLabel': dateLabel,
      'state': state,
    };
  }
}

class TenantRecord {
  final String? id;
  final String name;
  final String roomNumber;
  final String propertyName;
  final String phone;
  final String email;
  final String rentAmount;
  final String statusLabel;
  final Color statusColor;
  final String balanceLabel;
  final String occupationLabel;
  final TenantDocument contract;
  final TenantDocument inventory;
  final String paymentSummary;
  final String notes;
  final String emergencyContact;

  const TenantRecord({
    this.id,
    required this.name,
    required this.roomNumber,
    required this.propertyName,
    required this.phone,
    required this.email,
    required this.rentAmount,
    required this.statusLabel,
    required this.statusColor,
    required this.balanceLabel,
    required this.occupationLabel,
    required this.contract,
    required this.inventory,
    required this.paymentSummary,
    required this.notes,
    required this.emergencyContact,
  });

  factory TenantRecord.fromMap(Map<String, dynamic> data) {
    final status = _readString(data, 'statusLabel', fallback: 'A jour');

    return TenantRecord(
      id: _readOptionalString(data, 'id'),
      name: _readString(data, 'name', fallback: 'Locataire sans nom'),
      roomNumber: _readString(data, 'roomNumber', fallback: '-'),
      propertyName: _readString(
        data,
        'propertyName',
        fallback: 'Bien non renseigne',
      ),
      phone: _readString(data, 'phone', fallback: 'Telephone non renseigne'),
      email: _readString(data, 'email', fallback: 'Email non renseigne'),
      rentAmount: _readString(data, 'rentAmount', fallback: '0 FCFA'),
      statusLabel: status,
      statusColor: _statusColorFor(status),
      balanceLabel: _readString(
        data,
        'balanceLabel',
        fallback: 'Suivi non renseigne',
      ),
      occupationLabel: _readString(
        data,
        'occupationLabel',
        fallback: 'Date non renseignee',
      ),
      contract: TenantDocument.fromMap(
        data['contract'] is Map<String, dynamic>
            ? data['contract'] as Map<String, dynamic>
            : null,
      ),
      inventory: TenantDocument.fromMap(
        data['inventory'] is Map<String, dynamic>
            ? data['inventory'] as Map<String, dynamic>
            : null,
      ),
      paymentSummary: _readString(
        data,
        'paymentSummary',
        fallback: 'Aucun paiement renseigne',
      ),
      notes: _readString(data, 'notes', fallback: 'Aucune note ajoutee.'),
      emergencyContact: _readString(
        data,
        'emergencyContact',
        fallback: 'Contact urgence non renseigne',
      ),
    );
  }

  TenantRecord copyWith({String? id}) {
    return TenantRecord(
      id: id ?? this.id,
      name: name,
      roomNumber: roomNumber,
      propertyName: propertyName,
      phone: phone,
      email: email,
      rentAmount: rentAmount,
      statusLabel: statusLabel,
      statusColor: statusColor,
      balanceLabel: balanceLabel,
      occupationLabel: occupationLabel,
      contract: contract,
      inventory: inventory,
      paymentSummary: paymentSummary,
      notes: notes,
      emergencyContact: emergencyContact,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'roomNumber': roomNumber,
      'propertyName': propertyName,
      'phone': phone,
      'email': email,
      'rentAmount': rentAmount,
      'statusLabel': statusLabel,
      'balanceLabel': balanceLabel,
      'occupationLabel': occupationLabel,
      'contract': contract.toMap(),
      'inventory': inventory.toMap(),
      'paymentSummary': paymentSummary,
      'notes': notes,
      'emergencyContact': emergencyContact,
    };
  }
}

String? _readOptionalString(Map<String, dynamic>? map, String key) {
  final value = map?[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return null;
}

String _readString(
  Map<String, dynamic>? map,
  String key, {
  required String fallback,
}) {
  final value = map?[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return fallback;
}

Color _statusColorFor(String status) {
  switch (status) {
    case 'Retard':
      return const Color(0xFFD64545);
    case 'Paiement attendu':
      return const Color(0xFFF39C12);
    default:
      return const Color(0xFF149954);
  }
}

const List<TenantRecord> _localPreviewTenants = [
  TenantRecord(
    id: 'preview_1',
    name: 'Afi Mensah',
    roomNumber: 'A12',
    propertyName: 'Residence Les Palmiers',
    phone: '+229 97 45 12 30',
    email: 'afi.mensah@email.com',
    rentAmount: '75 000 FCFA',
    statusLabel: 'A jour',
    statusColor: Color(0xFF149954),
    balanceLabel: 'Solde regle pour mai',
    occupationLabel: 'Depuis janvier 2026',
    contract: TenantDocument(
      title: 'Contrat A12',
      reference: 'CTR-A12-2026',
      dateLabel: 'Cree le 5 janvier 2026',
      state: 'Signe',
    ),
    inventory: TenantDocument(
      title: 'Etat des lieux A12',
      reference: 'EDL-A12-2026',
      dateLabel: 'Fait le 5 janvier 2026',
      state: 'Complet',
    ),
    paymentSummary: 'Dernier paiement: 75 000 FCFA le 10 mai',
    notes: 'Locataire ponctuelle, dossier complet.',
    emergencyContact: 'Contact urgence: Koffi Mensah - 96 21 44 70',
  ),
  TenantRecord(
    id: 'preview_2',
    name: 'Jean Houngbo',
    roomNumber: 'B04',
    propertyName: 'Immeuble Akpakpa Centre',
    phone: '+229 95 18 44 02',
    email: 'jean.houngbo@email.com',
    rentAmount: '60 000 FCFA',
    statusLabel: 'Paiement attendu',
    statusColor: Color(0xFFF39C12),
    balanceLabel: 'Paiement attendu cette semaine',
    occupationLabel: 'Depuis mars 2026',
    contract: TenantDocument(
      title: 'Contrat B04',
      reference: 'CTR-B04-2026',
      dateLabel: 'Cree le 12 mars 2026',
      state: 'Signe',
    ),
    inventory: TenantDocument(
      title: 'Etat des lieux B04',
      reference: 'EDL-B04-2026',
      dateLabel: 'A verifier',
      state: 'En cours',
    ),
    paymentSummary: 'Prochaine echeance: 60 000 FCFA',
    notes: 'Relancer si le paiement n arrive pas avant vendredi.',
    emergencyContact: 'Contact urgence: Mariam Houngbo - 91 32 80 16',
  ),
  TenantRecord(
    id: 'preview_3',
    name: 'Nadia Soglo',
    roomNumber: 'C07',
    propertyName: 'Villa Fidjrosse',
    phone: '+229 99 07 63 21',
    email: 'nadia.soglo@email.com',
    rentAmount: '120 000 FCFA',
    statusLabel: 'Retard',
    statusColor: Color(0xFFD64545),
    balanceLabel: '1 mois de retard',
    occupationLabel: 'Depuis novembre 2025',
    contract: TenantDocument(
      title: 'Contrat C07',
      reference: 'CTR-C07-2025',
      dateLabel: 'Cree le 2 novembre 2025',
      state: 'Signe',
    ),
    inventory: TenantDocument(
      title: 'Etat des lieux C07',
      reference: 'EDL-C07-2025',
      dateLabel: 'Fait le 2 novembre 2025',
      state: 'Complet',
    ),
    paymentSummary: 'Retard constate sur le mois de mai',
    notes: 'Prevoir une relance et proposer un echeancier.',
    emergencyContact: 'Contact urgence: Eric Soglo - 97 80 14 55',
  ),
];

class Locataire extends StatefulWidget {
  const Locataire({super.key});

  @override
  State<Locataire> createState() => _LocataireState();
}

class _LocataireState extends State<Locataire> {
  List<TenantRecord> _cachedTenants = [];
  static const String _localCacheKey = 'tenants_local';

  @override
  void initState() {
    super.initState();
    _loadCachedTenants();
  }

  Future<void> _loadCachedTenants() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedTenants = preferences.getStringList(_localCacheKey) ?? [];
    final tenants = <TenantRecord>[];

    for (final encodedTenant in encodedTenants) {
      try {
        final decoded = jsonDecode(encodedTenant);
        if (decoded is Map<String, dynamic>) {
          tenants.add(TenantRecord.fromMap(decoded));
        }
      } catch (error) {
        debugPrint('Erreur lecture cache locataire: $error');
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _cachedTenants = tenants;
    });
  }

  Future<void> _saveCachedTenants(List<TenantRecord> tenants) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _localCacheKey,
      tenants.map((tenant) => jsonEncode(tenant.toMap())).toList(),
    );
  }

  void _replaceCachedTenants(List<TenantRecord> tenants) {
    if (_sameTenantIds(_cachedTenants, tenants)) {
      return;
    }

    setState(() {
      _cachedTenants = tenants;
    });
    _saveCachedTenants(tenants);
  }

  bool _sameTenantIds(List<TenantRecord> first, List<TenantRecord> second) {
    if (first.length != second.length) {
      return false;
    }

    for (var index = 0; index < first.length; index += 1) {
      if (first[index].id != second[index].id) {
        return false;
      }
    }

    return true;
  }

  List<TenantRecord> get _displayTenants {
    if (_cachedTenants.isEmpty) {
      return _localPreviewTenants;
    }
    return _cachedTenants;
  }

  Future<void> _ajout() async {
    final newTenant = await Navigator.of(context).push<TenantRecord>(
      MaterialPageRoute(builder: (context) => const Ajout()),
    );

    if (newTenant == null || !mounted) {
      return;
    }

    final tenantToSave = newTenant.copyWith(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
    );
    _replaceCachedTenants([tenantToSave, ..._cachedTenants]);
    _showSnackBar('${tenantToSave.name} a ete ajoute en local.');
  }

  Future<void> _deleteTenant(TenantRecord tenant) async {
    final tenantId = tenant.id;

    if (tenantId == null) {
      _showSnackBar('Impossible de supprimer ce locataire.');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le locataire'),
          content: Text('Voulez-vous supprimer ${tenant.name} de la liste ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD64545),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final updatedCache = _cachedTenants
        .where((cachedTenant) => cachedTenant.id != tenantId)
        .toList();
    _replaceCachedTenants(updatedCache);

    if (!mounted) return;
    _showSnackBar('${tenant.name} a ete supprime.');
  }

  Widget _buildLocalTenantBody() {
    return _TenantList(
      tenants: _displayTenants,
      onShowDetails: _showTenantDetails,
      onDelete: _deleteTenant,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showTenantDetails(TenantRecord tenant) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8EF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2D5C5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF132238),
                        child: Text(
                          tenant.name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant.name,
                              style: const TextStyle(
                                color: Color(0xFF132238),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tenant.propertyName,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailGrid(tenant: tenant),
                  const SizedBox(height: 16),
                  _DocumentTile(
                    icon: Icons.description_outlined,
                    title: tenant.contract.title,
                    reference: tenant.contract.reference,
                    dateLabel: tenant.contract.dateLabel,
                    state: tenant.contract.state,
                  ),
                  const SizedBox(height: 12),
                  _DocumentTile(
                    icon: Icons.fact_check_outlined,
                    title: tenant.inventory.title,
                    reference: tenant.inventory.reference,
                    dateLabel: tenant.inventory.dateLabel,
                    state: tenant.inventory.state,
                  ),
                  const SizedBox(height: 16),
                  _InfoPanel(
                    title: 'Coordonnees',
                    lines: [
                      tenant.phone,
                      tenant.email,
                      tenant.emergencyContact,
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoPanel(
                    title: 'Suivi',
                    lines: [
                      tenant.balanceLabel,
                      tenant.paymentSummary,
                      tenant.notes,
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Locataires',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajout,
        backgroundColor: const Color(0xFF132238),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Ajouter'),
      ),
      body: SafeArea(child: _buildLocalTenantBody()),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final TenantRecord tenant;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TenantCard({
    required this.tenant,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFE0B2),
                child: Text(
                  tenant.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF132238),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.name,
                      style: const TextStyle(
                        color: Color(0xFF132238),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Chambre ${tenant.roomNumber} - ${tenant.rentAmount}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: tenant.statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tenant.statusLabel,
                        style: TextStyle(
                          color: tenant.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Supprimer',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFFD64545),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TenantList extends StatelessWidget {
  final List<TenantRecord> tenants;
  final void Function(TenantRecord tenant) onShowDetails;
  final void Function(TenantRecord tenant) onDelete;

  const _TenantList({
    required this.tenants,
    required this.onShowDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: tenants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        return _TenantCard(
          tenant: tenant,
          onTap: () => onShowDetails(tenant),
          onDelete: () => onDelete(tenant),
        );
      },
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final TenantRecord tenant;

  const _DetailGrid({required this.tenant});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: [
        _MetricTile(
          icon: Icons.meeting_room_outlined,
          label: 'Chambre',
          value: tenant.roomNumber,
        ),
        _MetricTile(
          icon: Icons.payments_outlined,
          label: 'Loyer',
          value: tenant.rentAmount,
        ),
        _MetricTile(
          icon: Icons.event_available_outlined,
          label: 'Occupation',
          value: tenant.occupationLabel,
        ),
        _MetricTile(
          icon: Icons.verified_outlined,
          label: 'Statut',
          value: tenant.statusLabel,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE67E22), size: 22),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF132238),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reference;
  final String dateLabel;
  final String state;

  const _DocumentTile({
    required this.icon,
    required this.title,
    required this.reference,
    required this.dateLabel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF132238)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF132238),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$reference - $dateLabel',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            state,
            style: const TextStyle(
              color: Color(0xFFE67E22),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _InfoPanel({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF132238),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines) ...[
            Text(line, style: const TextStyle(color: Color(0xFF526072))),
            if (line != lines.last) const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }
}

class _EmptyTenants extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyTenants({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: Color(0xFFE67E22),
            ),
            const SizedBox(height: 14),
            const Text(
              'Aucun locataire pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF132238),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre premier locataire pour commencer le suivi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthRequired extends StatelessWidget {
  const _AuthRequired();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Connectez-vous pour voir et enregistrer vos locataires.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF132238),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Impossible de charger les locataires.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFD64545)),
        ),
      ),
    );
  }
}

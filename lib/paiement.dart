import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_locative/Dashboard.dart';
import 'package:gestion_locative/document.dart';
import 'package:gestion_locative/locataire.dart';
import 'package:gestion_locative/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paiement extends StatefulWidget {
  const Paiement({super.key});

  @override
  State<Paiement> createState() => _PaiementState();
}

class _PaiementState extends State<Paiement> {
  String _selectedFilter = 'Tous les flux';
  List<PaymentRecord> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadTenantPayments();
  }

  Future<void> _loadTenantPayments() async {
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
        debugPrint('Erreur lecture paiements locataires: $error');
      }
    }

    final tenantsToDisplay = tenants.isEmpty ? localPreviewTenants : tenants;

    if (!mounted) {
      return;
    }

    setState(() {
      _payments = tenantsToDisplay.map(PaymentRecord.fromTenant).toList();
    });
  }

  void _markPaymentAsPaid(PaymentRecord payment) {
    final paymentIndex = _payments.indexOf(payment);
    if (paymentIndex == -1) {
      return;
    }

    setState(() {
      _payments[paymentIndex] = payment.copyWith(
        status: 'Paye',
        statusColor: Colors.green,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${payment.tenantName} est marque comme paye.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Paiements',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: _PaymentsContent(
        payments: _payments,
        selectedFilter: _selectedFilter,
        onMarkAsPaid: _markPaymentAsPaid,
        onFilterSelected: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Dashboard()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Document()),
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

class PaymentRecord {
  final String tenantName;
  final String propertyName;
  final String amount;
  final String dueDate;
  final String status;
  final Color statusColor;

  const PaymentRecord({
    required this.tenantName,
    required this.propertyName,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.statusColor,
  });

  factory PaymentRecord.fromTenant(TenantRecord tenant) {
    final status = _paymentStatusForTenantStatus(tenant.statusLabel);

    return PaymentRecord(
      tenantName: tenant.name,
      propertyName: '${tenant.propertyName} - Chambre ${tenant.roomNumber}',
      amount: tenant.rentAmount,
      dueDate: tenant.paymentSummary,
      status: status,
      statusColor: _paymentStatusColor(status),
    );
  }

  PaymentRecord copyWith({
    String? tenantName,
    String? propertyName,
    String? amount,
    String? dueDate,
    String? status,
    Color? statusColor,
  }) {
    return PaymentRecord(
      tenantName: tenantName ?? this.tenantName,
      propertyName: propertyName ?? this.propertyName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

String _paymentStatusForTenantStatus(String status) {
  switch (status) {
    case 'Retard':
      return 'En retard';
    case 'Paiement attendu':
      return 'En attente';
    default:
      return 'Paye';
  }
}

Color _paymentStatusColor(String status) {
  switch (status) {
    case 'En retard':
      return Colors.red;
    case 'En attente':
      return Colors.orange;
    default:
      return Colors.green;
  }
}

class _PaymentsContent extends StatelessWidget {
  final List<PaymentRecord> payments;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final ValueChanged<PaymentRecord> onMarkAsPaid;

  const _PaymentsContent({
    required this.payments,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    final filteredPayments = payments.where((payment) {
      if (selectedFilter == 'Tous les flux') {
        return true;
      }
      return payment.status == selectedFilter;
    }).toList();

    final paidPayments = payments
        .where((payment) => payment.status == 'Paye')
        .toList();
    final pendingPayments = payments
        .where((payment) => payment.status == 'En attente')
        .toList();
    final latePayments = payments
        .where((payment) => payment.status == 'En retard')
        .toList();
    final paidTotal = _sumPayments(paidPayments);
    final pendingTotal = _sumPayments(pendingPayments);
    final lateTotal = _sumPayments(latePayments);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      shrinkWrap: true,
      children: [
        const Text(
          'Suivi des paiements',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          selectedFilter == 'Tous les flux'
              ? 'Consultez rapidement les loyers payes, en attente et en retard.'
              : 'Affichage des loyers filtres sur: $selectedFilter.',
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _PaymentSummaryCard(
                title: 'Montant loyer paye',
                amount: '${_formatPaymentAmount(paidTotal)} FCFA',
                subtitle: '${paidPayments.length} paiements valides',
                color: const Color(0xFFE8F5E9),
                accentColor: Colors.green,
                icon: Icons.check_circle,
              ),
              _PaymentSummaryCard(
                title: 'En attente',
                amount: '${_formatPaymentAmount(pendingTotal)} FCFA',
                subtitle: '${pendingPayments.length} paiements a confirmer',
                color: const Color(0xFFFFF8E1),
                accentColor: Colors.orange,
                icon: Icons.schedule,
              ),
              _PaymentSummaryCard(
                title: 'En retard',
                amount: '${_formatPaymentAmount(lateTotal)} FCFA',
                subtitle: '${latePayments.length} loyers non regles',
                color: const Color(0xFFFFEBEE),
                accentColor: Colors.red,
                icon: Icons.warning_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        const Text(
          'Filtrer les flux',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _PaymentFilterChip(
              label: 'Tous les flux',
              isSelected: selectedFilter == 'Tous les flux',
              onTap: () => onFilterSelected('Tous les flux'),
            ),
            _PaymentFilterChip(
              label: 'En attente',
              isSelected: selectedFilter == 'En attente',
              onTap: () => onFilterSelected('En attente'),
            ),
            _PaymentFilterChip(
              label: 'Paye',
              isSelected: selectedFilter == 'Paye',
              onTap: () => onFilterSelected('Paye'),
            ),
            _PaymentFilterChip(
              label: 'En retard',
              isSelected: selectedFilter == 'En retard',
              onTap: () => onFilterSelected('En retard'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Paiements recents (${filteredPayments.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (filteredPayments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Aucun paiement ne correspond a ce filtre.',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ...filteredPayments.map(
            (payment) => _PaymentTile(
              tenantName: payment.tenantName,
              propertyName: payment.propertyName,
              amount: payment.amount,
              dueDate: payment.dueDate,
              status: payment.status,
              statusColor: payment.statusColor,
              onMarkAsPaid: payment.status == 'Paye'
                  ? null
                  : () => onMarkAsPaid(payment),
            ),
          ),
      ],
    );
  }

  int _sumPayments(List<PaymentRecord> records) {
    return records.fold<int>(
      0,
      (sum, payment) => sum + _amountToInt(payment.amount),
    );
  }

  int _amountToInt(String amount) {
    final digitsOnly = amount.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  String _formatPaymentAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => '${match[1]} ',
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color color;
  final Color accentColor;
  final IconData icon;

  const _PaymentSummaryCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: accentColor,
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _PaymentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C5D99) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1C5D99)
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String tenantName;
  final String propertyName;
  final String amount;
  final String dueDate;
  final String status;
  final Color statusColor;
  final VoidCallback? onMarkAsPaid;

  const _PaymentTile({
    required this.tenantName,
    required this.propertyName,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.statusColor,
    required this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              child: Icon(Icons.payments_outlined, color: statusColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    propertyName,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(dueDate, style: const TextStyle(color: Colors.black45)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onMarkAsPaid != null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: onMarkAsPaid,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('  '),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

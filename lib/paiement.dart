import 'package:flutter/material.dart';
import 'package:gestion_locative/Dashboard.dart';
import 'package:gestion_locative/document.dart';
import 'package:gestion_locative/profil.dart';

class PaiementPage extends StatefulWidget {
  const PaiementPage({super.key});

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  String _selectedFilter = 'Tous les flux';

  final List<PaymentRecord> _payments = [
    PaymentRecord(
      tenantName: 'Sophie Arnaud',
      propertyName: 'Appartement Cotonou - A12',
      amount: '75 000 FCFA',
      dueDate: 'Echeance: 05 Avril 2026',
      status: 'Paye',
      statusColor: Colors.green,
    ),
    PaymentRecord(
      tenantName: 'Marc Leroy',
      propertyName: 'Studio Fidjrosse',
      amount: '60 000 FCFA',
      dueDate: 'Echeance: 10 Avril 2026',
      status: 'En attente',
      statusColor: Colors.orange,
    ),
    PaymentRecord(
      tenantName: 'Aicha Bello',
      propertyName: 'Villa Calavi',
      amount: '120 000 FCFA',
      dueDate: 'Echeance: 02 Avril 2026',
      status: 'En retard',
      statusColor: Colors.red,
    ),
    PaymentRecord(
      tenantName: 'Jean Kossi',
      propertyName: 'Chambre Porto-Novo',
      amount: '35 000 FCFA',
      dueDate: 'Echeance: 12 Avril 2026',
      status: 'Paye',
      statusColor: Colors.green,
    ),
    PaymentRecord(
      tenantName: 'Clarisse Dossou',
      propertyName: 'Residence Ganhi',
      amount: '85 000 FCFA',
      dueDate: 'Echeance: 15 Avril 2026',
      status: 'Paye',
      statusColor: Colors.green,
    ),
    PaymentRecord(
      tenantName: 'Ibrahim Lawani',
      propertyName: 'Cite Universitaire Akpakpa',
      amount: '45 000 FCFA',
      dueDate: 'Echeance: 28 Avril 2026',
      status: 'En attente',
      statusColor: Colors.orange,
    ),
  ];

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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Paiements',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
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
              MaterialPageRoute(builder: (_) => const DocumentPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilPage()),
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

    final paidPayments =
        payments.where((payment) => payment.status == 'Paye').toList();
    final pendingPayments =
        payments.where((payment) => payment.status == 'En attente').toList();
    final latePayments =
        payments.where((payment) => payment.status == 'En retard').toList();
    final paidTotal = _sumPayments(paidPayments);
    final pendingTotal = _sumPayments(pendingPayments);
    final lateTotal = _sumPayments(latePayments);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cardWidth = availableWidth >= 720
                  ? (availableWidth - 24) / 3
                  : availableWidth >= 460
                      ? (availableWidth - 12) / 2
                      : availableWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _PaymentSummaryCard(
                      title: 'Loyers payes',
                      amount: '${_formatPaymentAmount(paidTotal)} FCFA',
                      subtitle: '${paidPayments.length} paiements valides',
                      backgroundColor: const Color(0xFFFFFFFF),
                      accentColor: const Color(0xFF1F9D55),
                      icon: Icons.check_circle,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PaymentSummaryCard(
                      title: 'En attente',
                      amount: '${_formatPaymentAmount(pendingTotal)} FCFA',
                      subtitle:
                          '${pendingPayments.length} paiements a confirmer',
                      backgroundColor: const Color(0xFFFFFFFF),
                      accentColor: const Color(0xFFE68A00),
                      icon: Icons.schedule,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _PaymentSummaryCard(
                      title: 'En retard',
                      amount: '${_formatPaymentAmount(lateTotal)} FCFA',
                      subtitle: '${latePayments.length} loyers non regles',
                      backgroundColor: const Color(0xFFFFFFFF),
                      accentColor: const Color(0xFFD92D20),
                      icon: Icons.warning_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
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
      ),
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
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;

  const _PaymentSummaryCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const Spacer(),
              Container(
                width: 10,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
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
              fontSize: 21,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.payments_outlined, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        propertyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  amount,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    dueDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (onMarkAsPaid != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onMarkAsPaid,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Marquer paye'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F9D55),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

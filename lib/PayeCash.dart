import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_locative/locataire.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ⚠️ ajouté pour récupérer l'uid

class PayeCash extends StatefulWidget {
  const PayeCash({super.key});

  @override
  State<PayeCash> createState() => _PayeCashState();
}

class _PayeCashState extends State<PayeCash> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔄 Fonction de paiement (mise à jour Firestore après succès)
  Future<void> _launchPaymentAPI(String provider, TenantRecord tenant) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final tenantId = tenant.id;

    if (currentUser == null || tenantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'identifier le paiement.")),
      );
      return;
    }

    final url = Uri.parse("https://api.$provider.com/payment"); // Exemple
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "roomNumber": tenant.roomNumber,
        "name": tenant.name,
        "amount": tenant.rentAmount,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      // ✅ Mise à jour du statut dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('locataires')
          .doc(tenantId)
          .update({
            'statusLabel': 'A jour',
            'paymentSummary':
                'Dernier paiement: ${tenant.rentAmount} le ${DateTime.now()}',
          });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Paiement réussi via $provider")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur paiement via $provider")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomNumber = _controller.text.trim().toUpperCase();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('Paiement Cash'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Champ pour entrer le numéro de chambre
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Numero de chambre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(
                  () {},
                ); // ⚠️ force le rebuild pour relancer la recherche
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Valider'),
            ),
            const SizedBox(height: 20),

            // 🔄 StreamBuilder écoute Firestore en temps réel
            if (currentUser == null)
              const Text("Veuillez vous connecter pour voir les locataires.")
            else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('locataires')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final tenants = snapshot.data!.docs
                      .map(
                        (doc) => TenantRecord.fromMap(
                          doc.data() as Map<String, dynamic>,
                        ).copyWith(id: doc.id),
                      )
                      .toList();

                  TenantRecord? tenant;
                  for (final currentTenant in tenants) {
                    if (currentTenant.roomNumber.trim().toUpperCase() ==
                        roomNumber) {
                      tenant = currentTenant;
                      break;
                    }
                  }

                  if (tenant == null) {
                    return const Text("Aucun locataire trouvé");
                  }

                  // ✅ Affichage des infos du locataire + options de paiement
                  final TenantRecord selectedTenant = tenant!;

                  return Column(
                    children: [
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFE0B2),
                            child: Text(
                              selectedTenant.name.isEmpty
                                  ? '?'
                                  : selectedTenant.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text('Occupant: ${selectedTenant.name}'),
                          subtitle: Text(
                            '${selectedTenant.propertyName}\nLoyer: ${selectedTenant.rentAmount}',
                          ),
                          trailing: Text(
                            'Chambre: ${selectedTenant.roomNumber}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          PaymentOption(
                            color: Colors.yellow,
                            label: 'MTN Momo',
                            onTap: () =>
                                _launchPaymentAPI("MTN", selectedTenant),
                          ),
                          PaymentOption(
                            color: Colors.blue,
                            label: 'Moov Money',
                            onTap: () =>
                                _launchPaymentAPI("Moov", selectedTenant),
                          ),
                          PaymentOption(
                            color: Colors.blue,
                            label: 'Celtis Mobile',
                            onTap: () =>
                                _launchPaymentAPI("Celtis", selectedTenant),
                          ),
                          PaymentOption(
                            color: Colors.red,
                            label: 'Banque',
                            onTap: () =>
                                _launchPaymentAPI("Banque", selectedTenant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final paymentLink =
                              "https://gestion-locative-3f02c.web.app";
                          Clipboard.setData(ClipboardData(text: paymentLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lien de paiement copié !"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Copier le lien de paiement",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ✅ Widget réutilisable pour les options de paiement
class PaymentOption extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;
  const PaymentOption({
    super.key,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color,
              child: Text(
                label.split(' ')[0],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

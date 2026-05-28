import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gestion_locative/ajoutMaison.dart';
import 'package:gestion_locative/document.dart';
import 'package:gestion_locative/paiement.dart';
import 'package:gestion_locative/profil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gestion_locative/locataire.dart';

class Dashboard extends StatefulWidget {
  final int initialIndex;
  final String userName;

  const Dashboard({
    super.key,
    this.initialIndex = 0,
    this.userName = 'Utilisateur local',
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late int _selectedIndex;
  Uint8List? _profileImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  static const List<int> _rentAmounts = [50000, 150000, 100000, 70000];

  final List<String> _titles = const [
    'Gestion locative',
    'Paiements',
    'Documents',
    'Profil',
  ];

  final List<Widget> _pages = const [
    _DashboardHomePage(),
    _SimpleTabPage(
      title: 'Profil',
      icon: Icons.person,
      message: 'Le profil utilisateur s\'affichera ici.',
      backgroundColor: Color(0xFFFFF3E0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 1);
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 600,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      _profileImageBytes = bytes;
    });
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ajouter une image'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mode scanner d\'image activé.'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Ajouter depuis la galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajout d\'image depuis la galerie.'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Ajouter depuis la galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedIndex = _selectedIndex == 0 ? 0 : 3;
    final userName = widget.userName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3E0),
        title: _selectedIndex == 0
            ? Row(
                children: [
                  GestureDetector(
                    onTap: () => _showProfileImageOptions(context),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      backgroundImage: _profileImageBytes == null
                          ? null
                          : MemoryImage(_profileImageBytes!),
                      child: _profileImageBytes == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Gestion locative",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                _titles[displayedIndex],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AjoutMaison()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: displayedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Paiement()),
            );
            return;
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Document()),
            );
            return;
          }
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Profil()),
            );
            return;
          }

          setState(() {
            _selectedIndex = index == 0 ? 0 : 1;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(const AssetImage('assets/images/logo (2).png')),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Paiement',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: "Document",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFilterButton(String label, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    ),
  );
}

class _DashboardHomePage extends StatelessWidget {
  const _DashboardHomePage();

  @override
  Widget build(BuildContext context) {
    final totalRent = _DashboardState._rentAmounts.fold<int>(
      0,
      (sum, rent) => sum + rent,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Statistiques en haut
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Loyer total mensuel",
                  value: '${_formatAmount(totalRent)} FCFA',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: StatCard(
                  title: "Bien Actifs",
                  value: "8",
                  color: Colors.lightBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Boutton filters
            child: Row(
              children: [
                _buildFilterButton(
                  "Tous les biens",
                  () => print("tous les biens"),
                ),
                _buildFilterButton(
                  "Locataires",
                  () => Navigator.pushNamed(context, '/locataire'),
                ),
                _buildFilterButton(
                  "Payé cash",
                  () => Navigator.pushNamed(context, '/payeCash'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Liste des locataires en temps réel ---
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: getLocataires(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text("Erreur de chargement");
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text("Aucun locataire trouvé");
              }

              final locataires = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locataires.length,
                itemBuilder: (context, index) {
                  final locataire = locataires[index];
                  return Card(
                    child: ListTile(
                      title: Text(locataire['nom']),
                      subtitle: Text(
                        "Chambre: ${locataire['chambre']} • Loyer: ${locataire['loyer']}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteLocataire(locataire['id']),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildImageCard(
                "assets/images/image1 (2).jpg",
                "Maison 1",
                "price:50000",
              ),
              _buildImageCard(
                "assets/images/img (2).jpg",
                "Maison 2",
                "price:150.000",
              ),
              _buildImageCard(
                "assets/images/img.jpeg",
                "Villa",
                "price:100.000",
              ),
              _buildImageCard(
                "assets/images/img (2).jpg",
                "Chambre",
                "price:70.000",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimpleTabPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final Color backgroundColor;

  const _SimpleTabPage({
    required this.title,
    required this.icon,
    required this.message,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: Colors.black54),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildImageCard(String path, String title, String price) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(path, fit: BoxFit.cover, width: double.infinity),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _formatAmount(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]} ',
  );
}

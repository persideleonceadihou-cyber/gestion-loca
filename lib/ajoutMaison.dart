import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_locative/app_background.dart';
import 'package:image_picker/image_picker.dart';

class _C {
  static const navy = Color(0xFF1A2B5E);
  static const creamLight = Color(0xFFFDF6DC);
  static const bgPage = Color(0xFFF5F0E8);
  static const white = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1A2B5E);
  static const textMuted = Color(0xFF7A6F52);
  static const border = Color(0xFFECE6D6);
  static const success = Color(0xFF3B6D11);
  static const warning = Color(0xFF854F0B);
  static const danger = Color(0xFF993C1D);
}

class AjoutMaison extends StatefulWidget {
  const AjoutMaison({super.key});

  @override
  State<AjoutMaison> createState() => _AjoutMaisonState();
}

class _AjoutMaisonState extends State<AjoutMaison> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  final _roomsController = TextEditingController();

  String _selectedEtat = 'Disponible';
  String _selectedType = 'Maison';
  bool _isSaving = false;

  // 👉 Variables pour l’image
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    }
  }

  Future<String?> _uploadImage(Uint8List imageBytes, String userId) async {
    final fileName =
        _selectedImageName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(
      'users/$userId/biens/$fileName',
    );
    await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final price = int.tryParse(
      _priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    ) ?? 0;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSaveError('Vous devez être connecté pour ajouter un bien.');
      setState(() => _isSaving = false);
      return;
    }

    // Upload image si sélectionnée
    String? imageUrl;
    if (_selectedImageBytes != null) {
      imageUrl = await _uploadImage(_selectedImageBytes!, user.uid);
    }

    final propertyData = {
      'title': _titleController.text.trim(),
      'location': _addressController.text.trim(),
      'type': _selectedType,
      'price': '${_priceController.text.trim()} FCFA',
      'priceNumber': price,
      'rooms': _roomsController.text.trim(),
      'description': _descController.text.trim(),
      'status': _selectedEtat,
      'isRented': _selectedEtat.toLowerCase().contains('lou'),
      'image': imageUrl ?? '',
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('biens')
          .add(propertyData);

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_titleController.text.trim()} ajouté avec succès !'),
          backgroundColor: _C.success,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, propertyData);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSaveError('Erreur: ${e.toString()}');
    }
  }

  void _showSaveError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _C.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bgPage,
      appBar: AppBar(
        backgroundColor: _C.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajouter un bien',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Nouveau bien immobilier',
                style: TextStyle(fontSize: 12, color: Color(0xFFD0D8F0))),
          ],
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    icon: Icons.home_work_outlined,
                    iconColor: _C.navy,
                    title: 'Type de bien',
                    child: _TypeSelector(
                      selected: _selectedType,
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.edit_outlined,
                    iconColor: _C.navy,
                    title: 'Informations principales',
                    child: Column(
                      children: [
                        _Field(
                          controller: _titleController,
                          label: 'Nom du bien',
                          hint: 'Ex : Villa Les Cocotiers',
                          icon: Icons.home_outlined,
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                controller: _priceController,
                                label: 'Loyer (FCFA)',
                                hint: '150 000',
                                icon: Icons.payments_outlined,
                                keyboardType: TextInputType.number,
                                validator: _required,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Field(
                                controller: _roomsController,
                                label: 'Chambres',
                                hint: 'Ex : 4',
                                icon: Icons.meeting_room_outlined,
                                keyboardType: TextInputType.number,
                                validator: _required,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _addressController,
                          label: 'Adresse',
                          hint: 'Quartier, Ville',
                          icon: Icons.location_on_outlined,
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _descController,
                          label: 'Description',
                          hint: 'Eau courante, compteur, accès...',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.image_outlined,
                    iconColor: _C.navy,
                    title: 'Image du bien',
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text("Choisir une image"),
                        ),
                        const SizedBox(height: 10),
                        if (_selectedImageBytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedImageBytes!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.toggle_on_outlined,
                    iconColor: _C.success,
                    title: 'Etat du bien',
                    child: _EtatSelector(
                      selected: _selectedEtat,
                      onChanged: (value) =>
                          setState(() => _selectedEtat = value),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _SaveButtonContent(isSaving: _isSaving),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }
}

class _SaveButtonContent extends StatelessWidget {
  final bool isSaving;

  const _SaveButtonContent({required this.isSaving});

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Enregistrement...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_home_outlined, color: Colors.white, size: 20),
        SizedBox(width: 10),
        Text(
          'Enregistrer le bien',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _C.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: _C.textMain,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _C.textMuted, fontSize: 13),
        hintStyle: TextStyle(
          color: _C.textMuted.withValues(alpha: 0.55),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: _C.textMuted, size: 20),
        filled: true,
        fillColor: _C.creamLight,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.border, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.navy, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.danger, width: 1.8),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  static const _types = [
    _TypeOption('Maison', Icons.home_outlined),
    _TypeOption('Villa', Icons.villa_outlined),
    _TypeOption('Appartement', Icons.apartment_outlined),
    _TypeOption('Numero', Icons.meeting_room_outlined),
    _TypeOption('Bureau', Icons.business_outlined),
    _TypeOption('Studio', Icons.bed_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((type) {
        final isSelected = selected == type.label;
        return GestureDetector(
          onTap: () => onChanged(type.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? _C.navy : _C.creamLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? _C.navy : _C.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 15,
                  color: isSelected ? Colors.white : _C.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _C.textMain,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TypeOption {
  final String label;
  final IconData icon;

  const _TypeOption(this.label, this.icon);
}

class _EtatSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _EtatSelector({required this.selected, required this.onChanged});

  static const _states = [
    _EtatOption('Disponible', _C.success, Icons.check_circle_outline_rounded),
    _EtatOption('Loue', _C.navy, Icons.people_outline_rounded),
    _EtatOption('En travaux', _C.warning, Icons.construction_outlined),
    _EtatOption('Indisponible', _C.danger, Icons.block_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _states.map((state) {
        final isSelected = selected == state.label;
        return GestureDetector(
          onTap: () => onChanged(state.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? state.color.withValues(alpha: 0.08)
                  : _C.creamLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? state.color : _C.border,
                width: isSelected ? 1.8 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  state.icon,
                  color: isSelected ? state.color : _C.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  state.label,
                  style: TextStyle(
                    color: isSelected ? state.color : _C.textMain,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_rounded, color: state.color, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EtatOption {
  final String label;
  final Color color;
  final IconData icon;

  const _EtatOption(this.label, this.color, this.icon);
}

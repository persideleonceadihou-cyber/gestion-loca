import 'package:flutter/material.dart';
import 'package:gestion_locative/locataire.dart';

class   Ajout extends StatefulWidget {
  const Ajout({super.key});

  @override
  State<Ajout> createState() => _AjoutState();
}

class _AjoutState extends State<Ajout> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _propertyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _rentController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedStatus = 'A jour';
  String? _scannedFolderLabel;

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _propertyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rentController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final room = _roomController.text.trim().toUpperCase();
    final property = _propertyController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final rent = _rentController.text.trim();
    final emergencyContact = _contactController.text.trim();
    final notes = _notesController.text.trim();
    final dateLabel = _todayLabel();
    final statusColor = _statusColorFor(_selectedStatus);
    final statusMeta = _statusMetaFor(_selectedStatus);

    Navigator.of(context).pop(
      TenantRecord(
        name: name,
        roomNumber: room,
        propertyName: property,
        phone: phone,
        email: email,
        rentAmount: '$rent FCFA',
        statusLabel: _selectedStatus,
        statusColor: statusColor,
        balanceLabel: statusMeta,
        occupationLabel: 'Ajoute le $dateLabel',
        contract: TenantDocument(
          title: 'Contrat $room',
          reference: 'CTR-$room-${DateTime.now().year}',
          dateLabel: 'Cree le $dateLabel',
          state: 'Nouveau',
        ),
        inventory: TenantDocument(
          title: 'Etat des lieux $room',
          reference: 'EDL-$room-${DateTime.now().year}',
          dateLabel: 'A programmer',
          state: 'A faire',
        ),
        paymentSummary: 'Dossier cree, premiere echeance a planifier',
        notes: notes.isEmpty ? 'Aucune note ajoutee pour le moment.' : notes,
        emergencyContact: emergencyContact.isEmpty
            ? 'Contact urgence non renseigne'
            : 'Contact urgence: $emergencyContact',
      ),
    );
  }

  Future<void> _scanFolder() async {
    final label = await Navigator.of(context).pushNamed<String>('/scan');

    if (label == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _scannedFolderLabel = label;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan du dossier termine.'),
        duration: Duration(seconds: 2),
      ),
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
          'Ajouter un locataire',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scanner un dossier',
            onPressed: _scanFolder,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3057), Color(0xFF4FA3D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouveau dossier locataire',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Renseignez les informations principales pour ajouter directement le locataire a votre liste.',
                        style: TextStyle(color: Color(0xFFDDEAF8), height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _FormSectionCard(
                  title: 'Informations principales',
                  child: Column(
                    children: [
                      _TenantTextField(
                        controller: _nameController,
                        label: 'Nom complet',
                        icon: Icons.person_outline,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _TenantTextField(
                              controller: _roomController,
                              label: 'Chambre',
                              icon: Icons.meeting_room_outlined,
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TenantTextField(
                              controller: _rentController,
                              label: 'Loyer',
                              icon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _TenantTextField(
                        controller: _propertyController,
                        label: 'Bien loue',
                        icon: Icons.home_work_outlined,
                        validator: _requiredValidator,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _FormSectionCard(
                  title: 'Coordonnees',
                  child: Column(
                    children: [
                      _TenantTextField(
                        controller: _phoneController,
                        label: 'Telephone',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 14),
                      _TenantTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 14),
                      _TenantTextField(
                        controller: _contactController,
                        label: 'Contact urgence',
                        icon: Icons.support_agent_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _FormSectionCard(
                  title: 'Suivi du dossier',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statut initial',
                        style: TextStyle(
                          color: Color(0xFF132238),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        items: const [
                          DropdownMenuItem(
                            value: 'A jour',
                            child: Text('A jour'),
                          ),
                          DropdownMenuItem(
                            value: 'Paiement attendu',
                            child: Text('Paiement attendu'),
                          ),
                          DropdownMenuItem(
                            value: 'Retard',
                            child: Text('Retard'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF7F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.folder_open_outlined,
                                  color: Color(0xFF132238),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Dossier locataire',
                                    style: TextStyle(
                                      color: Color(0xFF132238),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _scanFolder,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF132238),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.document_scanner_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Scanner'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _scannedFolderLabel ?? 'Aucun scan effectue',
                              style: const TextStyle(
                                color: Color(0xFF526072),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TenantTextField(
                        controller: _notesController,
                        label: 'Notes',
                        icon: Icons.edit_note_outlined,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132238),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text(
                      'Ajouter a la liste',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Veuillez saisir un email valide';
    }
    return null;
  }

  String _todayLabel() {
    const months = [
      'janvier',
      'fevrier',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'aout',
      'septembre',
      'octobre',
      'novembre',
      'decembre',
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
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

  String _statusMetaFor(String status) {
    switch (status) {
      case 'Retard':
        return 'Relance a programmer';
      case 'Paiement attendu':
        return 'Premiere echeance en attente';
      default:
        return 'Dossier cree';
    }
  }
}

class _FormSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormSectionCard({required this.title, required this.child});

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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF132238),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TenantTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _TenantTextField({
    required this.controller,
    required this.label,
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

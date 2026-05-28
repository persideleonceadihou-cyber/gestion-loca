import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_locative/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> registerUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("Utilisateur créé ✅");
  } catch (e) {
    print("Erreur: $e");
  }
}

Future<void> loginUser(
  BuildContext context,
  String email,
  String password,
) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    //  Connexion réussie
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Connexion réussie")));
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Inscrivez-vous d'abord")));
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mot de passe incorrect")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: ${e.message}")));
    }
  }
}
// 🚀 Résultat
// Si un utilisateur tente de se connecter sans compte → message “Inscrivez-vous d’abord”.

Future<void> logoutUser() async {
  await FirebaseAuth.instance.signOut();
  print("Déconnecté ✅");
}

const String usersLocalCacheKey = 'users_local';

class _LoginResult {
  final Map<String, String>? user;
  final String? message;

  const _LoginResult({this.user, this.message});
}

class _RegisterResult {
  final bool success;
  final String message;

  const _RegisterResult({required this.success, this.message = ''});
}

class Connect extends StatefulWidget {
  const Connect({super.key});

  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _showLogin = true; // true = connexion, false = inscription
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isSubmitting = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateForm() async {
    if (_isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_showLogin) {
        final email = _emailController.text.trim().toLowerCase();
        final password = _passwordController.text.trim();

        final result = await _findRegisteredUser(email, password);
        final user = result.user;
        if (user == null) {
          await _askUserToEditCredentials(
            result.message ?? 'Email ou mot de passe incorrect',
          );
          return;
        }

        _showMessage('Connexion reussie');
        _goToDashboard(user['name'] ?? email.split('@').first);
        return;
      }
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      final result = await _registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      if (!result.success) {
        _showMessage(result.message);
        return;
      }

      _showMessage('Inscription reussie');
      _goToDashboard(name);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<_LoginResult> _findRegisteredUser(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final users = await _loadRegisteredUsers();
      final user = users.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {'name': email.split('@').first, 'email': email},
      );
      return _LoginResult(user: user);
    } on FirebaseAuthException catch (error) {
      debugPrint('Erreur connexion Firebase: ${error.code}');
      return _LoginResult(message: _firebaseAuthMessage(error));
    }
  }

  Future<_RegisterResult> _registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final users = await _loadRegisteredUsers();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.updatePhotoURL("https://..."); // optionnel
await credential.user?.reload(); // ⚠️ recharge les infos
    } on FirebaseAuthException catch (error) {
      debugPrint('Erreur inscription Firebase: ${error.code}');
      return _RegisterResult(
        success: false,
        message: _firebaseAuthMessage(error),
      );
    }

    users.add({'name': name, 'email': email, 'phone': phone});

    await preferences.setStringList(
      usersLocalCacheKey,
      users.map((user) => jsonEncode(user)).toList(),
    );

    return const _RegisterResult(success: true);
  }

  String _firebaseAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
        return 'Email ou mot de passe incorrect';
      case 'user-not-found':
        return "Aucun compte Firebase n'existe avec cet email";
      case 'user-disabled':
        return 'Ce compte a ete desactive dans Firebase';
      case 'email-already-in-use':
        return 'Cet email existe deja dans Firebase. Connectez-vous.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caracteres';
      case 'invalid-email':
        return "L'adresse email est invalide";
      case 'operation-not-allowed':
        return 'Active Email/Password dans Firebase Authentication';
      case 'network-request-failed':
        return 'Connexion internet indisponible';
      case 'too-many-requests':
        return 'Trop de tentatives. Reessayez dans quelques minutes';
      case 'missing-email':
        return 'Entrez votre email';
      case 'missing-password':
        return 'Entrez votre mot de passe';
      case 'requires-recent-login':
        return 'Reconnectez-vous avant de modifier le mot de passe';
      default:
        return error.message ?? 'Erreur Firebase: ${error.code}';
    }
  }

  Future<List<Map<String, String>>> _loadRegisteredUsers() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedUsers = preferences.getStringList(usersLocalCacheKey) ?? [];
    final users = <Map<String, String>>[];

    for (final encodedUser in encodedUsers) {
      try {
        final decoded = jsonDecode(encodedUser);
        if (decoded is Map<String, dynamic>) {
          users.add(
            decoded.map((key, value) => MapEntry(key, value?.toString() ?? '')),
          );
        }
      } catch (error) {
        debugPrint('Erreur lecture utilisateur local: $error');
      }
    }

    return users;
  }

  void _goToDashboard(String userName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Dashboard(userName: userName)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _askUserToEditCredentials(String message) async {
    _showMessage(message);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connexion impossible'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPasswordResetDialog();
            },
            child: const Text('Reinitialiser le mot de passe'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPasswordResetDialog() async {
    final resetFormKey = GlobalKey<FormState>();
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reinitialiser le mot de passe'),
          content: Form(
            key: resetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Entrez votre email. Vous recevrez un lien pour choisir un nouveau mot de passe.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!resetFormKey.currentState!.validate()) {
                  return;
                }

                final email = emailController.text.trim().toLowerCase();

                try {
                  await _auth.sendPasswordResetEmail(email: email);
                } on FirebaseAuthException catch (error) {
                  debugPrint('Erreur reinitialisation Firebase: ${error.code}');
                  _showMessage(_firebaseAuthMessage(error));
                  return;
                }

                if (!mounted) return;
                Navigator.pop(context);
                _passwordController.clear();
                _confirmPasswordController.clear();
                _emailController.text = email;
                _showMessage(
                  'Email envoye si un compte Firebase existe pour $email.',
                );
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      );
    } finally {
      emailController.dispose();
    }
  }

  void _toggleMode() {
    setState(() {
      _showLogin = !_showLogin;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _showPassword = false;
      _showConfirmPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D9),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo (2).png', height: 120),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        _showLogin
                            ? 'connectez-vous'
                            : ' inscrivez-vous pour creer votre compte',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _showLogin
                            ? 'Connectez-vous pour acceder a votre tableau de bord'
                            : 'Ajoutez vos informations pour ouvrir votre espace',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 20),
                      if (_showLogin) ...[
                        _buildTextField(
                          controller: _emailController,
                          icon: Icons.email,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _passwordController,
                          icon: Icons.lock,
                          hintText: 'Mot de passe',
                          obscureText: !_showPassword,
                          validator: _passwordValidator,
                          suffixIcon: _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onSuffixTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showPasswordResetDialog,
                            child: const Text('Mot de passe oublie ?'),
                          ),
                        ),
                      ] else ...[
                        _buildTextField(
                          controller: _nameController,
                          icon: Icons.person,
                          hintText: 'Nom complet',
                          validator: (value) =>
                              _requiredValidator(value, 'Nom complet'),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _emailController,
                          icon: Icons.email,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _phoneController,
                          icon: Icons.phone,
                          hintText: 'Numero de telephone',
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              _requiredValidator(value, 'Numero de telephone'),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _passwordController,
                          icon: Icons.lock,
                          hintText: 'Mot de passe',
                          obscureText: !_showPassword,
                          validator: _passwordValidator,
                          suffixIcon: _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onSuffixTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          icon: Icons.lock,
                          hintText: 'Confirmer votre mot de passe',
                          obscureText: !_showConfirmPassword,
                          validator: _confirmPasswordValidator,
                          suffixIcon: _showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onSuffixTap: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _validateForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _showLogin ? 'Se connecter' : "S'inscrire",
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _toggleMode,
                child: Text(
                  _showLogin
                      ? "Pas encore de compte ? S'inscrire"
                      : 'Deja un compte ? Se connecter',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap),
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est obligatoire';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredError = _requiredValidator(value, 'Email');
    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Veuillez saisir un email valide';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final requiredError = _requiredValidator(value, 'Mot de passe');
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 6) {
      return 'Au moins 6 caracteres';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredError = _requiredValidator(
      value,
      'Confirmation du mot de passe',
    );
    if (requiredError != null) {
      return requiredError;
    }

    if (value?.trim() != _passwordController.text.trim()) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}

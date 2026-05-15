import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Connect extends StatefulWidget {
  const Connect({super.key});

  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  bool _isLogin = true;
  bool _showPassword = false;
  bool _isLoading = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _normalizedEmail() {
    return _emailController.text.trim().toLowerCase();
  }

  String _normalizedPassword() {
    return _passwordController.text.trim();
  }

  Future<void> _handleAuth() async {
    if (_isLoading) return;

    if (_isLogin) {
      await _handleLogin();
    } else {
      await _handleSignup();
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_isLoading) return;

    final emailController = TextEditingController(text: _normalizedEmail());

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mot de passe oublie'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Votre email',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(emailController.text.trim().toLowerCase());
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );

    emailController.dispose();

    if (email == null) {
      return;
    }

    if (email.isEmpty) {
      _showErrorSnackBar('Veuillez entrer votre email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Veuillez entrer un email valide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      _showSuccessSnackBar(
        'Email de reinitialisation envoye. Verifiez votre boite mail.',
      );
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Erreur Firebase Auth reinitialisation: ${error.code} - ${error.message}',
      );
      if (!mounted) return;
      _showErrorSnackBar(_firebaseAuthMessage(error));
    } catch (error) {
      debugPrint('Erreur reinitialisation inattendue: $error');
      if (!mounted) return;
      _showErrorSnackBar('Erreur inattendue pendant la reinitialisation');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _normalizedEmail();
    final password = _normalizedPassword();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Veuillez remplir tous les champs');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Veuillez entrer un email valide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signOut();
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      _showSuccessSnackBar('Bienvenue ${credential.user?.email ?? ''}');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Erreur Firebase Auth connexion: ${error.code} - ${error.message}',
      );
      if (!mounted) return;
      _showErrorSnackBar(_firebaseAuthMessage(error));
    } catch (error) {
      debugPrint('Erreur connexion inattendue: $error');
      if (!mounted) return;
      _showErrorSnackBar('Erreur inattendue pendant la connexion');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _normalizedEmail();
    final password = _normalizedPassword();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      _showErrorSnackBar('Veuillez remplir tous les champs');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Veuillez entrer un email valide');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Le mot de passe doit contenir au moins 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _showErrorSnackBar('Impossible de creer le compte');
        return;
      }

      await user.updateDisplayName(name);
      await _saveUserProfile(user, name: name, email: email, phone: phone);
      await user.reload();

      if (!mounted) return;
      _showSuccessSnackBar('Compte cree avec succes pour $name');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Erreur  Auth inscription: ${error.code} - ${error.message}',
      );
      if (!mounted) return;
      _showErrorSnackBar(_firebaseAuthMessage(error));
    } on FirebaseException catch (error) {
      debugPrint(
        'Erreur  d\'inscription: ${error.code} - ${error.message}',
      );
      if (!mounted) return;
      _showErrorSnackBar(error.message ?? 'Erreur ');
    } catch (error) {
      debugPrint('Erreur inscription inattendue: $error');
      if (!mounted) return;
      _showErrorSnackBar('Erreur inattendue pendant l inscription');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUserProfile(
    User user, {
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      debugPrint(
        'Erreur  profil utilisateur: ${error.code} - ${error.message}',
      );
    }
  }

  String _firebaseAuthMessage(FirebaseAuthException error) {
    late final String message;

    switch (error.code) {
      case 'invalid-email':
        message = 'Adresse email invalide';
        break;
      case 'user-not-found':
        message = 'Aucun compte  ne correspond a cet email';
        break;
      case 'wrong-password':
      case 'invalid-credential':
        message =
            'Mot de passe incorrect ou compte introuvable. Essayez Mot de passe oublie.';
        break;
      case 'email-already-in-use':
        message = 'Cet email est deja utilise';
        break;
      case 'weak-password':
        message = 'Le mot de passe est trop faible';
        break;
      case 'operation-not-allowed':
        message =
            'La connexion Email/Mot de passe n est pas activee.';
        break;
      case 'configuration-not-found':
        message =
            'La configuration  Auth est introuvable pour ce projet';
        break;
      case 'api-key-not-valid':
      case 'invalid-api-key':
        message = 'La cle API  est invalide';
        break;
      case 'app-not-authorized':
        message = 'Cette application n est pas autorisee ';
        break;
      case 'unauthorized-domain':
        message = 'Ce domaine n est pas autorise  Auth';
        break;
      case 'network-request-failed':
        message = 'Verifiez votre connexion internet';
        break;
      case 'too-many-requests':
        message = 'Trop de tentatives. Reessayez dans quelques minutes';
        break;
      default:
        message = error.message ?? 'Erreur  Auth';
    }

    if (kDebugMode) {
      return '$message (${error.code})';
    }
    return message;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFFFF3E0)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 26),
            child: Column(
              children: [
                const SizedBox(height: 2),
                Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          color: const Color(0xFFFFF3E0),
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFFFF3E0),
                              BlendMode.multiply,
                            ),
                            child: Image.asset(
                              'assets/images/logo (2).png',
                              width: 100,
                              height: 100,
                              
                            ),
                          ),
                        ),
                      ],
                    ), 
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      Text(
                        _isLogin ? 'Se connecter' : 'Creer un compte',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF132238),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin
                            ? 'Connectez-vous pour acceder a votre tableau de bord.'
                            : 'Ajoutez vos informations pour ouvrir votre espace.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF6C7B8D),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_isLogin) ...[
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nom complet',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      if (!_isLogin) ...[
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Numero de telephone',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF1C5D99),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      if (_isLogin) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : _handleForgotPassword,
                            child: const Text(
                              'Mot de passe oublie ?',
                              style: TextStyle(
                                color: Color(0xFF1C5D99),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132238),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isLogin ? 'Se connecter' : 'S\'inscrire',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Pas encore de compte ? '
                                : 'Deja un compte ? ',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _emailController.clear();
                                _passwordController.clear();
                                _nameController.clear();
                                _phoneController.clear();
                                _showPassword = false;
                              });
                            },
                            child: Text(
                              _isLogin ? 'S\'inscrire' : 'Se connecter',
                              style: const TextStyle(
                                color: Color(0xFF1C5D99),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: const BorderSide(color: Color(0xFF1C5D99), width: 2),
        ),
      ),
    );
  }
}

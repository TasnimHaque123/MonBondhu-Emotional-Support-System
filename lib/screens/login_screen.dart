import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
        _isLoading = false;
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.login(username, password);

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _loginAnonymous() async {
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loginAnonymous();
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('Login', 'লগইন')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => langProvider.toggleLanguage(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.lock,
                    size: 80,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: langProvider.translate('Username', 'ব্যবহারকারীর নাম'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: langProvider.translate('Password', 'পাসওয়ার্ড'),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(langProvider.translate('Login', 'লগইন')),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/register');
                            },
                            child: Text(langProvider.translate(
                                "Don't have an account? Register",
                                "অ্যাকাউন্ট নেই? রেজিস্ট্রেশন করুন")),
                          ),
                          const Divider(height: 30),
                          OutlinedButton(
                            onPressed: _loginAnonymous,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(langProvider.translate(
                                'Continue Anonymously (Privacy Mode)',
                                'নাম গোপন রেখে শুরু করুন (প্রাইভেসি মোড)')),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

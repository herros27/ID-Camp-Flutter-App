import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await AuthService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (response['error'] == false) {
      final result = response['loginResult'];
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', result['token']);
      await prefs.setString('name', result['name']);
      await prefs.setString('userId', result['userId']);

      if (!mounted) return;

      context.go('/home');
    } else {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Login Gagal"),
              content: Text(response['message'] ?? "Terjadi kesalahan."),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text("Login")),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                context.go('/register');
              },
              child: const Text("Belum punya akun? Daftar disini"),
            ),
          ],
        ),
      ),
    );
  }
}

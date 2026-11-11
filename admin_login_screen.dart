import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;

  void _verifyAdminPassword() {
    final ok = ref
        .read(authProvider.notifier)
        .authenticateAdmin(_passwordController.text);

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: Invalid Admin Master Password'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pasargad Admin Access')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 72, color: Colors.amberAccent),
            const SizedBox(height: 16),
            const Text(
              'RESTRICTED ADMIN PORTAL',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the hardcoded master password to manage Pasargad Panel WireGuard users.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Admin Master Password',
                prefixIcon: const Icon(Icons.key),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                icon: const Icon(Icons.lock_open),
                label: const Text('UNLOCK ADMIN DASHBOARD'),
                onPressed: _verifyAdminPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

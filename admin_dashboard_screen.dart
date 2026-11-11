import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<int> _quotaOptionsGb = [5, 10, 25, 50, 100, 250];
  int _selectedQuotaGb = 50;

  Future<void> _handleCreateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).adminCreateUser(
          username: _usernameController.text,
          password: _passwordController.text,
          dataLimitGb: _selectedQuotaGb,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'WireGuard user "${_usernameController.text.trim()}" created with $_selectedQuotaGb GB quota!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _usernameController.clear();
      _passwordController.clear();
    } else {
      final err = ref.read(authProvider).errorMessage ?? 'Failed to create user';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasargad Panel — Admin'),
        actions: [
          IconButton(
            tooltip: 'Lock Admin Session',
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provision New WireGuard Client',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Creates a WireGuard peer on the Pasargad Panel and allocates the selected traffic quota.',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Client Username',
                  hintText: 'e.g., wg_user_01',
                  prefixIcon: Icon(Icons.person_add_alt_1),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Client Password',
                  hintText: 'Assign a strong client password',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<int>(
                value: _selectedQuotaGb,
                decoration: const InputDecoration(
                  labelText: 'Data Traffic Quota (Volume Limit)',
                  prefixIcon: Icon(Icons.data_usage),
                  border: OutlineInputBorder(),
                ),
                items: _quotaOptionsGb
                    .map(
                      (gb) => DropdownMenuItem<int>(
                        value: gb,
                        child: Text('$gb GB (${gb * 1024} MB)'),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedQuotaGb = val);
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  icon: authState.isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.cloud_upload_outlined),
                  label: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text(
                          'CREATE WIREGUARD USER ON PANEL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  onPressed: authState.isLoading ? null : _handleCreateUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

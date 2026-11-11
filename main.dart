import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'ui/screens/client_dashboard_screen.dart';
import 'ui/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PasargadVpnApp()));
}

class PasargadVpnApp extends ConsumerWidget {
  const PasargadVpnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Pasargad WireGuard VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
          surface: const Color(0xFF161B22),
        ),
      ),
      home: authState.isLoading && authState.clientSession == null
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : authState.clientSession != null
              ? const ClientDashboardScreen()
              : const LoginScreen(),
    );
  }
}

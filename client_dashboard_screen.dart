import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vpn_provider.dart';
import '../widgets/quota_progress_card.dart';
import 'login_screen.dart';

class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final vpnState = ref.watch(vpnControllerProvider);
    final session = authState.clientSession;

    if (session == null) {
      return const LoginScreen();
    }

    final stage = vpnState.valueOrNull ?? VpnStage.disconnected;
    final isConnected = stage == VpnStage.connected;
    final isConnecting = stage == VpnStage.connecting || vpnState.isLoading;

    ref.listen<AsyncValue<VpnStage>>(vpnControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Account: ${session.username}'),
        actions: [
          IconButton(
            tooltip: 'Refresh Data Quota',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(authProvider.notifier).refreshClientQuota(),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              if (isConnected) {
                await ref.read(vpnControllerProvider.notifier).toggleVpn();
              }
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            QuotaProgressCard(session: session),
            Column(
              children: [
                GestureDetector(
                  onTap: isConnecting
                      ? null
                      : () => ref.read(vpnControllerProvider.notifier).toggleVpn(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? Colors.greenAccent.withOpacity(0.15)
                          : const Color(0xFF161B22),
                      border: Border.all(
                        color: isConnected
                            ? Colors.greenAccent
                            : isConnecting
                                ? Colors.amberAccent
                                : const Color(0xFF00E5FF),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isConnected
                                  ? Colors.greenAccent
                                  : const Color(0xFF00E5FF))
                              .withOpacity(0.25),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: isConnecting
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.power_settings_new,
                                  size: 64,
                                  color: isConnected
                                      ? Colors.greenAccent
                                      : const Color(0xFF00E5FF),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isConnected ? 'DISCONNECT' : 'CONNECT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: isConnected
                                        ? Colors.greenAccent
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tunnel Status: ${stage.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? Colors.greenAccent : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Endpoint: ${session.serverEndpoint}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const Text(
              'Protected by Native WireGuard® Protocol',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

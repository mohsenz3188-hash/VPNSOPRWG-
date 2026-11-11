import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import '../data/services/wireguard_vpn_service.dart';
import 'auth_provider.dart';

final wireGuardServiceProvider = Provider<WireGuardVpnService>((ref) {
  return WireGuardVpnService();
});

final vpnStageStreamProvider = StreamProvider<VpnStage>((ref) {
  final vpnService = ref.watch(wireGuardServiceProvider);
  return vpnService.vpnStageStream;
});

class VpnControllerNotifier extends StateNotifier<AsyncValue<VpnStage>> {
  final WireGuardVpnService _vpnService;
  final Ref _ref;

  VpnControllerNotifier(this._vpnService, this._ref)
      : super(const AsyncValue.data(VpnStage.disconnected)) {
    _initStageListener();
  }

  Future<void> _initStageListener() async {
    try {
      final currentStage = await _vpnService.getCurrentStage();
      state = AsyncValue.data(currentStage);
    } catch (_) {
      state = const AsyncValue.data(VpnStage.disconnected);
    }

    _vpnService.vpnStageStream.listen((stage) {
      state = AsyncValue.data(stage);
    });
  }

  Future<void> toggleVpn() async {
    final currentStage = state.valueOrNull ?? VpnStage.disconnected;

    if (currentStage == VpnStage.connected || currentStage == VpnStage.connecting) {
      state = const AsyncValue.loading();
      try {
        await _vpnService.disconnect();
        await _ref.read(authProvider.notifier).refreshClientQuota();
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
      return;
    }

    final session = _ref.read(authProvider).clientSession;
    if (session == null) {
      state = AsyncValue.error('No active user configuration found.', StackTrace.current);
      return;
    }

    if (!session.isActive || session.remainingBytes <= 0) {
      state = AsyncValue.error(
        'Your data quota is exhausted or account is inactive.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _vpnService.connect(
        wgQuickConfig: session.wgQuickConfig,
        serverEndpoint: session.serverEndpoint,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final vpnControllerProvider =
    StateNotifierProvider<VpnControllerNotifier, AsyncValue<VpnStage>>((ref) {
  return VpnControllerNotifier(
    ref.watch(wireGuardServiceProvider),
    ref,
  );
});

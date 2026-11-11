import 'dart:async';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';
import '../../core/constants/app_constants.dart';

class WireGuardVpnService {
  final WireGuardFlutterInterface _wireguard = WireGuardFlutter.instance;
  bool _isInitialized = false;

  Stream<VpnStage> get vpnStageStream => _wireguard.vpnStageSnapshot;

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    await _wireguard.initialize(interfaceName: AppConstants.wgInterfaceName);
    _isInitialized = true;
  }

  Future<void> connect({
    required String wgQuickConfig,
    required String serverEndpoint,
  }) async {
    await ensureInitialized();

    if (wgQuickConfig.trim().isEmpty) {
      throw Exception('WireGuard configuration string is empty.');
    }

    await _wireguard.startVpn(
      serverAddress: serverEndpoint,
      wgQuickConfig: wgQuickConfig,
      providerBundleIdentifier: 'com.pasargad.vpn.wg',
    );
  }

  Future<void> disconnect() async {
    await ensureInitialized();
    await _wireguard.stopVpn();
  }

  Future<VpnStage> getCurrentStage() async {
    await ensureInitialized();
    return await _wireguard.stage();
  }
}

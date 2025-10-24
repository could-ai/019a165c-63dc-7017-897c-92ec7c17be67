import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/scan_result.dart';

class NetworkScanner {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<ScanResult> scanNetwork() async {
    final String? ssid = await _networkInfo.getWifiName();
    final String? bssid = await _networkInfo.getWifiBSSID();
    final String? localIp = await _networkInfo.getWifiIP();
    final String? gatewayIp = await _networkInfo.getWifiGatewayIP();

    List<int> openPorts = [];
    if (gatewayIp != null) {
      openPorts = await _scanPorts(gatewayIp);
    }

    List<String> vulnerabilities = _analyzeVulnerabilities(openPorts);

    return ScanResult(
      ssid: ssid,
      bssid: bssid,
      localIp: localIp,
      gatewayIp: gatewayIp,
      openPorts: openPorts,
      vulnerabilities: vulnerabilities,
    );
  }

  Future<List<int>> _scanPorts(String ip) async {
    final List<int> commonPorts = [21, 22, 23, 80, 443, 3389, 8080];
    final List<int> openPorts = [];

    for (int port in commonPorts) {
      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: const Duration(milliseconds: 500),
        );
        openPorts.add(port);
        await socket.close();
      } catch (e) {
        // Port is likely closed
      }
    }
    return openPorts;
  }

  List<String> _analyzeVulnerabilities(List<int> openPorts) {
    List<String> vulnerabilities = [];

    // Placeholder for encryption check
    vulnerabilities.add(
        "Could not determine encryption type. Ensure your network uses WPA2 or WPA3.");

    // Default credentials warning
    vulnerabilities.add(
        "Ensure you have changed the default admin password on your router.");

    if (openPorts.contains(21)) {
      vulnerabilities.add("FTP (Port 21) is open. This protocol is unencrypted and insecure.");
    }
    if (openPorts.contains(23)) {
      vulnerabilities.add("Telnet (Port 23) is open. This protocol is unencrypted and insecure.");
    }
    if (openPorts.contains(80)) {
      vulnerabilities.add("HTTP (Port 80) is open, allowing for unencrypted web traffic to the router admin page.");
    }
     if (openPorts.contains(3389)) {
      vulnerabilities.add("RDP (Port 3389) may be open, potentially exposing a computer to remote desktop attacks.");
    }

    return vulnerabilities;
  }
}

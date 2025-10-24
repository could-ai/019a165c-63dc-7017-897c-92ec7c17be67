import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/scan_result.dart';
import 'services/network_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NetworkScanner _scanner = NetworkScanner();
  ScanResult? _scanResult;
  bool _isLoading = false;
  String? _error;

  Future<void> _startScan() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _scanResult = null;
    });

    // Request location permission for WiFi info
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final result = await _scanner.scanNetwork();
        setState(() {
          _scanResult = result;
        });
      } catch (e) {
        setState(() {
          _error = "Failed to scan network: ${e.toString()}";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _error = "Location permission is required to get Wi-Fi information.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wi-Fi Security Scanner"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _startScan,
              icon: const Icon(Icons.wifi_tethering),
              label: Text(_isLoading ? "Scanning..." : "Scan Current Wi-Fi"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            if (_scanResult != null)
              Expanded(
                child: ScanResultView(result: _scanResult!),
              ),
          ],
        ),
      ),
    );
  }
}

class ScanResultView extends StatelessWidget {
  final ScanResult result;

  const ScanResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      children: [
        _buildResultCard(
          context,
          icon: Icons.wifi,
          title: "Network Information",
          children: [
            _buildInfoRow("SSID", result.ssid ?? "N/A"),
            _buildInfoRow("BSSID", result.bssid ?? "N/A"),
            _buildInfoRow("Your IP", result.localIp ?? "N/A"),
            _buildInfoRow("Router IP", result.gatewayIp ?? "N/A"),
          ],
        ),
        _buildResultCard(
          context,
          icon: Icons.door_front_door_outlined,
          title: "Exposed Ports on Router",
          children: result.openPorts.isEmpty
              ? [const Text("No common exposed ports found.")]
              : result.openPorts
                  .map((port) => _buildInfoRow("Port $port", "Open"))
                  .toList(),
        ),
        _buildResultCard(
          context,
          icon: Icons.security,
          title: "Security Vulnerabilities",
          children: result.vulnerabilities
              .map((vuln) => ListTile(
                    leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    title: Text(vuln),
                    dense: true,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context,
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

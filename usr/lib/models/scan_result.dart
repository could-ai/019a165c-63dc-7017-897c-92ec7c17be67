class ScanResult {
  final String? ssid;
  final String? bssid;
  final String? localIp;
  final String? gatewayIp;
  final List<int> openPorts;
  final List<String> vulnerabilities;

  ScanResult({
    this.ssid,
    this.bssid,
    this.localIp,
    this.gatewayIp,
    this.openPorts = const [],
    this.vulnerabilities = const [],
  });
}

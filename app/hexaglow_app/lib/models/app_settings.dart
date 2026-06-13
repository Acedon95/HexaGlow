/// Connection settings for reaching the HexaGlow ESP32 over UDP.
class AppSettings {
  final String esp32Ip;
  final int port;

  const AppSettings({required this.esp32Ip, this.port = 4210});

  static const defaultSettings = AppSettings(esp32Ip: '192.168.1.100', port: 4210);

  AppSettings copyWith({String? esp32Ip, int? port}) {
    return AppSettings(
      esp32Ip: esp32Ip ?? this.esp32Ip,
      port: port ?? this.port,
    );
  }

  Map<String, dynamic> toJson() => {
        'ip': esp32Ip,
        'port': port,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        esp32Ip: json['ip'] as String,
        port: json['port'] as int? ?? 4210,
      );
}

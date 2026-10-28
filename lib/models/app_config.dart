import 'dart:io';

class AppConfig {
  final String host;
  final int porta;

  const AppConfig({required this.host, required this.porta});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final hostJson = json['host']?.toString().trim();
    return AppConfig(
      host: hostJson != null && hostJson.isNotEmpty ? hostJson : hostPadrao,
      porta: int.tryParse(json['porta']?.toString() ?? '') ?? 8082,
    );
  }

  static String get hostPadrao {
    if (Platform.isWindows) {
      return '127.0.0.1';
    }

    return '127.0.0.1';
  }

  Map<String, dynamic> toJson() {
    return {'host': host, 'porta': porta};
  }

  factory AppConfig.padrao() {
    return AppConfig(host: hostPadrao, porta: 8082);
  }
}

import 'dart:io';

class PdvPaths {
  PdvPaths._();

  static String get basePath {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix';
    }

    return '/vmix/vmix';
  }

  // Imagens comuns do PDV
  static String get picturesPath {
    return '$basePath${Platform.pathSeparator}pictures';
  }

  static String picture(String fileName) {
    return '$picturesPath${Platform.pathSeparator}$fileName';
  }

  // Ícones SVG
  static String get iconsPath {
    return [
      picturesPath,
      'data',
      'assets',
      'icons',
    ].join(Platform.pathSeparator);
  }

  static String icon(String fileName) {
    return '$iconsPath${Platform.pathSeparator}$fileName';
  }

  // Pasta bundle
  static String get bundle {
    return [basePath, 'bundle'].join(Platform.pathSeparator);
  }

  // /bundle/config.json
  static String get config {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\config.json';
    }

    return '$bundle${Platform.pathSeparator}config.json';
  }
}

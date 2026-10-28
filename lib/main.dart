import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:get/get.dart';
import 'package:pdv_flutter/services/app_config_service.dart';

import 'controllers/pdv_controller.dart';
import 'screens/home_screen.dart';
import 'services/pdv_socket_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FullScreen.ensureInitialized();
  FullScreen.setFullScreen(false);

  // WidgetsFlutterBinding.ensureInitialized();

  final config = await AppConfigService().carregar();

  // SOCKET
  final socketService = PdvSocketService();

  Get.put<PdvSocketService>(socketService, permanent: true);

  // CONTROLLER
  Get.put<PdvController>(
    PdvController(socketService: socketService),
    permanent: true,
  );
  runApp(
    //DevicePreview(enabled: !kReleaseMode, builder: (context) => const PdvApp()),
    DevicePreview(enabled: false, builder: (context) => const PdvApp()),
  );
  // CONECTA AO PDV
  WidgetsBinding.instance.addPostFrameCallback((_) {
    socketService.conectar(host: config.host, porta: config.porta);
  });
}

class PdvApp extends StatelessWidget {
  const PdvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDV',
      scaffoldMessengerKey: PdvController.messengerKey,
      home: HomeScreen(),
    );
  }
}

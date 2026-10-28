import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_controller.dart';

class PdvSystemInfo extends StatelessWidget {
  PdvSystemInfo({super.key});

  final PdvController controller = Get.find<PdvController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sistema = controller.sistemaRaw.value;

      // Remove o S| somente da exibição
      String texto = sistema.startsWith('S|') ? sistema.substring(2) : sistema;

      // Extrai somente os campos da primeira parte da mensagem.
      final partePrincipal = texto.split('|').first;

      final campos = RegExp(
        r'Pdv:\S+|Oper:\d+-?|Data:\S+|Prod:\S+\s+\S+|Vrs:\S+|Srv:\S+',
      ).allMatches(partePrincipal).map((match) => match.group(0)!).toList();

      // Remove o hífen final do operador.
      final camposFormatados = campos.map((campo) {
        return campo.startsWith('Oper:')
            ? campo.replaceFirst(RegExp(r'-$'), '')
            : campo;
      }).toList();

      final socketStatus = controller.conectadoPdv.value ? 'ON' : 'OFF';

      final informacao = camposFormatados.join(' ');

      final textoExibido = informacao.isEmpty
          ? 'Socket:$socketStatus'
          : '$informacao Socket:$socketStatus';

      // Define a cor pelo status do servidor.
      final Color backgroundColor;

      if (sistema.isEmpty) {
        backgroundColor = Colors.grey;
      } else if (sistema.contains('Srv:ON')) {
        backgroundColor = Colors.green;
      } else {
        backgroundColor = Colors.black;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: backgroundColor,
        child: Text(
          textAlign: TextAlign.center,
          textoExibido,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}

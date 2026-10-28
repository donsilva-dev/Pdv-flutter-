import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdv_flutter/controllers/pdv_controller.dart';

class PdvInfoDialog extends StatelessWidget {
  final PdvController pdvController;

  const PdvInfoDialog({super.key, required this.pdvController});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 1100,
        height: 600,
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Informações do PDV',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        pdvController.voltar();
                      },
                      icon: const Icon(Icons.close, size: 28),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Obx(() {
                final informacoes = pdvController.sistemaInformacao;

                if (informacoes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SelectableText(
                      informacoes.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

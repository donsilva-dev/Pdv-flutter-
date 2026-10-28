import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_controller.dart';

class PdvKeyboardDisplay extends StatelessWidget {
  PdvKeyboardDisplay({super.key});

  final PdvController controller = Get.find<PdvController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 50,
        child: Row(
          children: [
            // DISPLAY
            Expanded(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  controller.valorDigitado.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 5),

            // APAGA UM CARACTERE
            SizedBox(
              width: 105,
              height: 50,
              child: Material(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: controller.apagarUltimoDigito,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.backspace_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

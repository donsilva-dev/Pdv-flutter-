import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdv_flutter/config/pdv_path.dart';
import 'package:pdv_flutter/controllers/pdv_controller.dart';
import 'package:pdv_flutter/widgets/pdv_function_button.dart';
import 'package:pdv_flutter/widgets/pdv_info_dialog.dart';
import 'package:pdv_flutter/widgets/pdv_keyboard_display.dart';
import 'package:pdv_flutter/widgets/pdv_numeric_keyboard.dart';
import 'package:pdv_flutter/widgets/pdv_product_panel.dart';
import 'package:pdv_flutter/widgets/pdv_system_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PdvController controller = Get.find<PdvController>();
  bool _modalAberto = false;

  Worker? _informacoesWorker;

  // Variável reativa para a string de data e hora
  var dataHoraFormatada = ''.obs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _atualizarTempo();
    // Atualiza a variável reativa a cada 1 segundo
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _atualizarTempo(),
    );

    _informacoesWorker = ever(controller.mostrarInformacoesPdv, (bool mostrar) {
      if (!mostrar || _modalAberto) return;

      _abrirModalInformacoes();
    });
  }

  void _atualizarTempo() {
    dataHoraFormatada.value = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(DateTime.now());
  }

  void _abrirModalInformacoes() {
    if (_modalAberto) return;

    _modalAberto = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PdvInfoDialog(pdvController: controller);
      },
    ).then((_) {
      _modalAberto = false;
      controller.fecharInformacoesPdv();
    });
    print('[MODAL] 198 - ABRIR');
  }

  @override
  void dispose() {
    _informacoesWorker?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = File(
      '${PdvPaths.picturesPath}${Platform.pathSeparator}logo.png',
    );

    // ==========================================================
    // CONFIGURAÇÕES DA ÁREA DIREITA
    // ==========================================================

    const keyboardWidth = 550.0;

    const buttonHeight = 70.0;

    const spacing = 5.0;

    const keyboardBottom = 8.0;

    const keyboardHeight = (buttonHeight * 4) + (spacing * 3);

    const keyboardDisplayHeight = 50.0;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==================================================
                  // LADO ESQUERDO
                  // ==================================================
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        // CABEÇALHO / LOGO
                        SizedBox(
                          height: 80,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: SizedBox(
                                height: 60,
                                child: logo.existsSync()
                                    ? Image.file(logo)
                                    : const Icon(
                                        Icons.broken_image_outlined,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                          ),
                        ),

                     // Espaço entre a imagem e a data
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Obx(
                              () => Text(
                                controller.dataHoraFormatada.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // DIVIDER
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                          height: 20,
                          endIndent: 10,
                          indent: 10,
                        ),

                        // BOTÕES
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Obx(() {
                              return GridView.count(
                                crossAxisCount: 7,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                                childAspectRatio: 0.9,
                                children: [
                                  if (controller.mostrarBotao('abertura'))
                                    PdvFunctionButton(
                                      label: 'Abertura',
                                      // imagePath: PdvPaths.icon(
                                      //   'iniciar_venda.svg',
                                      // ),
                                      imagePath: '',
                                      icon: Icons.door_front_door,
                                      onPressed: controller.abertura,
                                    ),

                                  if (controller.mostrarBotao('reducaoZ'))
                                    PdvFunctionButton(
                                      label: 'Redução\nZ',

                                      // imagePath: PdvPaths.icon(
                                      //   '${Icon(Icons.logout_outlined)}',
                                      // ),
                                      imagePath: '',
                                      icon: Icons.logout,

                                      onPressed: controller.reducao,
                                    ),

                                  if (controller.mostrarBotao(
                                    'entradaOperador',
                                  ))
                                    PdvFunctionButton(
                                      label: 'Entrada\nOperador',
                                      imagePath: '',
                                      icon: Icons.login,
                                      onPressed: controller.entradaOperador,
                                    ),
                                  if (controller.mostrarBotao('saidaOperador'))
                                    PdvFunctionButton(
                                      label: 'Saída\nOperador',
                                      imagePath: '',
                                      icon: Icons.login,
                                      onPressed: controller.saidaOperador,
                                    ),

                                  if (controller.mostrarBotao('iniciarVenda'))
                                    PdvFunctionButton(
                                      label: 'Iniciar\nVenda',
                                      imagePath: '',
                                      icon: Icons.add_shopping_cart,
                                      onPressed: controller.iniciarVenda,
                                    ),

                                  if (controller.mostrarBotao('cancelaVenda'))
                                    PdvFunctionButton(
                                      label: 'Cancela\nVenda',
                                      imagePath: '',
                                      icon: Icons.cancel_outlined,
                                      onPressed: controller.cancelaVenda,
                                    ),

                                  if (controller.mostrarBotao('cancelaItem'))
                                    PdvFunctionButton(
                                      label: 'Cancela\nItem',
                                      imagePath: '',
                                      icon: Icons.remove_circle_outline,
                                      onPressed: controller.cancelaItem,
                                    ),

                                  if (controller.mostrarBotao(
                                    'administrativaTef',
                                  ))
                                    PdvFunctionButton(
                                      label: 'Administrativa\nTEF',
                                      imagePath: '',
                                      icon: Icons.point_of_sale,
                                      onPressed: controller.admTef,
                                    ),

                                  if (controller.mostrarBotao('cancelaTef'))
                                    PdvFunctionButton(
                                      label: 'Cancelamento\nTEF',
                                      imagePath: '',
                                      icon: Icons.credit_card_off_outlined,
                                      onPressed: controller.cancelaTef,
                                    ),

                                  if (controller.mostrarBotao('reimprimeTef'))
                                    PdvFunctionButton(
                                      label: 'Reimpressão\nTEF',
                                      imagePath: '',
                                      icon: Icons.receipt_long,
                                      onPressed: controller.reimpressaoTef,
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),

                        // FINALIZADORAS
                        Obx(() {
                          if (!controller.estaEmTotal &&
                                  !controller.estaEmRetirada ||
                              !controller.mostrarBotao('finalizadoras')) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'FORMAS DE PAGAMENTOS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // GRID DE FINALIZADORAS COM SCROLL
                              SizedBox(
                                height: 300,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    8,
                                    16,
                                  ),
                                  child: Obx(
                                    () => GridView.count(
                                      crossAxisCount: 7,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                      childAspectRatio: 0.9,
                                      children: [
                                        if (controller.mostrarBotao('dinheiro'))
                                          PdvFunctionButton(
                                            label: 'DINHEIRO',
                                            imagePath: '',
                                            icon: Icons.money,
                                            onPressed: controller.dinheiro,
                                          ),
                                        if (controller.mostrarBotao('credito'))
                                          PdvFunctionButton(
                                            label: 'CRÉDITO',
                                            imagePath: '',
                                            icon: Icons.credit_card,
                                            onPressed: controller.credito,
                                          ),
                                        if (controller.mostrarBotao('debito'))
                                          PdvFunctionButton(
                                            label: 'DÉBITO',
                                            imagePath: '',
                                            icon: Icons.credit_card,
                                            onPressed: controller.debito,
                                          ),
                                        if (controller.mostrarBotao('pos'))
                                          PdvFunctionButton(
                                            label: 'POS',
                                            imagePath: '',
                                            icon: Icons.point_of_sale,

                                            onPressed: controller.pos,
                                          ),

                                        // Adicione as demais finalizadoras aqui.
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        //  VENDA RAPIDA
                        Obx(() {
                          if (!controller.estaEmVenda ||
                              !controller.mostrarBotao('vendaRapida')) {
                            return SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'PRODUTO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // GRID DE VENDARAPIDA COM SCROLL
                              SizedBox(
                                height: 300,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    8,
                                    16,
                                  ),
                                  child: Obx(
                                    () => GridView.count(
                                      crossAxisCount: 7,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                      childAspectRatio: 0.9,
                                      children: [
                                        if (controller.mostrarBotao(
                                          'vendaRapida',
                                        ))
                                          PdvFunctionButton(
                                            label: 'PÃO SIRIO',
                                            imagePath: '',
                                            icon: Icons.bakery_dining,
                                            onPressed: controller.pao,
                                          ),

                                        PdvFunctionButton(
                                          label: 'LEITE \nMoça',
                                          imagePath: '',
                                          icon: Icons.inventory_2,
                                          onPressed: controller.leiteMoca,
                                        ),

                                        // Adicione as demais finalizadoras aqui.
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  // ==================================================
                  // LADO DIREITO
                  // ==================================================
                  SizedBox(
                    width: keyboardWidth + 8,
                    child: Stack(
                      children: [
                        // PRODUTOS
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 8,
                          bottom:
                              keyboardBottom +
                              keyboardHeight +
                              spacing +
                              keyboardDisplayHeight +
                              spacing,
                          child: PdvProductPanel(),
                        ),

                        // DISPLAY DA DIGITAÇÃO
                        Positioned(
                          left: 0,
                          right: 8,
                          bottom: keyboardBottom + keyboardHeight + spacing,
                          height: keyboardDisplayHeight,
                          child: PdvKeyboardDisplay(),
                        ),

                        // TECLADO
                        Positioned(
                          left: 0,
                          right: 8,
                          bottom: keyboardBottom,
                          child: PdvNumericKeyboard(
                            width: keyboardWidth,
                            buttonHeight: buttonHeight,
                            spacing: spacing,
                            onKeyPressed: (value) {
                              if (value == 'Limpa') {
                                controller.limparDigitacao();
                                return;
                              }

                              if (value == 'Entrar') {
                                controller.entrar();
                                return;
                              }

                              if (value == 'Função') {
                                controller.funcao();
                                return;
                              }

                              if (value == 'Voltar') {
                                controller.voltar();
                                return;
                              }

                              if (value == 'Limpar') {
                                controller.limpa();
                                return;
                              }

                              if (value == 'Total') {
                                controller.totalizaVenda();
                                return;
                              }

                              if (value == 'X') {
                                controller.multiplicacao();
                                return;
                              }

                              const teclasDigitacao = {
                                '0',
                                '00',
                                '1',
                                '2',
                                '3',
                                '4',
                                '5',
                                '6',
                                '7',
                                '8',
                                '9',
                                '.',
                              };

                              if (teclasDigitacao.contains(value)) {
                                controller.digitar(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // RODAPÉ
            // ======================================================
            PdvSystemInfo(),
          ],
        ),
      ),
    );
  }
}

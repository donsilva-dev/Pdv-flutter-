import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pdv_controller.dart';

class PdvProductPanel extends StatelessWidget {
  PdvProductPanel({super.key});

  final PdvController controller = Get.find<PdvController>();

  final ScrollController scrollController = ScrollController();
  int ultimoTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildHeaderDivider(),
          _buildProducts(),
          _buildDivider(),
          _buildDisplay(),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return Obx(() {
      final mostrar =
          controller.modoInformacao.value ||
          controller.estaEmVenda ||
          controller.estaEmRetirada ||
          controller.estaEmTotal;

      return mostrar ? _buildDivider() : const SizedBox.shrink();
    });
  }

  // ==========================================================
  // CABEÇALHO
  // ==========================================================

  Widget _buildHeader() {
    return Obx(() {
      if (controller.modoInformacao.value) {
        return Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: const Text(
            'INFORMAÇÕES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      }

      // Fora de venda (ex.: E|2 Disponível) → sem cabeçalho
      if (!controller.estaEmVenda && !controller.estaEmTotal) {
        return SizedBox.shrink();
      }

      // Em venda (E|3) → cabeçalho das colunas
      return Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Row(
          children: const [
            SizedBox(
              width: 35,
              child: Text(
                'SEQ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 90,
              child: Text(
                'QTD/UNI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                'DESCRIÇÃO',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 90,
              child: Text(
                'PREÇO',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ==========================================================
  // PRODUTOS
  // ==========================================================
  Widget _buildProducts() {
    return Expanded(
      child: Obx(() {
        if (controller.modoInformacao.value) {
          return _buildInformacoes();
        }

        return _buildListaProdutos();
      }),
    );
  }

  Widget _buildListaProdutos() {
    final produtos = controller.produtos;

    // SCROLL
    if (produtos.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    if (produtos.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: produtos.length,
      separatorBuilder: (_, _) {
        return Divider(height: 1, color: Colors.grey.shade300);
      },
      itemBuilder: (context, index) {
        return _buildProductItem(produtos[index]);
      },
    );
  }

  // Normaliza: minúsculas, remove espaços repetidos e nas pontas
  static String _normalizar(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  static final List<String> _titulos = [
    'Selecione a opcao desejada',
    'Selecione o tipo de cancelamento',
    'Digite o valor da transacao',
    'Qualquer tecla para continuar...',
    'Data da transacao',
    'Forneca o numero do documento a ser cancelado',
    'Documento Invalido',
    'Tipo do comprovante a ser re-impresso',
    'Tipos de TEF',
  ].map(_normalizar).toList();

  Widget _buildInformacoes() {
    final informacoes = controller.sistemaInformacao;

    if (informacoes.isEmpty) {
      return const Center(
        child: Text(
          'Aguardando informações...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: informacoes.length,
      itemBuilder: (context, index) {
        final texto = informacoes[index];
        final textoNormalizado = _normalizar(texto);
        final ehTitulo = _titulos.any(textoNormalizado.contains);

        if (ehTitulo) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        final partes = texto.split(':');
        final numero = partes.length > 1 ? partes[0] : '';
        final descricao = partes.length > 1
            ? partes.sublist(1).join(':').trim()
            : texto;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  numero.isEmpty ? '' : '$numero:',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(descricao, style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // ITEM DO PRODUTO
  // ==========================================================

  Widget _buildProductItem(dynamic produto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _buildSequence(produto),
          _buildQuantity(produto),
          _buildDescription(produto),
          _buildPrice(produto),
        ],
      ),
    );
  }

  // ==========================================================
  // SEQUÊNCIA
  // ==========================================================

  Widget _buildSequence(dynamic produto) {
    return SizedBox(
      width: 35,
      child: Text(
        '${produto.sequencia}',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
    );
  }

  // ==========================================================
  // QUANTIDADE / UNIDADE
  // ==========================================================

  Widget _buildQuantity(dynamic produto) {
    final bool cancelado = produto.cancelado;
    return SizedBox(
      width: 90,
      child: Text(
        '${produto.quantidade.toStringAsFixed(3)} '
        '${produto.unidade}',
        style: TextStyle(
          color: cancelado ? Colors.red : Colors.black,
          decoration: cancelado
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          decorationColor: Colors.red,
          decorationThickness: 2,

          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==========================================================
  // DESCRIÇÃO
  // ==========================================================

  Widget _buildDescription(dynamic produto) {
    final bool cancelado = produto.cancelado;

    return Expanded(
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            produto.descricao,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: cancelado ? Colors.red : Colors.black,
              decoration: cancelado
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: Colors.red,
              decorationThickness: 2,
            ),
          ),
          if (cancelado)
            Text(
              'Cancelado',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: cancelado ? Colors.red : Colors.black,
                decoration: cancelado
                    ? TextDecoration.none
                    : TextDecoration.none,
                decorationColor: Colors.red,
                decorationThickness: 2,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREÇO
  // ==========================================================

  Widget _buildPrice(dynamic produto) {
    final bool cancelado = produto.cancelado;
    final bool emPromocao = produto.emPromocao;

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // VALOR NORMAL
          if (emPromocao)
            Text(
              'De R\$ ${produto.valorNormal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: cancelado ? Colors.red : Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),

          // VALOR UNIITARIO
          if (!emPromocao)
            Text(
              'R\$ ${produto.valorUnitario.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cancelado ? Colors.red : Colors.green.shade700,
                decoration: cancelado
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.red,
              ),
            ),

          // VALOR PROMOCAO
          if (emPromocao)
            Text(
              'Por: R\$ ${produto.valorTotal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cancelado
                    ? Colors.red
                    : emPromocao
                    ? Colors.green.shade700
                    : Colors.black,
                decoration: cancelado
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.red,
                decorationThickness: 2,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // DISPLAY DO PDV
  // ==========================================================
  Widget _buildDisplay() {
    return Obx(() {
      final principal = controller.displayPrincipal.value;
      final secundario = controller.displaySecundario.value;

      // 1. Dicionário com a frase antiga (Chave) e a frase nova (Valor)
      final Map<String, String> frasesCustomizadas = {
        'MATRIC SAIDA OPER': 'MATRICULA PARA SAIDA DE OPERADOR',
        'SENHA SAIDA OPER': 'SENHA PARA SAIDA DE OPERADOR',
        'SISTEMA MANUT': 'SISTEMA EM MANUTENÇÃO',
        'MATRIC OPERADOR': 'MATRICULA DO OPERADOR',
        'SENHA OPERADOR': 'SENHA DO OPERADOR',
        'MATRIC LIB ENT OPER': 'MATRICULA LIBERA ENTRADA OPERADOR',
        'SENHA LIB ENT OPER': 'SENHA LIBERA ENTRADA OPERADOR',
        'MATRIC RET ZERADA': 'MATRICULA RETIRADA ZERADA',
        'SENHA RET ZERADA': 'SENHA RETIRADA ZERADA',
        'MATRIC FECHAMENTO': 'MATRICULA FECHAMENTO',
        'MATRIC CANCELA VENDA': 'MATRICULA CANCELA VENDA',
        'MATRIC CANCELA ITEM': 'MATRICULA CANCELA ITEM',
        'MATRIC CAN MAIS ITEM': 'MATRICULA CANCELA MAIS ITEM',
        'SENHA CAN MAIS ITEM': 'SENHA CANCELA MAIS ITEM',
        'VALOR INVALIDO(1)': 'INFORME O VALOR',
        'MATRIC CANCELA TEF': 'MATRICULA CANCELA TEF',
        'NCAD': 'PRODUTO NÃO CADASTRADO',
      };

      // 2. Primeiro, tenta encontrar a frase exata.
      String principalModificado = frasesCustomizadas[principal] ?? '';

      // 3. Se não achou a frase exata, trata partes da mensagem por condição
      if (principalModificado.isEmpty) {
        if (principal.startsWith('NCAD')) {
          // Exemplo: se vier "NCAD 78910...", vira "PRODUTO NÃO CADASTRADO 78910..."
          principalModificado = principal.replaceFirst(
            'NCAD',
            'PRODUTO NÃO CADASTRADO',
          );
        } else if (principal.contains('NCAD')) {
          // Se o NCAD estiver em qualquer outra parte do texto
          principalModificado = principal.replaceAll(
            'NCAD',
            'PRODUTO NÃO CADASTRADO',
          );
        } else {
          // Se não corresponder a nenhuma regra, mantém o texto original intocado
          principalModificado = principal;
        }
      }

      return Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              principalModificado,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            if (secundario.isNotEmpty)
              Text(
                secundario,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
          ],
        ),
      );
    });
  }

  // Widget _buildDisplay() {
  //   return Obx(() {
  //     final principal = controller.displayPrincipal.value;
  //     final secundario = controller.displaySecundario.value;

  //     final Map<String, String> dicionarioCorrecoes = {
  //       'MATRIC': 'MATRICULA PARA SAIDA DE',
  //       'OPER': 'SENHA PARA SAIDA DE OPERADOR',
  //       'RET': 'RETIRADA',
  //     };

  //     String texto = principal;

  //     dicionarioCorrecoes.forEach((abreviacao, nomeCompleto) {
  //       texto = texto.replaceAll(
  //         RegExp(r'\b' + abreviacao + r'\b'),
  //         nomeCompleto,
  //       );
  //     });

  //     return Container(
  //       width: double.infinity,
  //       height: 60,
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Text(
  //             texto,
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //           ),
  //           if (secundario.isNotEmpty)
  //             Text(
  //               secundario,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
  //             ),
  //         ],
  //       ),
  //     );
  //   });
  // }

  // ==========================================================
  // DIVISOR
  // ==========================================================

  Widget _buildDivider() {
    return Material(
      elevation: 1,
      color: Colors.grey,
      child: const SizedBox(height: 1, width: double.infinity),
    );
  }
}

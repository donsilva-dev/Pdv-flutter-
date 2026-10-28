import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdv_flutter/models/pdv_product.dart';
import '../services/pdv_socket_service.dart';

class PdvController extends GetxController {
  final PdvSocketService socketService;

  PdvController({required this.socketService});

  StreamSubscription<String>? _socketSubscription;

  StreamSubscription<bool>? _conexaoSubscription;

  final conectadoPdv = false.obs;

  bool? _ultimaConexao;

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // ESTADO
  final statusPdv = 0.obs;

  // DISPLAY
  final displayPrincipal = ''.obs;
  final displaySecundario = ''.obs;

  // MODO INFORMACAO
  final modoInformacao = false.obs;

  // SISTEMA
  final sistemaRaw = ''.obs;

  // VALOR DIGITADO
  final valorDigitado = ''.obs;
  // DISPLAY
  final limpaDisplay = ''.obs;

  // LISTA DE STRING OBSERVAVEL
  final sistemaInformacao = <String>[].obs;
  final mostrarInformacoesPdv = false.obs;

  bool get estaDisponivel => statusPdv.value == 2;
  bool get estaEmVenda => statusPdv.value == 3;
  bool get estaEmTotal => statusPdv.value == 4;
  bool get estaEmRetirada => statusPdv.value == 7;

  // Variável reativa para a string de data e hora
  var dataHoraFormatada = ''.obs;
  Timer? _timer;

  // STATUS DE BOTOES
  // CADA BOTOES INFORMA EM QUAIS STATUS PODEM APARECER.

  final Map<String, List<int>> statusDosBotoes = {
    'abertura': [0],
    'reducaoZ': [1],
    'entradaOperador': [1, 6],
    'saidaOperador': [2],
    'iniciarVenda': [2],
    'cancelaVenda': [3, 4],
    'cancelaItem': [3],
    'administrativaTef': [2],
    'cancelaTef': [2],
    'reimprimeTef': [2],
    'credito': [4],
    'debito': [4],
    'dinheiro': [4, 7],
    'pos': [4],
    'finalizadoras': [4, 7],
    'vendaRapida': [3],
  };

  // Verifica se o botão pode aparecer no status atual.
  bool mostrarBotao(String botao) {
    return statusDosBotoes[botao]?.contains(statusPdv.value) ?? false;
  }

  final produtos = <PdvProduct>[].obs;
  final totalVenda = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _atualizarTempo();
    // Atualiza a variável reativa a cada 1 segundo
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _atualizarTempo(),
    );
    _socketSubscription = socketService.mensagens.listen(processarMensagem);

    _conexaoSubscription = socketService.estadoConexao.listen((conectado) {
      conectadoPdv.value = conectado;

      if (_ultimaConexao == conectado) return;

      _ultimaConexao = conectado;

      if (conectado) {
        print('[PDV] Conexão restabelecida!');
        _aoReconectar();
      } else {
        print('[PDV] Conexão perdida. Aguardando reconexão...');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isClosed) return;

        _mostrarAlertaConexao(conectado: conectado);
      });
    });

    conectadoPdv.value = socketService.conectado;
  }

  void _atualizarTempo() {
    dataHoraFormatada.value = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(DateTime.now());
  }

  void _mostrarAlertaConexao({required bool conectado}) {
    final messenger = messengerKey.currentState;

    if (messenger == null) {
      print('[ALERTA] ScaffoldMessenger ainda indisponível.');
      return;
    }

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              conectado ? Icons.check_circle : Icons.wifi_off,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                conectado
                    ? 'Conexão com o PDV restabelecida.'
                    : 'CONEXÃO COM PDV PERDIDA',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: conectado
            ? Colors.green.shade700
            : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: conectado
            ? const Duration(seconds: 3)
            : const Duration(days: 365),
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          top: MediaQuery.of(messenger.context!).padding.top + 16,
          bottom: MediaQuery.of(messenger.context!).size.height - 70,
        ),
      ),
    );
  }

  void _aoReconectar() {
    print('[PDV] Preparando atualização após reconexão');
  }

  void digitar(String valor) {
    valorDigitado.value += valor;
  }

  void apagarUltimoDigito() {
    if (valorDigitado.value.isEmpty) return;

    valorDigitado.value = valorDigitado.value.substring(
      0,
      valorDigitado.value.length - 1,
    );
  }

  void limparDigitacao() {
    valorDigitado.value = '';
  }

  void processarMensagem(String raw) {
    if (raw.trim().isEmpty) return;

    final partes = raw.split('|');

    if (partes.isEmpty) return;

    switch (partes[0].trim()) {
      case 'E':
        _processarStatus(partes);
        break;

      case 'D':
        _processarDisplay(partes);
        break;

      case 'F':
        _processarFuncao(partes);
        break;

      case 'S':
        _processarSistema(raw);
        break;
      case 'X':
        _processarInformacao(raw);
        break;

      case 'I':
        _processarItem(partes);
        break;

      case 'M':
        _processarMensagem(partes);
        break;
    }
  }

  // M|texto||
  void _processarMensagem(List<String> partes) {
    if (partes.length < 2) return;

    final texto = partes[1].trim();

    if (texto.isEmpty) return;

    print('[MSG PDV] $texto');
  }

  void _processarItem(List<String> partes) {
    if (partes.length < 2) return;

    final tipo = partes[1].trim();

    switch (tipo) {
      // ==========================================================
      // PRODUTO ADICIONADO
      // I|02|...
      // ==========================================================
      case '02':
        _adicionarProduto(partes);
        break;

      // ==========================================================
      // PRODUTO CANCELADO
      // I|03|...
      // ==========================================================
      case '03':
        _cancelarProduto(partes);
        break;

      // ==========================================================
      // TOTAL DA VENDA
      // I|9|25.57||
      // ==========================================================
      case '9':
        _atualizarTotal(partes);
        break;
    }
  }

  void _adicionarProduto(List<String> partes) {
    if (partes.length < 15) return;

    final produto = PdvProduct(
      sequencia: int.tryParse(partes[2].trim()) ?? 0,

      codigo: partes[3].trim(),

      codigoBarras: partes[5].trim(),

      descricao: partes[7].trim(),

      valorUnitario: double.tryParse(partes[8].trim()) ?? 0,

      valorTotal: double.tryParse(partes[9].trim()) ?? 0,

      quantidade: double.tryParse(partes[10].trim()) ?? 0,

      unidade: partes[11].trim(),

      valorNormal: double.tryParse(partes[14].trim()) ?? 0,
      emPromocao: partes[12].trim() == '1',
    );

    // Cada I|02 representa um item independente.
    // NÃO agrupamos produtos iguais.
    produtos.add(produto);

    // Mantém a lista pela sequência real do PDV.
    produtos.sort((a, b) => a.sequencia.compareTo(b.sequencia));

    produtos.refresh();

    print(
      '[PRODUTO ADICIONADO] '
      'SEQ: ${produto.sequencia} | '
      '${produto.descricao}',
    );
  }

  void _cancelarProduto(List<String> partes) {
    if (partes.length < 3) return;

    final sequencia = int.tryParse(partes[2].trim());

    if (sequencia == null) {
      print('[CANCELAMENTO] Sequência inválida');
      return;
    }

    final index = produtos.indexWhere(
      (produto) => produto.sequencia == sequencia,
    );

    if (index == -1) {
      print(
        '[CANCELAMENTO] '
        'Produto da sequência $sequencia não encontrado',
      );

      return;
    }

    // Não removemos o produto.
    // Apenas marcamos como cancelado.
    produtos[index].cancelado = true;

    // Como alteramos uma propriedade interna do objeto,
    // atualizamos o RxList.
    produtos.refresh();

    print(
      '[PRODUTO CANCELADO] '
      'SEQ: ${produtos[index].sequencia} | '
      '${produtos[index].descricao}',
    );
  }

  void _atualizarTotal(List<String> partes) {
    if (partes.length < 3) return;

    final total = double.tryParse(partes[2].trim());

    if (total == null) return;

    // Durante o cancelamento observamos:
    //
    // I|9|-1||
    //
    // Esse valor é intermediário e não deve aparecer
    // como total da venda.
    if (total < 0) {
      print(
        '[TOTAL VENDA] '
        'Valor intermediário ignorado: $total',
      );

      return;
    }

    totalVenda.value = total;

    print('[TOTAL VENDA] ${totalVenda.value}');
  }

  // E|2|2|
  void _processarStatus(List<String> partes) {
    if (partes.length < 2) return;

    final codigo = int.tryParse(partes[1].trim());

    if (codigo == null) return;

    final statusAnterior = statusPdv.value;

    statusPdv.value = codigo;

    print('[STATUS PDV] $statusAnterior -> $codigo');

    // Disponível: encerra o modo e limpa a venda.
    if (codigo == 2) {
      modoInformacao.value = false;
      sistemaInformacao.clear();
      _limparVenda();

      print('[INFO PDV] PDV disponível');
      return;
    }

    // Venda: encerra o modo de informações.
    if (codigo == 3) {
      modoInformacao.value = false;
      sistemaInformacao.clear();

      print('[INFO PDV] Venda iniciada');
    }

    // Status 4 (Recebimento):
    // não desativar modoInformacao aqui.
    // A finalizadora pode estar exibindo o menu TEF.
  }

  void _limparVenda() {
    produtos.clear();

    totalVenda.value = 0.0;

    valorDigitado.value = '';

    print('[VENDA] Dados da venda limpos');
  }

  // D|DISPLAY PRINCIPAL|DISPLAY SECUNDARIO|
  void _processarDisplay(List<String> partes) {
    displayPrincipal.value = partes.length > 1 ? partes[1].trim() : '';

    displaySecundario.value = partes.length > 2 ? partes[2].trim() : '';
  }

  // F|F|104|
  // F|I|104|
  void _processarFuncao(List<String> partes) {
    if (partes.length < 3) return;

    final tipo = partes[1].trim();
    final codigo = partes[2].trim();

    print('[FUNÇÃO] F|$tipo|$codigo');

    // F|I|129| confirma que o PDV entrou na função 129.
    if (tipo == 'I' && codigo == '129') {
      sistemaInformacao.clear();
      modoInformacao.value = true;
      print('[INFO PDV] FUNÇÃO 129 - iniciando informações');
    }

    // F|I|130| confirma que o PDV entrou na função 130.
    if (tipo == 'I' && codigo == '130') {
      sistemaInformacao.clear();
      modoInformacao.value = true;
      print('[INFO PDV] FUNÇÃO 130 - iniciando informações');
    }

    // F|I|130| confirma que o PDV entrou na função 130.
    if (tipo == 'I' && codigo == '131') {
      sistemaInformacao.clear();
      modoInformacao.value = true;
      print('[INFO PDV] FUNÇÃO 131 - iniciando informações');
    }
  }

  // S|...
  void _processarSistema(String raw) {
    sistemaRaw.value = raw;
  }

  // X| ...
  void _processarInformacao(String raw) {
    final partes = raw.split('|');

    if (partes.length < 3) return;

    final comando = partes[2].trim();

    print('[INFO PDV] Comando X recebido: $comando');

    // X|frmGeral|CLS||
    // Limpa a tela antes de desenhar as novas informações.
    if (comando == 'CLS') {
      sistemaInformacao.clear();
      return;
    }

    // X|frmGeral|CPRINT|texto|S|
    if (comando == 'CPRINT' || comando == 'PRINT') {
      if (partes.length < 4) return;

      final texto = partes[3].trim();

      if (texto.isEmpty) return;

      // Ignora somente a linha formada por traços.
      if (RegExp(r'^-+$').hasMatch(texto)) {
        return;
      }
      sistemaInformacao.add(texto);
      print('[INFO PDV] Texto recebido: $texto');
    }
  }

  // FECHAR MODAL - 198
  void fecharInformacoesPdv() {
    mostrarInformacoesPdv.value = false;
    print('[MODAL] 198 - FECHADO');
  }

  // Flutter → PDV
  void enviarFuncao(int codigo) {
    socketService.enviar('F|F|$codigo|');
  }

  // ENVIAR FUNCAO COM VALOR - F|F|60|95
  void enviarFuncaoComValor(int codigo, String valor) {
    socketService.enviar('F|F|$codigo|$valor');
  }

  // ENVIAR FUNCAO COM CODIGO DO PRODUTO - COD F|F|60|390
  // void enviarCodigoProduto(int codigo, int valor) {
  //   socketService.enviar('F|F|$codigo|$valor');
  // }

  // BOTÃO ENTRAR - F|F|60|95
  void entrar() {
    final valor = valorDigitado.value.trim();

    if (valor.isEmpty) {
      return;
    }

    print('[ENTER] Enviando valor: $valor');

    // Exemplo:
    // F|F|60|95
    enviarFuncaoComValor(60, valor);

    // Limpa o display do teclado para a próxima entrada.
    limparDigitacao();
  }

  // BOTÃO FUNÇÃO
  void funcao() {
    final valor = valorDigitado.value.trim();

    if (valor.isEmpty) {
      return;
    }

    // FUNÇÃO 198 = informações do PDV
    // if (valor == '198') {
    //   if (!mostrarInformacoesPdv.value) {
    //     sistemaInformacao.clear();
    //     mostrarInformacoesPdv.value = true;

    //     print('[INFO PDV] Iniciando coleta das informações 198');
    //   }
    // }

    if (valor == '198') {
      sistemaInformacao.clear();
      mostrarInformacoesPdv.value = true;

      print('[INFO PDV] Iniciando coleta das informações 198');
    }

    print('[FUNCAO] Enviando valor: $valor');

    // Exemplo:
    // F|F|60|95
    enviarFuncaoComValor(65, valor);

    // Limpa o display do teclado para a próxima entrada.
    limparDigitacao();
  }

  // FUNÇÃO 61 - BOTÃO VOLTAR
  void voltar() {
    enviarFuncao(61);

    // Sai do painel de informações imediatamente.
    modoInformacao.value = false;
    sistemaInformacao.clear();

    print('[INFO PDV] Voltando para a lista de produtos');
  }

  // FUNÇÃO 66 - LIMPAR
  void limpa() {
    final valor = valorDigitado.value.trim();

    if (valor.isEmpty) {
      return;
    }
    print('[FUNCAO] Enviando valor: $valor');

    // Exemplo:
    // F|F|60|95
    enviarFuncaoComValor(66, valor);

    // Limpa o display do teclado para a próxima entrada.
    limparDigitacao();
  }

  // FUNÇÃO 111 - CANCELA VENDA
  void cancelaVenda() {
    enviarFuncao(111);
  }

  // FUNÇÃO 108 - CANCELA ITEM
  void cancelaItem() {
    enviarFuncao(108);
  }

  // FUNÇÃO 129 - ADMINISTRATIVA TEF
  void admTef() {
    enviarFuncao(129);
  }

  // FUNÇÃO 130 - CANCELAMENTO DE TEF
  void cancelaTef() {
    enviarFuncao(130);
  }

  // FUNÇÃO 131 - REIMPRESSAO DE TEF
  void reimpressaoTef() {
    enviarFuncao(131);
  }

  // TOTALIZA VENDA
  void totalizaVenda() {
    enviarFuncao(105);
  }

  // MULTIPLICAÇÃO
  void multiplicacao() {
    final valor = valorDigitado.value.trim();

    if (valor.isEmpty) {
      return;
    }
    print('[FUNCAO] Enviando valor: $valor');

    // Exemplo:
    // F|F|60|95
    enviarFuncaoComValor(62, valor);

    // Limpa o display do teclado para a próxima entrada.
    limparDigitacao();
  }

  // FUNÇÃO 104 - INICIAR VENDA
  void iniciarVenda() {
    enviarFuncao(104);
  }

  // FUNÇÃO 103 - ENTRADA OPERADOR
  void entradaOperador() {
    enviarFuncao(103);
  }

  // FUNÇÃO 106 - SAIDA OPERADOR
  void saidaOperador() {
    enviarFuncao(106);
  }

  // FUNÇÃO 101 - ABERTURA
  void abertura() {
    enviarFuncao(101);
  }

  // FUNÇÃO 101 - ABERTURA
  void reducao() {
    enviarFuncao(112);
  }

  // FINALIZADORA
  void dinheiro() {
    final valor = valorDigitado.value.trim();

    // if (valor.isEmpty) {
    //   return;
    // }
    print('[FUNCAO] Enviando valor: $valor');

    // Exemplo:
    // F|F|60|95
    enviarFuncaoComValor(1, valor);

    // Limpa o display do teclado para a próxima entrada.
    limparDigitacao();
    enviarFuncao(1);
  }

  void credito() {
    sistemaInformacao.clear();
    modoInformacao.value = true;

    enviarFuncao(2);
  }

  void debito() {
    sistemaInformacao.clear();
    modoInformacao.value = true;

    enviarFuncao(3);
  }

  void pos() {
    final valor = valorDigitado.value.trim();

    if (valor.isEmpty) {
      return;
    }
    print('[FUNCAO] Enviando valor: $valor');

    // Exemplo:
    // F|F|60|95
    enviarFuncaoComValor(4, valor);

    // Limpa o display do teclado para a próxima entrada.
    limparDigitacao();
  }

  // CODIGO DE PRODUTO
  void pao() {
    enviarFuncaoComValor(60, '390');
  }

  void leiteMoca() {
    enviarFuncaoComValor(60, '7891000100103');
  }

  String get sistemaDisplay {
    if (sistemaRaw.value.isEmpty) return '';

    final partes = sistemaRaw.value.split('|');

    if (partes.length < 2) return '';

    return partes[1];
  }

  // @override
  // void onClose() {
  //   _socketSubscription?.cancel();

  //   super.onClose();
  // }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    _conexaoSubscription?.cancel();
    _timer?.cancel(); // Limpa o timer quando o controller for destruído
    super.onClose();
  }
}

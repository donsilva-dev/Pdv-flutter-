import 'dart:async';
import 'dart:convert';
import 'dart:io';

class PdvSocketService {
  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;

  final StreamController<String> _mensagensController =
      StreamController<String>.broadcast();

  final StreamController<bool> _conexaoController =
      StreamController<bool>.broadcast();

  Stream<String> get mensagens => _mensagensController.stream;

  Stream<bool> get estadoConexao => _conexaoController.stream;

  bool get conectado => _socket != null;

  String? _host;
  int _porta = 8082;

  Timer? _timerReconexao;

  bool _conectando = false;
  bool _desconexaoManual = false;
  bool _descartado = false;

  String _buffer = '';

  Future<void> conectar({required String host, int porta = 8082}) async {
    _host = host;
    _porta = porta;
    _desconexaoManual = false;

    _timerReconexao?.cancel();

    await _tentarConectar();
  }

  Future<void> _tentarConectar() async {
    if (_descartado || _desconexaoManual || _conectando || conectado) {
      return;
    }

    final host = _host;

    if (host == null || host.isEmpty) return;

    _conectando = true;

    try {
      print('======================================');
      print('CONECTANDO AO PDV');
      print('IP: $host');
      print('PORTA: $_porta');
      print('======================================');

      final novoSocket = await Socket.connect(
        host,
        _porta,
        timeout: const Duration(seconds: 5),
      );

      // A conexão pode ter sido cancelada enquanto aguardávamos.
      if (_descartado || _desconexaoManual) {
        novoSocket.destroy();
        return;
      }

      _socket = novoSocket;
      _buffer = '';

      print('PDV CONECTADO!');

      _conexaoController.add(true);

      _subscription = novoSocket.listen(
        _onData,
        onError: (Object erro) {
          print('ERRO SOCKET: $erro');
          _tratarDesconexao(novoSocket);
        },
        onDone: () {
          print('CONEXÃO COM PDV ENCERRADA');
          _tratarDesconexao(novoSocket);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('ERRO AO CONECTAR NO PDV: $e');

      // Informa ao controller que a conexão está indisponível.
      if (!_descartado && !_desconexaoManual) {
        _conexaoController.add(false);
      }
    } finally {
      _conectando = false;

      if (!conectado && !_descartado && !_desconexaoManual) {
        _agendarReconexao();
      }
    }
  }

  void _agendarReconexao() {
    if (_descartado ||
        _desconexaoManual ||
        conectado ||
        _timerReconexao?.isActive == true) {
      return;
    }

    print('Nova tentativa de conexão em 3 segundos...');

    _timerReconexao = Timer(const Duration(seconds: 3), () {
      _timerReconexao = null;
      _tentarConectar();
    });
  }

  void _tratarDesconexao(Socket socket) {
    // Ignora eventos de uma conexão antiga.
    if (!identical(_socket, socket)) return;

    _socket = null;
    _buffer = '';

    final subscription = _subscription;
    _subscription = null;
    subscription?.cancel();

    socket.destroy();

    if (!_descartado && !_desconexaoManual) {
      _conexaoController.add(false);
      _agendarReconexao();
    }
  }

  void _onData(List<int> data) {
    final recebido = utf8.decode(data, allowMalformed: true);

    print('<<< BYTES RECEBIDOS');
    print(recebido);

    _processarBuffer(recebido);
  }

  void _processarBuffer(String recebido) {
    _buffer += recebido;

    final linhas = _buffer.split('\n');

    // Preserva a última mensagem caso ainda esteja incompleta.
    _buffer = linhas.removeLast();

    for (final linha in linhas) {
      final mensagem = linha.replaceAll('\r', '').trim();

      if (mensagem.isEmpty) continue;

      _mensagensController.add(mensagem);
    }
  }

  void enviar(String mensagem) {
    final socket = _socket;

    if (socket == null) {
      print('Não foi possível enviar: PDV desconectado.');
      return;
    }

    try {
      print('>>> ENVIANDO');
      print(mensagem);

      socket.write('$mensagem\n');
    } catch (e) {
      print('ERRO AO ENVIAR MENSAGEM: $e');
      _tratarDesconexao(socket);
    }
  }

  Future<void> desconectar() async {
    print('DESCONECTANDO DO PDV...');

    _desconexaoManual = true;
    _timerReconexao?.cancel();
    _timerReconexao = null;

    final socket = _socket;
    _socket = null;

    final subscription = _subscription;
    _subscription = null;

    await subscription?.cancel();
    socket?.destroy();

    _buffer = '';
    _conexaoController.add(false);
  }

  Future<void> dispose() async {
    _descartado = true;

    await desconectar();

    await _mensagensController.close();
    await _conexaoController.close();
  }
}

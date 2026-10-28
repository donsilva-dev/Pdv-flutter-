class PdvProduct {
  final int sequencia;
  final String codigo;
  final String codigoBarras;
  final String descricao;

  double quantidade;
  bool cancelado;

  final String unidade;
  final double valorUnitario;
  double valorTotal;

  final double valorNormal;
  final bool emPromocao;

  PdvProduct({
    required this.sequencia,
    required this.codigo,
    required this.codigoBarras,
    required this.descricao,
    required this.quantidade,
    required this.unidade,
    required this.valorUnitario,
    required this.valorTotal,
    this.valorNormal = 0.0,
    this.emPromocao = false,
    this.cancelado = false,
  });
}

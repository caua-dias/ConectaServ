import 'enums.dart';

class Contratacao {
  final int idContratacao;
  final int idCliente;
  final int idServico;
  final StatusPagamento statusPagamento;

  const Contratacao({
    required this.idContratacao,
    required this.idCliente,
    required this.idServico,
    required this.statusPagamento,
  });

  factory Contratacao.fromJson(Map<String, dynamic> json) {
    return Contratacao(
      idContratacao: json['idContratacao'] as int,
      idCliente: json['idCliente'] as int,
      idServico: json['idServico'] as int,
      statusPagamento: StatusPagamento.values.byName(json['statusPagamento']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idContratacao': idContratacao,
      'idCliente': idCliente,
      'idServico': idServico,
      'statusPagamento': statusPagamento.name,
    };
  }

  Contratacao copyWith({
    int? idContratacao,
    int? idCliente,
    int? idServico,
    StatusPagamento? statusPagamento,
  }) {
    return Contratacao(
      idContratacao: idContratacao ?? this.idContratacao,
      idCliente: idCliente ?? this.idCliente,
      idServico: idServico ?? this.idServico,
      statusPagamento: statusPagamento ?? this.statusPagamento,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contratacao &&
        other.idContratacao == idContratacao &&
        other.idCliente == idCliente &&
        other.idServico == idServico &&
        other.statusPagamento == statusPagamento;
  }

  @override
  int get hashCode =>
      idContratacao.hashCode ^
      idCliente.hashCode ^
      idServico.hashCode ^
      statusPagamento.hashCode;
}

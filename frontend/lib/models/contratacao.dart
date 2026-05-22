import 'enums.dart';

class Contratacao {
  final int? idContratacao;
  final int idCliente;
  final int idServico;
  final StatusPagamento statusPagamento;

  const Contratacao({
    this.idContratacao,
    required this.idCliente,
    required this.idServico,
    required this.statusPagamento,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idContratacao != null) 'id_contratacao': idContratacao,
      'id_cliente': idCliente,
      'id_servico': idServico,
      'status_pagamento': statusPagamento.name,
    };
  }

  factory Contratacao.fromMap(Map<String, dynamic> map) {
    return Contratacao(
      idContratacao: map['id_contratacao'] as int?,
      idCliente: map['id_cliente'] as int,
      idServico: map['id_servico'] as int,
      statusPagamento: StatusPagamento.values.byName(map['status_pagamento']),
    );
  }

  factory Contratacao.fromJson(Map<String, dynamic> json) {
    return Contratacao(
      idContratacao: json['idContratacao'] as int?,
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

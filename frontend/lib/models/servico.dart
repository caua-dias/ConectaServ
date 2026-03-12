import 'enums.dart';

class Servico {
  final int idServico;
  final int idEmpresa;
  final String descricao;
  final double preco;
  final Categoria categoria;

  const Servico({
    required this.idServico,
    required this.idEmpresa,
    required this.descricao,
    required this.preco,
    required this.categoria,
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      idServico: json['idServico'] as int,
      idEmpresa: json['idEmpresa'] as int,
      descricao: json['descricao'] as String,
      preco: (json['preco'] as num).toDouble(),
      categoria: Categoria.values.byName(json['categoria']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idServico': idServico,
      'idEmpresa': idEmpresa,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria.name,
    };
  }

  Servico copyWith({
    int? idServico,
    int? idEmpresa,
    String? descricao,
    double? preco,
    Categoria? categoria,
  }) {
    return Servico(
      idServico: idServico ?? this.idServico,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Servico &&
        other.idServico == idServico &&
        other.idEmpresa == idEmpresa &&
        other.descricao == descricao &&
        other.preco == preco &&
        other.categoria == categoria;
  }

  @override
  int get hashCode =>
      idServico.hashCode ^
      idEmpresa.hashCode ^
      descricao.hashCode ^
      preco.hashCode ^
      categoria.hashCode;
}

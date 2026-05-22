import 'enums.dart';

class EmpresaPrestadora {
  final int? idEmpresa;
  final String cnpj;
  final StatusCuradoria statusCuradoria;
  final String reputacao;

  const EmpresaPrestadora({
    this.idEmpresa,
    required this.cnpj,
    required this.statusCuradoria,
    required this.reputacao,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idEmpresa != null) 'id_empresa': idEmpresa,
      'cnpj': cnpj,
      'status_curadoria': statusCuradoria.name,
      'reputacao': reputacao,
    };
  }

  factory EmpresaPrestadora.fromMap(Map<String, dynamic> map) {
    return EmpresaPrestadora(
      idEmpresa: map['id_empresa'] as int?,
      cnpj: map['cnpj'] as String,
      statusCuradoria: StatusCuradoria.values.byName(map['status_curadoria']),
      reputacao: map['reputacao'] as String,
    );
  }

  factory EmpresaPrestadora.fromJson(Map<String, dynamic> json) {
    return EmpresaPrestadora(
      idEmpresa: json['idEmpresa'] as int?,
      cnpj: json['cnpj'] as String,
      statusCuradoria: StatusCuradoria.values.byName(json['statusCuradoria']),
      reputacao: json['reputacao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEmpresa': idEmpresa,
      'cnpj': cnpj,
      'statusCuradoria': statusCuradoria.name,
      'reputacao': reputacao,
    };
  }

  EmpresaPrestadora copyWith({
    int? idEmpresa,
    String? cnpj,
    StatusCuradoria? statusCuradoria,
    String? reputacao,
  }) {
    return EmpresaPrestadora(
      idEmpresa: idEmpresa ?? this.idEmpresa,
      cnpj: cnpj ?? this.cnpj,
      statusCuradoria: statusCuradoria ?? this.statusCuradoria,
      reputacao: reputacao ?? this.reputacao,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmpresaPrestadora &&
        other.idEmpresa == idEmpresa &&
        other.cnpj == cnpj &&
        other.statusCuradoria == statusCuradoria &&
        other.reputacao == reputacao;
  }

  @override
  int get hashCode =>
      idEmpresa.hashCode ^
      cnpj.hashCode ^
      statusCuradoria.hashCode ^
      reputacao.hashCode;
}

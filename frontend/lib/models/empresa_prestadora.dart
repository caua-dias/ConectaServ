import 'enums.dart';

class EmpresaPrestadora {
  final int? idEmpresa;
  final String cnpj;
  final StatusCuradoria statusCuradoria;
  final String reputacao;
  final String? nomeFantasia;
  final String? descricao;
  final String? localizacao;
  final String? emoji;

  const EmpresaPrestadora({
    this.idEmpresa,
    required this.cnpj,
    required this.statusCuradoria,
    required this.reputacao,
    this.nomeFantasia,
    this.descricao,
    this.localizacao,
    this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idEmpresa != null) 'id_empresa': idEmpresa,
      'cnpj': cnpj,
      'status_curadoria': statusCuradoria.name,
      'reputacao': reputacao,
      'nome_fantasia': nomeFantasia,
      'descricao': descricao,
      'localizacao': localizacao,
      'emoji': emoji,
    };
  }

  factory EmpresaPrestadora.fromMap(Map<String, dynamic> map) {
    return EmpresaPrestadora(
      idEmpresa: map['id_empresa'] as int?,
      cnpj: map['cnpj'] as String,
      statusCuradoria: StatusCuradoria.values.byName(map['status_curadoria']),
      reputacao: map['reputacao'] as String,
      nomeFantasia: map['nome_fantasia'] as String?,
      descricao: map['descricao'] as String?,
      localizacao: map['localizacao'] as String?,
      emoji: map['emoji'] as String?,
    );
  }

  factory EmpresaPrestadora.fromJson(Map<String, dynamic> json) {
    return EmpresaPrestadora(
      idEmpresa: json['idEmpresa'] as int?,
      cnpj: json['cnpj'] as String,
      statusCuradoria: StatusCuradoria.values.byName(json['statusCuradoria']),
      reputacao: json['reputacao'] as String,
      nomeFantasia: json['nomeFantasia'] as String?,
      descricao: json['descricao'] as String?,
      localizacao: json['localizacao'] as String?,
      emoji: json['emoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEmpresa': idEmpresa,
      'cnpj': cnpj,
      'statusCuradoria': statusCuradoria.name,
      'reputacao': reputacao,
      if (nomeFantasia != null) 'nomeFantasia': nomeFantasia,
      if (descricao != null) 'descricao': descricao,
      if (localizacao != null) 'localizacao': localizacao,
      if (emoji != null) 'emoji': emoji,
    };
  }

  EmpresaPrestadora copyWith({
    int? idEmpresa,
    String? cnpj,
    StatusCuradoria? statusCuradoria,
    String? reputacao,
    String? nomeFantasia,
    String? descricao,
    String? localizacao,
    String? emoji,
  }) {
    return EmpresaPrestadora(
      idEmpresa: idEmpresa ?? this.idEmpresa,
      cnpj: cnpj ?? this.cnpj,
      statusCuradoria: statusCuradoria ?? this.statusCuradoria,
      reputacao: reputacao ?? this.reputacao,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      descricao: descricao ?? this.descricao,
      localizacao: localizacao ?? this.localizacao,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmpresaPrestadora &&
        other.idEmpresa == idEmpresa &&
        other.cnpj == cnpj &&
        other.statusCuradoria == statusCuradoria &&
        other.reputacao == reputacao &&
        other.nomeFantasia == nomeFantasia &&
        other.descricao == descricao &&
        other.localizacao == localizacao &&
        other.emoji == emoji;
  }

  @override
  int get hashCode =>
      idEmpresa.hashCode ^
      cnpj.hashCode ^
      statusCuradoria.hashCode ^
      reputacao.hashCode ^
      (nomeFantasia?.hashCode ?? 0) ^
      (descricao?.hashCode ?? 0) ^
      (localizacao?.hashCode ?? 0) ^
      (emoji?.hashCode ?? 0);
}
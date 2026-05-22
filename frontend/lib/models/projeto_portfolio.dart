class ProjetoPortfolio {
  final int? idProjeto;
  final int idEmpresa;
  final String arquivo;

  const ProjetoPortfolio({
    this.idProjeto,
    required this.idEmpresa,
    required this.arquivo,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idProjeto != null) 'id_projeto': idProjeto,
      'id_empresa': idEmpresa,
      'arquivo': arquivo,
    };
  }

  factory ProjetoPortfolio.fromMap(Map<String, dynamic> map) {
    return ProjetoPortfolio(
      idProjeto: map['id_projeto'] as int?,
      idEmpresa: map['id_empresa'] as int,
      arquivo: map['arquivo'] as String,
    );
  }

  factory ProjetoPortfolio.fromJson(Map<String, dynamic> json) {
    return ProjetoPortfolio(
      idProjeto: json['idProjeto'] as int?,
      idEmpresa: json['idEmpresa'] as int,
      arquivo: json['arquivo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idProjeto': idProjeto, 'idEmpresa': idEmpresa, 'arquivo': arquivo};
  }

  ProjetoPortfolio copyWith({int? idProjeto, int? idEmpresa, String? arquivo}) {
    return ProjetoPortfolio(
      idProjeto: idProjeto ?? this.idProjeto,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      arquivo: arquivo ?? this.arquivo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjetoPortfolio &&
        other.idProjeto == idProjeto &&
        other.idEmpresa == idEmpresa &&
        other.arquivo == arquivo;
  }

  @override
  int get hashCode =>
      idProjeto.hashCode ^ idEmpresa.hashCode ^ arquivo.hashCode;
}

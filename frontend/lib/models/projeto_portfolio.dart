class ProjetoPortfolio {
  final int idProjeto;
  final int idEmpresa;
  final String arquivo;

  const ProjetoPortfolio({
    required this.idProjeto,
    required this.idEmpresa,
    required this.arquivo,
  });

  factory ProjetoPortfolio.fromJson(Map<String, dynamic> json) {
    return ProjetoPortfolio(
      idProjeto: json['idProjeto'] as int,
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

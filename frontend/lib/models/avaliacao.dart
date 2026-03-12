class Avaliacao {
  final int idAvaliacao;
  final int idContratacao;
  final int estrelas;
  final String? comentarios;
  final String? foto;

  const Avaliacao({
    required this.idAvaliacao,
    required this.idContratacao,
    required this.estrelas,
    this.comentarios,
    this.foto,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      idAvaliacao: json['idAvaliacao'] as int,
      idContratacao: json['idContratacao'] as int,
      estrelas: json['estrelas'] as int,
      comentarios: json['comentarios'] as String?,
      foto: json['foto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAvaliacao': idAvaliacao,
      'idContratacao': idContratacao,
      'estrelas': estrelas,
      'comentarios': comentarios,
      'foto': foto,
    };
  }

  Avaliacao copyWith({
    int? idAvaliacao,
    int? idContratacao,
    int? estrelas,
    String? comentarios,
    String? foto,
  }) {
    return Avaliacao(
      idAvaliacao: idAvaliacao ?? this.idAvaliacao,
      idContratacao: idContratacao ?? this.idContratacao,
      estrelas: estrelas ?? this.estrelas,
      comentarios: comentarios ?? this.comentarios,
      foto: foto ?? this.foto,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Avaliacao &&
        other.idAvaliacao == idAvaliacao &&
        other.idContratacao == idContratacao &&
        other.estrelas == estrelas &&
        other.comentarios == comentarios &&
        other.foto == foto;
  }

  @override
  int get hashCode =>
      idAvaliacao.hashCode ^
      idContratacao.hashCode ^
      estrelas.hashCode ^
      (comentarios?.hashCode ?? 0) ^
      (foto?.hashCode ?? 0);
}

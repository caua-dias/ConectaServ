class Avaliacao {
  final int? idAvaliacao; // Mudou para opcional (?) para o SQLite poder gerar o ID automaticamente
  final int idContratacao;
  final int estrelas;
  final String? comentarios;
  final String? foto;

  const Avaliacao({
    this.idAvaliacao, // Agora opcional
    required this.idContratacao,
    required this.estrelas,
    this.comentarios,
    this.foto,
  });

  // ---> ADICIONADO PARA O SQLITE <---
  Map<String, dynamic> toMap() {
    return {
      // Se for nulo, não enviamos para o SQLite; ele cuidará do AUTOINCREMENT
      if (idAvaliacao != null) 'id_avaliacao': idAvaliacao,
      'id_contratacao': idContratacao,
      'estrelas': estrelas,
      'comentarios': comentarios,
      'foto': foto,
    };
  }

  // ---> ADICIONADO PARA O SQLITE <---
  factory Avaliacao.fromMap(Map<String, dynamic> map) {
    return Avaliacao(
      idAvaliacao: map['id_avaliacao'] as int?,
      idContratacao: map['id_contratacao'] as int,
      estrelas: map['estrelas'] as int,
      comentarios: map['comentarios'] as String?,
      foto: map['foto'] as String?,
    );
  }

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      idAvaliacao: json['idAvaliacao'] as int?,
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
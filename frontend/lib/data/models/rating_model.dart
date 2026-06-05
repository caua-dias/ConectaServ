/// Modelo de avaliação retornado pelo backend após o envio via [RatingService].
///
/// Utilizado por:
/// - [RatingService] → submitRating (rating_service.dart)
///
/// Campos de entrada (enviados ao backend):
/// - [serviceId] — ID do serviço avaliado
/// - [score]     — nota de 1 a 5 (validado com `assert` no service)
/// - [comment]   — comentário opcional
///
/// Campos de retorno (preenchidos pelo backend):
/// - [id]         — ID único da avaliação criada
/// - [userId]     — ID do usuário que avaliou
/// - [createdAt]  — data/hora de criação
class RatingModel {
  final String id;
  final String serviceId;
  final String userId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.score,
    required this.createdAt,
    this.comment,
  });

  // ---------------------------------------------------------------------------
  // Serialização
  // ---------------------------------------------------------------------------

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'score': score,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Utilitários
  // ---------------------------------------------------------------------------

  RatingModel copyWith({
    String? id,
    String? serviceId,
    String? userId,
    int? score,
    String? comment,
    DateTime? createdAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Valida se o score está no intervalo permitido (1–5).
  bool get isValid => score >= 1 && score <= 5;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatingModel &&
        other.id == id &&
        other.serviceId == serviceId &&
        other.userId == userId &&
        other.score == score &&
        other.comment == comment &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      serviceId.hashCode ^
      userId.hashCode ^
      score.hashCode ^
      (comment?.hashCode ?? 0) ^
      createdAt.hashCode;

  @override
  String toString() =>
      'RatingModel(id: $id, serviceId: $serviceId, score: $score)';
}
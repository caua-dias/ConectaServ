/// Modelo de serviço retornado pelo backend.
///
/// Utilizado por:
/// - [ServiceService] → getServices (listing_service.dart)
/// - [ServiceRepository] → getServices
///
/// O backend envolve a lista dentro de `response['data']`, portanto o model
/// precisa ser completamente serializável via [fromJson] / [toJson].
class ServiceModel {
  final String id;
  final String companyId;
  final String title;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;

  /// Avaliação média do serviço (0.0 – 5.0).
  final double? rating;

  /// Número total de avaliações recebidas.
  final int? reviewCount;

  const ServiceModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.rating,
    this.reviewCount,
  });

  // ---------------------------------------------------------------------------
  // Serialização
  // ---------------------------------------------------------------------------

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'reviewCount': reviewCount,
    };
  }

  // ---------------------------------------------------------------------------
  // Utilitários
  // ---------------------------------------------------------------------------

  ServiceModel copyWith({
    String? id,
    String? companyId,
    String? title,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    double? rating,
    int? reviewCount,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  /// Preço formatado para exibição (ex.: "R$ 150,00").
  String get formattedPrice =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel &&
        other.id == id &&
        other.companyId == companyId &&
        other.title == title &&
        other.description == description &&
        other.price == price &&
        other.category == category &&
        other.imageUrl == imageUrl &&
        other.rating == rating &&
        other.reviewCount == reviewCount;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      companyId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      price.hashCode ^
      category.hashCode ^
      (imageUrl?.hashCode ?? 0) ^
      (rating?.hashCode ?? 0) ^
      (reviewCount?.hashCode ?? 0);

  @override
  String toString() =>
      'ServiceModel(id: $id, title: $title, price: $price, category: $category)';
}
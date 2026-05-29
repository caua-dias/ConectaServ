import '../../core/http_client.dart';
import '../models/rating_model.dart';

class RatingService {
  final HttpClient _httpClient;

  const RatingService(this._httpClient);

  Future<RatingModel> submitRating({
    required String serviceId,
    required int score,
    String? comment,
  }) async {
    assert(score >= 1 && score <= 5, 'Score deve ser entre 1 e 5');

    final response = await _httpClient.post(
      '/api/raiting',
      {
        'serviceId': serviceId,
        'score': score,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );

    return RatingModel.fromJson(response);
  }
}
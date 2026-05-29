import 'dart:convert';
import '../../core/cache_service.dart';
import '../../core/http_client.dart';
import '../models/service_model.dart';

class ServiceService {
  final HttpClient _httpClient;
  final CacheService _cacheService;

  static const int _cacheTtlMinutes = 10;

  const ServiceService(this._httpClient, this._cacheService);


  Future<List<ServiceModel>> getServices({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _getFromCache();
      if (cached != null) return cached;
    }

    final response = await _httpClient.get('/api/services');
    final rawList = response['data'] as List<dynamic>? ?? [];

    final services = rawList
        .cast<Map<String, dynamic>>()
        .map(ServiceModel.fromJson)
        .toList();

    await _saveToCache(services);

    return services;
  }

  List<ServiceModel>? _getFromCache() {
    final raw = _cacheService.get<String>(CacheKeys.services);
    if (raw == null) return null;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .cast<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(List<ServiceModel> services) async {
    final encoded = jsonEncode(services.map((s) => s.toJson()).toList());
    await _cacheService.set(
      CacheKeys.services,
      encoded,
      ttlMinutes: _cacheTtlMinutes,
    );
  }

  
  Future<void> invalidateCache() async {
    await _cacheService.remove(CacheKeys.services);
  }
}
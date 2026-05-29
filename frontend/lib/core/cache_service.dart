import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const int _defaultTtlMinutes = 10;

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Salva dados no cache com um TTL (time-to-live) em minutos
  Future<void> set(
    String key,
    dynamic data, {
    int ttlMinutes = _defaultTtlMinutes,
  }) async {
    final entry = {
      'data': data,
      'expiresAt': DateTime.now()
          .add(Duration(minutes: ttlMinutes))
          .millisecondsSinceEpoch,
    };
    await _prefs.setString(key, jsonEncode(entry));
  }

  /// Retorna dados do cache se ainda válidos, ou null se expirado/ausente
  T? get<T>(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = entry['expiresAt'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        _prefs.remove(key); // limpa cache expirado
        return null;
      }

      return entry['data'] as T;
    } catch (_) {
      return null;
    }
  }

  /// Remove uma chave do cache
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Remove todas as chaves que começam com o prefixo
  Future<void> removeByPrefix(String prefix) async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  /// Limpa todo o cache
  Future<void> clear() async {
    await _prefs.clear();
  }
}

/// Chaves de cache centralizadas para evitar typos
class CacheKeys {
  CacheKeys._();

  static const String services = 'cache_services';
  static String serviceById(String id) => 'cache_service_$id';
}
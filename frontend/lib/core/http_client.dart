import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException($statusCode): $message';
}

class BadRequestException extends AppException {
  const BadRequestException(String message) : super(message, statusCode: 400);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(String message) : super(message, statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException(String message) : super(message, statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException(String message) : super(message, statusCode: 409);
}

class ServerException extends AppException {
  const ServerException(String message) : super(message, statusCode: 500);
}

class HttpClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  HttpClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw const AppException('Sem conexão com a internet');
    }
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw const AppException('Sem conexão com a internet');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = _decodeBody(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw BadRequestException(
            body['message'] ?? 'Requisição inválida');
      case 401:
        throw UnauthorizedException(
            body['message'] ?? 'Não autorizado');
      case 404:
        throw NotFoundException(
            body['message'] ?? 'Recurso não encontrado');
      case 409:
        throw ConflictException(
            body['message'] ?? 'Conflito de dados');
      case 500:
      default:
        throw ServerException(
            body['message'] ?? 'Erro interno do servidor');
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
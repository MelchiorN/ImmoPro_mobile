import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Exception personnalisée pour les erreurs API.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Client HTTP centralisé pour tous les appels au backend Laravel.
///
/// Usage :
/// ```dart
// final client = ApiClient.instance;
/// final body = await client.post('/client/login', {'email': ..., 'password': ...});
/// ```
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _baseUrl = 'http://localhost:8000/api';

  static const String _tokenKey = 'sanctum_token';

  final _storage = const FlutterSecureStorage();
  final _client = http.Client();

  // ── Token management ─────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  Future<Map<String, String>> _buildHeaders({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Platform': defaultTargetPlatform.name,
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] as String? ?? 'Erreur serveur',
      errors: body['errors'] as Map<String, dynamic>?,
    );
  }

  void _logRequest(String method, String url, Map<String, String> headers, [String? body]) {
    debugPrint('── API REQUEST [$method] ──────────────────────────');
    debugPrint('URL     : $url');
    debugPrint('Headers : $headers');
    if (body != null && body.isNotEmpty && body != '{}') {
      debugPrint('Body    : $body');
    }
    debugPrint('──────────────────────────────────────────────────');
  }

  void _logResponse(String method, String url, int statusCode, String responseBody) {
    debugPrint('── API RESPONSE [$method] ─────────────────────────');
    debugPrint('URL     : $url');
    debugPrint('Status  : $statusCode');
    debugPrint('Body    : $responseBody');
    debugPrint('──────────────────────────────────────────────────');
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Requête POST (sans authentification).
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final url = '$_baseUrl$path';
    final headers = await _buildHeaders();
    final encodedBody = json.encode(data);

    _logRequest('POST', url, headers, encodedBody);

    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: encodedBody,
    );

    _logResponse('POST', url, response.statusCode, response.body);

    return _parseResponse(response);
  }

  /// Requête GET publique (sans authentification).
  Future<Map<String, dynamic>> getPublic(String path) async {
    final url = '$_baseUrl$path';
    final headers = {
      'Accept': 'application/json',
      'X-Platform': defaultTargetPlatform.name,
    };

    _logRequest('GET', url, headers);

    final response = await _client.get(
      Uri.parse(url),
      headers: headers,
    );

    _logResponse('GET', url, response.statusCode, response.body);

    return _parseResponse(response);
  }

  /// Requête GET (avec authentification Sanctum).
  Future<Map<String, dynamic>> getAuth(String path) async {
    final url = '$_baseUrl$path';
    final headers = await _buildHeaders(auth: true);

    _logRequest('GET AUTH', url, headers);

    final response = await _client.get(
      Uri.parse(url),
      headers: headers,
    );

    _logResponse('GET AUTH', url, response.statusCode, response.body);

    return _parseResponse(response);
  }

  /// Requête POST (avec authentification Sanctum).
  Future<Map<String, dynamic>> postAuth(
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    final url = '$_baseUrl$path';
    final headers = await _buildHeaders(auth: true);
    final encodedBody = json.encode(data ?? {});

    _logRequest('POST AUTH', url, headers, encodedBody);

    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: encodedBody,
    );

    _logResponse('POST AUTH', url, response.statusCode, response.body);

    return _parseResponse(response);
  }

  /// Requête PUT (avec authentification Sanctum).
  Future<Map<String, dynamic>> putAuth(
    String path,
    Map<String, dynamic> data,
  ) async {
    final url = '$_baseUrl$path';
    final headers = await _buildHeaders(auth: true);
    final encodedBody = json.encode(data);

    _logRequest('PUT AUTH', url, headers, encodedBody);

    final response = await _client.put(
      Uri.parse(url),
      headers: headers,
      body: encodedBody,
    );

    _logResponse('PUT AUTH', url, response.statusCode, response.body);

    return _parseResponse(response);
  }

  /// Requête PATCH (avec authentification Sanctum).
  Future<Map<String, dynamic>> patchAuth(
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    final url = '$_baseUrl$path';
    final headers = await _buildHeaders(auth: true);
    final encodedBody = json.encode(data ?? {});

    _logRequest('PATCH AUTH', url, headers, encodedBody);

    final response = await _client.patch(
      Uri.parse(url),
      headers: headers,
      body: encodedBody,
    );

    _logResponse('PATCH AUTH', url, response.statusCode, response.body);

    return _parseResponse(response);
  }

  /// Requête DELETE (avec authentification Sanctum).
  Future<Map<String, dynamic>> deleteAuth(String path) async {
    final url = '$_baseUrl$path';
    final headers = await _buildHeaders(auth: true);

    _logRequest('DELETE AUTH', url, headers);

    final response = await _client.delete(
      Uri.parse(url),
      headers: headers,
    );

    _logResponse('DELETE AUTH', url, response.statusCode, response.body);

    return _parseResponse(response);
  }

  /// Requête multipart POST — pour upload de fichiers (biens, médias, docs).
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<MultipartFileEntry> files,
  }) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));

    request.headers['Accept'] = 'application/json';
    request.headers['X-Platform'] = defaultTargetPlatform.name;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Champs texte
    request.fields.addAll(fields);

    // Fichiers
    for (final entry in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          entry.fieldName,
          entry.filePath,
          filename: entry.fileName,
        ),
      );
    }

    debugPrint('── API MULTIPART POST ────────────────');
    debugPrint('URL    : $_baseUrl$path');
    debugPrint('Fields : $fields');
    debugPrint('Files  : ${files.map((f) => f.fieldName).toList()}');

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint('Status : ${response.statusCode}');
    debugPrint('Body   : ${response.body}');
    debugPrint('──────────────────────────────────────');

    return _parseResponse(response);
  }

  /// Requête multipart POST avec bytes — plus fiable pour photo de profil
  /// car évite les problèmes de chemin content:// sur Android.
  Future<Map<String, dynamic>> postMultipartBytes(
    String path, {
    required Map<String, String> fields,
    required List<MultipartBytesEntry> files,
  }) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));

    request.headers['Accept'] = 'application/json';
    request.headers['X-Platform'] = defaultTargetPlatform.name;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);

    for (final entry in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          entry.fieldName,
          entry.bytes,
          filename: entry.fileName,
        ),
      );
    }

    debugPrint('── API MULTIPART BYTES POST ──────────');
    debugPrint('URL    : $_baseUrl$path');
    debugPrint('Files  : ${files.map((f) => f.fieldName).toList()}');

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint('Status : ${response.statusCode}');
    debugPrint('Body   : ${response.body}');
    debugPrint('──────────────────────────────────────');

    return _parseResponse(response);
  }
}

/// Entrée de fichier pour les requêtes multipart (path).
class MultipartFileEntry {
  final String fieldName;
  final String filePath;
  final String? fileName;

  const MultipartFileEntry({
    required this.fieldName,
    required this.filePath,
    this.fileName,
  });
}

/// Entrée de fichier pour les requêtes multipart (bytes).
class MultipartBytesEntry {
  final String fieldName;
  final List<int> bytes;
  final String fileName;

  const MultipartBytesEntry({
    required this.fieldName,
    required this.bytes,
    required this.fileName,
  });
}
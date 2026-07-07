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
/// final client = ApiClient.instance;
/// final body = await client.post('/client/login', {'email': ..., 'password': ...});
/// ```
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // ── Configuration ────────────────────────────────────────────────────────
  // Choix selon le contexte de développement :
  //
  // 1. Émulateur AVD (sans câble)
  //    → defaultValue: 'http://10.0.2.2:8000/api'
  //
  // 2. Vrai appareil via USB + ADB reverse
  //    → Lancer : adb reverse tcp:8000 tcp:8000
  //    → defaultValue: 'http://localhost:8000/api'
  //
  // 3. Vrai appareil via ngrok
  //   → defaultValue: 'https://devout-terese-unaneled.ngrok-free.dev -> http://localhost:8000 '
  //
  // 4. Vrai appareil via WiFi (même réseau)
  //    → flutter run --dart-define=API_URL=http://192.168.X.X:8000/api
  //
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    // defaultValue: 'http://192.168.2.100:8000/api',
    // defaultValue: 'https://devout-terese-unaneled.ngrok-free.dev'
    defaultValue: 'http://localhost:8000/api'
    // defaultValue: 'http://10.0.2.2:8000/api'
  );

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

  // ── Public API ────────────────────────────────────────────────────────────

  /// Requête POST (sans authentification).
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    final url = '$_baseUrl$path';
    final headers = await _buildHeaders();
    final encodedBody = json.encode(data);

    debugPrint('── API POST ──────────────────────────');
    debugPrint('URL     : $url');
    debugPrint('Headers : $headers');
    debugPrint('Body    : $encodedBody');

    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: encodedBody,
    );

    debugPrint('Status  : ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('──────────────────────────────────────');

    return _parseResponse(response);
  }

  /// Requête GET (avec authentification Sanctum).
  Future<Map<String, dynamic>> getAuth(String path) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _buildHeaders(auth: true),
    );
    return _parseResponse(response);
  }

  /// Requête POST (avec authentification Sanctum).
  Future<Map<String, dynamic>> postAuth(
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _buildHeaders(auth: true),
      body: json.encode(data ?? {}),
    );
    return _parseResponse(response);
  }

  /// Requête PUT (avec authentification Sanctum).
  Future<Map<String, dynamic>> putAuth(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _buildHeaders(auth: true),
      body: json.encode(data),
    );
    return _parseResponse(response);
  }

  /// Requête DELETE (avec authentification Sanctum).
  Future<Map<String, dynamic>> deleteAuth(String path) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _buildHeaders(auth: true),
    );
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
}

/// Entrée de fichier pour les requêtes multipart.
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

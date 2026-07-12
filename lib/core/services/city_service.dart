import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service pour récupérer la liste des villes d'un pays via countriesnow.space.
class CityService {
  CityService._();
  static final CityService instance = CityService._();

  final Map<String, List<String>> _cache = {};

  /// Retourne la liste des villes pour un pays donné.
  /// Utilise le cache mémoire pour éviter les appels répétés.
  Future<List<String>> fetchCities(String countryName) async {
    if (countryName.isEmpty) return [];
    if (_cache.containsKey(countryName)) return _cache[countryName]!;

    try {
      final response = await http
          .post(
            Uri.parse('https://countriesnow.space/api/v0.1/countries/cities'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'country': countryName}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('CityService: HTTP ${response.statusCode} for $countryName');
        return [];
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['error'] == true) {
        debugPrint('CityService: API error for $countryName: ${data['msg']}');
        return [];
      }

      final cities = (data['data'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      cities.sort();
      _cache[countryName] = cities;
      return cities;
    } catch (e) {
      debugPrint('CityService: Error fetching cities for $countryName: $e');
      return [];
    }
  }

  /// Filtre les villes par préfixe [query].
  Future<List<String>> search(String countryName, String query) async {
    final all = await fetchCities(countryName);
    if (query.isEmpty) return all.take(8).toList();
    final q = query.toLowerCase().trim();
    return all
        .where((c) => c.toLowerCase().startsWith(q))
        .take(10)
        .toList();
  }

  /// Vide le cache (utile pour les tests).
  void clearCache() => _cache.clear();
}

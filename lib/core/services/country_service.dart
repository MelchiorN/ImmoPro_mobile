import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Modèle représentant un pays avec ses métadonnées utiles.
class CountryModel {
  final String name;
  final String flagEmoji;
  final String dialCode;
  final String cca2;

  const CountryModel({
    required this.name,
    required this.flagEmoji,
    required this.dialCode,
    required this.cca2,
  });

  @override
  String toString() => '$flagEmoji $name ($dialCode)';
}

/// Service pour récupérer la liste des pays via restcountries.com.
/// Maintient un cache mémoire pour éviter les appels répétés.
class CountryService {
  CountryService._();
  static final CountryService instance = CountryService._();

  List<CountryModel>? _cache;



  /// Retourne la liste complète des pays, triée alphabétiquement.
  /// Utilise le cache mémoire si disponible.
  Future<List<CountryModel>> fetchCountries() async {
    if (_cache != null) return _cache!;

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://restcountries.com/v3.1/all?fields=name,flags,idd,cca2',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('CountryService: HTTP ${response.statusCode}');
        _cache = [];
        return [];
      }

      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      final countries = <CountryModel>[];

      for (final item in data) {
        try {
          final name     = (item['name']?['common'] as String?) ?? '';
          final flag     = (item['flags']?['emoji'] as String?) ?? '🌍';
          final cca2     = (item['cca2'] as String?) ?? '';
          final root     = (item['idd']?['root'] as String?) ?? '';
          final suffixes = item['idd']?['suffixes'] as List<dynamic>?;
          String dial    = root;

          if (suffixes != null && suffixes.length == 1) {
            dial = '$root${suffixes[0]}';
          } else if (root.isNotEmpty && (suffixes == null || suffixes.isEmpty)) {
            dial = root;
          }

          if (name.isEmpty || dial.isEmpty) continue;

          countries.add(CountryModel(
            name:      name,
            flagEmoji: flag,
            dialCode:  dial,
            cca2:      cca2,
          ));
        } catch (_) {
          continue;
        }
      }

      countries.sort((a, b) => a.name.compareTo(b.name));
      _cache = countries;
      return countries;
    } catch (e) {
      debugPrint('CountryService: Error fetching countries: $e');
      _cache = [];
      return [];
    }
  }

  /// Cherche les pays dont le nom commence par [query] (insensible à la casse).
  Future<List<CountryModel>> search(String query) async {
    final all = await fetchCountries();
    if (query.isEmpty) return all.take(8).toList();
    final q = query.toLowerCase().trim();
    return all.where((c) => c.name.toLowerCase().startsWith(q)).take(10).toList();
  }

  /// Vérifie si un nom correspond exactement à un pays connu.
  Future<bool> exists(String name) async {
    final all = await fetchCountries();
    final n = name.toLowerCase().trim();
    return all.any((c) => c.name.toLowerCase() == n);
  }

  /// Retourne le CountryModel correspondant à un nom (null si introuvable).
  Future<CountryModel?> findByName(String name) async {
    final all = await fetchCountries();
    final n = name.toLowerCase().trim();
    try {
      return all.firstWhere((c) => c.name.toLowerCase() == n);
    } catch (_) {
      return null;
    }
  }

  /// Vide le cache (utile pour les tests).
  void clearCache() => _cache = null;
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service pour récupérer la liste des villes d'un pays via countriesnow.space.
class CityService {
  CityService._();
  static final CityService instance = CityService._();

  final Map<String, List<String>> _cache = {};

  static const Map<String, List<String>> _fallbackCities = {
    'Togo': [
      'Lomé',
      'Sokodé',
      'Kara',
      'Atakpamé',
      'Dapaong',
      'Tsévié',
      'Kpalimé',
      'Aného',
      'Tabligbo',
      'Bassar',
    ],
    'Bénin': [
      'Cotonou',
      'Porto-Novo',
      'Parakou',
      'Bohicon',
      'Abomey',
      'Lokossa',
      'Natitingou',
      'Ouidah',
      'Djougou',
      'Aplahoué',
    ],
    'Côte d\'Ivoire': [
      'Abidjan',
      'Yamoussoukro',
      'Bouaké',
      'Divo',
      'San Pedro',
      'Korhogo',
      'Man',
      'Gagnoa',
      'Dabou',
      'Grand-Bassam',
    ],
    'Sénégal': [
      'Dakar',
      'Thiès',
      'Saint-Louis',
      'Ziguinchor',
      'Kaolack',
      'Tambacounda',
      'Mbour',
      'Touba',
      'Kédougou',
      'Diourbel',
    ],
    'Burkina Faso': [
      'Ouagadougou',
      'Bobo-Dioulasso',
      'Koudougou',
      'Banfora',
      'Dédougou',
      'Ouahigouya',
      'Tenkodogo',
      'Fada N\'Gourma',
      'Kaya',
      'Gaoua',
    ],
    'Mali': [
      'Bamako',
      'Ségou',
      'Mopti',
      'Tombouctou',
      'Kayes',
      'Koutiala',
      'Gao',
      'Kati',
      'Kolokani',
      'Bougouni',
    ],
    'Niger': [
      'Niamey',
      'Zinder',
      'Maradi',
      'Agadez',
      'Tahoua',
      'Diffa',
      'Dosso',
      'Birni-Nkonni',
      'Tillabéri',
      'Ayorou',
    ],
    'Cameroun': [
      'Yaoundé',
      'Douala',
      'Bafoussam',
      'Bamenda',
      'Ngaoundéré',
      'Garoua',
      'Maroua',
      'Ebolowa',
      'Kumba',
      'Bertoua',
    ],
    'France': [
      'Paris',
      'Lyon',
      'Marseille',
      'Toulouse',
      'Nice',
      'Nantes',
      'Strasbourg',
      'Montpellier',
      'Bordeaux',
      'Lille',
    ],
    'Gabon': [
      'Libreville',
      'Port-Gentil',
      'Franceville',
      'Oyem',
      'Lambaréné',
      'Moanda',
      'Tchibanga',
      'Mouila',
      'Koulamoutou',
      'Nkan',
    ],
    'Guinée': [
      'Conakry',
      'Kankan',
      'Nzérékoré',
      'Kindia',
      'Labé',
      'Boké',
      'Macenta',
      'Siguiri',
      'Mamou',
      'Faranah',
    ],
    'Congo-Brazzaville': [
      'Brazzaville',
      'Pointe-Noire',
      'Dolisie',
      'Nkayi',
      'Impfondo',
      'Ouesso',
      'Madingou',
      'Gamboma',
      'Sibiti',
      'Oyo',
    ],
    'Congo-Kinshasa (RDC)': [
      'Kinshasa',
      'Lubumbashi',
      'Goma',
      'Kisangani',
      'Bukavu',
      'Mbuji-Mayi',
      'Kolwezi',
      'Matadi',
      'Kananga',
      'Likasi',
    ],
  };

  /// Retourne la liste des villes pour un pays donné.
  /// Utilise le cache mémoire pour éviter les appels répétés.
  Future<List<String>> fetchCities(String countryName) async {
    final normalizedCountry = countryName.trim();
    if (normalizedCountry.isEmpty) return [];
    if (_cache.containsKey(normalizedCountry)) {
      return _cache[normalizedCountry]!;
    }

    try {
      final response = await http
          .post(
            Uri.parse('https://countriesnow.space/api/v0.1/countries/cities'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'country': normalizedCountry}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint(
          'CityService: HTTP ${response.statusCode} for $normalizedCountry',
        );
        return _fallbackCitiesFor(normalizedCountry);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['error'] == true) {
        debugPrint(
          'CityService: API error for $normalizedCountry: ${data['msg']}',
        );
        return _fallbackCitiesFor(normalizedCountry);
      }

      final cities =
          (data['data'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [];

      if (cities.isEmpty) {
        return _fallbackCitiesFor(normalizedCountry);
      }

      cities.sort();
      _cache[normalizedCountry] = cities;
      return cities;
    } catch (e) {
      debugPrint(
        'CityService: Error fetching cities for $normalizedCountry: $e',
      );
      return _fallbackCitiesFor(normalizedCountry);
    }
  }

  /// Filtre les villes par préfixe [query].
  Future<List<String>> search(String countryName, String query) async {
    final all = await fetchCities(countryName);
    if (query.isEmpty) return all.take(8).toList();
    final q = query.toLowerCase().trim();
    return all.where((c) => c.toLowerCase().startsWith(q)).take(10).toList();
  }

  /// Synchronous search over the cache. Returns empty list if the
  /// country's cities are not yet cached.
  List<String> searchSync(String countryName, String query) {
    final all = _cache[countryName];
    if (all == null) {
      final fallback = _fallbackCitiesFor(countryName);
      if (fallback.isEmpty) return const [];
      return query.isEmpty
          ? fallback.take(8).toList()
          : fallback
                .where(
                  (c) => c.toLowerCase().startsWith(query.toLowerCase().trim()),
                )
                .take(10)
                .toList();
    }
    if (query.isEmpty) return all.take(8).toList();
    final q = query.toLowerCase().trim();
    return all.where((c) => c.toLowerCase().startsWith(q)).take(10).toList();
  }

  /// Returns true if cities for [countryName] are present in the cache.
  bool hasCachedCities(String countryName) => _cache.containsKey(countryName);

  /// Vide le cache (utile pour les tests).
  void clearCache() => _cache.clear();

  List<String> _fallbackCitiesFor(String countryName) {
    final normalized = countryName.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final match = _fallbackCities.entries.where((entry) {
      return entry.key.toLowerCase() == normalized;
    }).firstOrNull;

    if (match == null) return const [];

    final cities = List<String>.from(match.value);
    cities.sort();
    _cache[countryName.trim()] = cities;
    return cities;
  }
}

extension on Iterable<dynamic> {
  dynamic get firstOrNull => isEmpty ? null : first;
}

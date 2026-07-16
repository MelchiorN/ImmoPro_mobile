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

  /// Expose the in-memory cache synchronously for widgets that need
  /// immediate (sync) access to already-fetched countries.
  List<CountryModel>? get cache => _cache;

  static const List<CountryModel> _fallbackCountries = [
    CountryModel(name: 'Togo', flagEmoji: '🇹🇬', dialCode: '+228', cca2: 'TG'),
    CountryModel(name: 'Bénin', flagEmoji: '🇧🇯', dialCode: '+229', cca2: 'BJ'),
    CountryModel(name: 'Côte d\'Ivoire', flagEmoji: '🇨🇮', dialCode: '+225', cca2: 'CI'),
    CountryModel(name: 'Sénégal', flagEmoji: '🇸🇳', dialCode: '+221', cca2: 'SN'),
    CountryModel(name: 'Burkina Faso', flagEmoji: '🇧🇫', dialCode: '+226', cca2: 'BF'),
    CountryModel(name: 'Mali', flagEmoji: '🇲🇱', dialCode: '+223', cca2: 'ML'),
    CountryModel(name: 'Niger', flagEmoji: '🇳🇪', dialCode: '+227', cca2: 'NE'),
    CountryModel(name: 'Cameroun', flagEmoji: '🇨🇲', dialCode: '+237', cca2: 'CM'),
    CountryModel(name: 'France', flagEmoji: '🇫🇷', dialCode: '+33', cca2: 'FR'),
    CountryModel(name: 'Gabon', flagEmoji: '🇬🇦', dialCode: '+241', cca2: 'GA'),
    CountryModel(name: 'Guinée', flagEmoji: '🇬🇳', dialCode: '+224', cca2: 'GN'),
    CountryModel(name: 'Congo-Brazzaville', flagEmoji: '🇨🇬', dialCode: '+242', cca2: 'CG'),
    CountryModel(name: 'Congo-Kinshasa (RDC)', flagEmoji: '🇨🇩', dialCode: '+243', cca2: 'CD'),
    CountryModel(name: 'Canada', flagEmoji: '🇨🇦', dialCode: '+1', cca2: 'CA'),
    CountryModel(name: 'États-Unis', flagEmoji: '🇺🇸', dialCode: '+1', cca2: 'US'),
    CountryModel(name: 'Belgique', flagEmoji: '🇧🇪', dialCode: '+32', cca2: 'BE'),
    CountryModel(name: 'Suisse', flagEmoji: '🇨🇭', dialCode: '+41', cca2: 'CH'),
    CountryModel(name: 'Allemagne', flagEmoji: '🇩🇪', dialCode: '+49', cca2: 'DE'),
    CountryModel(name: 'Royaume-Uni', flagEmoji: '🇬🇧', dialCode: '+44', cca2: 'GB'),
    CountryModel(name: 'Italie', flagEmoji: '🇮🇹', dialCode: '+39', cca2: 'IT'),
    CountryModel(name: 'Espagne', flagEmoji: '🇪🇸', dialCode: '+34', cca2: 'ES'),
    CountryModel(name: 'Maroc', flagEmoji: '🇲🇦', dialCode: '+212', cca2: 'MA'),
    CountryModel(name: 'Algérie', flagEmoji: '🇩🇿', dialCode: '+213', cca2: 'DZ'),
    CountryModel(name: 'Tunisie', flagEmoji: '🇹🇳', dialCode: '+216', cca2: 'TN'),
    CountryModel(name: 'Ghana', flagEmoji: '🇬🇭', dialCode: '+233', cca2: 'GH'),
    CountryModel(name: 'Nigeria', flagEmoji: '🇳🇬', dialCode: '+234', cca2: 'NG'),
    CountryModel(name: 'Madagascar', flagEmoji: '🇲🇬', dialCode: '+261', cca2: 'MG'),
    CountryModel(name: 'Mauritanie', flagEmoji: '🇲🇷', dialCode: '+222', cca2: 'MR'),
  ];

  /// Retourne la liste complète des pays, triée alphabétiquement.
  /// Utilise le cache mémoire si disponible.
  /// En cas de panne de l'API ou d'absence de connexion, bascule vers une liste statique de secours.
  Future<List<CountryModel>> fetchCountries() async {
    if (_cache != null) return _cache!;

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://countriesnow.space/api/v0.1/countries/codes',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('CountryService: HTTP ${response.statusCode}, falling back to static list');
        _cache = List<CountryModel>.from(_fallbackCountries);
        return _cache!;
      }

      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      if (data['error'] == true) {
        debugPrint('CountryService: API error: ${data['msg']}, falling back to static list');
        _cache = List<CountryModel>.from(_fallbackCountries);
        return _cache!;
      }

      final List<dynamic>? list = data['data'] as List<dynamic>?;
      final countries = <CountryModel>[];

      if (list != null) {
        for (final item in list) {
          try {
            final name = (item['name'] as String?) ?? '';
            final code = (item['code'] as String?) ?? '';
            final dial = (item['dial_code'] as String?) ?? '';

            if (name.isEmpty || code.isEmpty || dial.isEmpty) continue;

            // Generate flag emoji offline using regional indicators
            final flag = _countryCodeToEmoji(code);

            countries.add(
              CountryModel(
                name: name,
                flagEmoji: flag,
                dialCode: dial,
                cca2: code,
              ),
            );
          } catch (_) {
            continue;
          }
        }
      }

      countries.sort((a, b) => a.name.compareTo(b.name));
      _cache = countries;
      return countries;
    } catch (e) {
      debugPrint('CountryService: Error fetching countries: $e, falling back to static list');
      _cache = List<CountryModel>.from(_fallbackCountries);
      return _cache!;
    }
  }

  String _countryCodeToEmoji(String countryCode) {
    if (countryCode.length != 2) return '🌍';
    final int firstChar = countryCode.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
    final int secondChar = countryCode.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  /// Cherche les pays dont le nom commence par [query] (insensible à la casse).
  Future<List<CountryModel>> search(String query) async {
    final all = await fetchCountries();
    if (query.isEmpty) return all.take(8).toList();
    final q = query.toLowerCase().trim();
    return all
        .where((c) => c.name.toLowerCase().startsWith(q))
        .take(10)
        .toList();
  }

  /// Synchronous search over the cache. Returns an empty list if cache
  /// is not yet populated. This is useful for UI callbacks that must
  /// return iterables synchronously (eg. RawAutocomplete.optionsBuilder).
  List<CountryModel> searchSync(String query) {
    final all = _cache;
    if (all == null) return const [];
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return all.take(8).toList();
    return all
        .where((c) => c.name.toLowerCase().startsWith(q))
        .take(10)
        .toList();
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

import 'package:flutter_test/flutter_test.dart';
import 'package:immopro_mobile/core/services/city_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'returns fallback cities for a selected country when the API is unavailable',
    () async {
      CityService.instance.clearCache();

      final cities = await CityService.instance.fetchCities('Togo');

      expect(cities, isNotEmpty);
      expect(cities, contains('Lomé'));
    },
  );
}

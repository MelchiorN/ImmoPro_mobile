import '../../features/home/domain/entities/property_entity.dart';

/// Formate un prix en FCFA avec séparateur de milliers (espace fine \u202F).
/// Ex : 850000 → "850 000 FCFA"
///      450000 (location) → "450 000 FCFA/mois"
String formatPriceFcfa(double price, PropertyType type) {
  final digits = price.toInt().toString().split('');
  final buf = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    // Espace fine (U+202F) tous les 3 chiffres depuis la droite
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('\u202F');
    buf.write(digits[i]);
  }
  final formatted = '${buf.toString()} FCFA';
  return switch (type) {
    PropertyType.rent => '$formatted/mois',
    PropertyType.colocation => '$formatted/mois',
    PropertyType.sale => formatted,
  };
}

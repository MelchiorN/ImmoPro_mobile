/// Entité représentant le schéma de formulaire d'une catégorie.
/// Chargée depuis GET /api/categories/{slug}/schema
class CategorySchemaEntity {
  final String slug;
  final String nom;
  final String? description;
  final List<AttributDefinitionEntity> attributs;

  const CategorySchemaEntity({
    required this.slug,
    required this.nom,
    this.description,
    required this.attributs,
  });
}

/// Définition d'un champ dynamique d'une catégorie.
class AttributDefinitionEntity {
  final String nomChamp;
  final String labelAffiche;
  final String typeChamp; // 'texte' | 'nombre' | 'booleen' | 'enum' | 'date'
  final List<String> optionsEnum;
  final bool obligatoire;
  final bool estSocle;
  final int ordreAffichage;

  const AttributDefinitionEntity({
    required this.nomChamp,
    required this.labelAffiche,
    required this.typeChamp,
    required this.optionsEnum,
    required this.obligatoire,
    required this.estSocle,
    required this.ordreAffichage,
  });

  /// Règles de validation pour ce champ selon son type.
  String? validate(dynamic value) {
    // Valeur absente
    if (value == null || (value is String && value.trim().isEmpty)) {
      return obligatoire ? '$labelAffiche est obligatoire' : null;
    }

    switch (typeChamp) {
      case 'nombre':
        final n = num.tryParse(value.toString().replaceAll(' ', ''));
        if (n == null) return '$labelAffiche doit être un nombre';
        if (n < 0) return '$labelAffiche doit être positif';
        return null;
      case 'booleen':
        if (value is! bool) return '$labelAffiche doit être vrai ou faux';
        return null;
      case 'enum':
        if (!optionsEnum.contains(value.toString())) {
          return 'Valeur invalide pour $labelAffiche';
        }
        return null;
      case 'date':
        final d = DateTime.tryParse(value.toString());
        if (d == null) return '$labelAffiche doit être une date valide';
        return null;
      case 'texte':
      default:
        if (value.toString().length > 500) {
          return '$labelAffiche ne doit pas dépasser 500 caractères';
        }
        return null;
    }
  }
}

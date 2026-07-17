import '../../domain/entities/category_schema_entity.dart';

class AttributDefinitionModel extends AttributDefinitionEntity {
  const AttributDefinitionModel({
    required super.nomChamp,
    required super.labelAffiche,
    required super.typeChamp,
    required super.optionsEnum,
    required super.obligatoire,
    required super.estSocle,
    required super.ordreAffichage,
  });

  factory AttributDefinitionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options_enum'] as List<dynamic>? ?? [];
    return AttributDefinitionModel(
      nomChamp:        json['nom_champ']       as String? ?? '',
      labelAffiche:    json['label_affiche']   as String? ?? '',
      typeChamp:       json['type_champ']      as String? ?? 'texte',
      optionsEnum:     rawOptions.map((e) => e.toString()).toList(),
      obligatoire:     json['obligatoire']     as bool? ?? false,
      estSocle:        json['est_socle']       as bool? ?? false,
      ordreAffichage:  json['ordre_affichage'] as int?  ?? 0,
    );
  }
}

class CategorySchemaModel extends CategorySchemaEntity {
  const CategorySchemaModel({
    required super.slug,
    required super.nom,
    super.description,
    required super.attributs,
  });

  factory CategorySchemaModel.fromJson(Map<String, dynamic> json) {
    final rawAttributs = json['attributs'] as List<dynamic>? ?? [];
    return CategorySchemaModel(
      slug:        json['slug']        as String? ?? '',
      nom:         json['nom']         as String? ?? '',
      description: json['description'] as String?,
      attributs: rawAttributs
          .map((a) => AttributDefinitionModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

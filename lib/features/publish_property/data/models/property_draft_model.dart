import '../../domain/entities/property_draft_entity.dart';

/// Modèle data — sérialisation du brouillon + mapping vers l'API.
class PropertyDraftModel extends PropertyDraftEntity {
  const PropertyDraftModel({
    super.propertyType,
    super.transactionType,
    super.title,
    super.price,
    super.surface,
    super.superficie,
    super.rooms = 1,
    super.bathrooms = 1,
    super.description,
    super.address,
    super.latitude,
    super.longitude,
    super.caracteristiques = const {},
    super.mediaPaths = const [],
    super.idDocumentPath,
    super.justificatifProprietePath,
    super.cadastralPlanPath,
    super.otherDocumentPaths = const [],
  });

  factory PropertyDraftModel.fromEntity(PropertyDraftEntity e) {
    return PropertyDraftModel(
      propertyType:              e.propertyType,
      transactionType:           e.transactionType,
      title:                     e.title,
      price:                     e.price,
      surface:                   e.surface,
      superficie:                e.superficie,
      rooms:                     e.rooms,
      bathrooms:                 e.bathrooms,
      description:               e.description,
      address:                   e.address,
      latitude:                  e.latitude,
      longitude:                 e.longitude,
      caracteristiques:          e.caracteristiques,
      mediaPaths:                e.mediaPaths,
      idDocumentPath:            e.idDocumentPath,
      justificatifProprietePath: e.justificatifProprietePath,
      cadastralPlanPath:         e.cadastralPlanPath,
      otherDocumentPaths:        e.otherDocumentPaths,
    );
  }

  Map<String, dynamic> toJson() => {
        'property_type':        propertyType,
        'transaction_type':     transactionType,
        'title':                title,
        'price':                price,
        'surface':              surface,
        'superficie':           superficie,
        'rooms':                rooms,
        'bathrooms':            bathrooms,
        'description':          description,
        'address':              address,
        'latitude':             latitude,
        'longitude':            longitude,
        'caracteristiques':     caracteristiques,
        'media_count':          mediaPaths.length,
        'other_docs_count':     otherDocumentPaths.length,
      };
}

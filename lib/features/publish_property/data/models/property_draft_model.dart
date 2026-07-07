import '../../domain/entities/property_draft_entity.dart';

/// Modèle data — sérialisation JSON du brouillon.
class PropertyDraftModel extends PropertyDraftEntity {
  const PropertyDraftModel({
    super.propertyType,
    super.transactionType,
    super.title,
    super.price,
    super.surface,
    super.rooms = 1,
    super.bathrooms = 1,
    super.description,
    super.address,
    super.latitude,
    super.longitude,
    super.mediaPaths = const [],
    super.titleDeedPath,
    super.idDocumentPath,
    super.cadastralPlanPath,
    super.otherDocumentPaths = const [],
  });

  factory PropertyDraftModel.fromEntity(PropertyDraftEntity e) {
    return PropertyDraftModel(
      propertyType:       e.propertyType,
      transactionType:    e.transactionType,
      title:              e.title,
      price:              e.price,
      surface:            e.surface,
      rooms:              e.rooms,
      bathrooms:          e.bathrooms,
      description:        e.description,
      address:            e.address,
      latitude:           e.latitude,
      longitude:          e.longitude,
      mediaPaths:         e.mediaPaths,
      titleDeedPath:      e.titleDeedPath,
      idDocumentPath:     e.idDocumentPath,
      cadastralPlanPath:  e.cadastralPlanPath,
      otherDocumentPaths: e.otherDocumentPaths,
    );
  }

  Map<String, dynamic> toJson() => {
        'property_type':    propertyType,
        'transaction_type': transactionType,
        'title':            title,
        'price':            price,
        'surface':          surface,
        'rooms':            rooms,
        'bathrooms':        bathrooms,
        'description':      description,
        'address':          address,
        'latitude':         latitude,
        'longitude':        longitude,
        'media_count':      mediaPaths.length,
        'other_docs_count': otherDocumentPaths.length,
      };
}

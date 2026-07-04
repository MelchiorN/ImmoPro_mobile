import '../../domain/entities/user_entity.dart';

/// Modèle pour sérialiser/désérialiser l'utilisateur depuis/vers l'API Laravel.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.telephone,
    required super.country,
    required super.city,
    super.profilePicture,
    required super.role,
    required super.status,
    super.emailVerifiedAt,
    super.token,
  });

  /// Crée un UserModel à partir de la réponse JSON du backend Laravel.
  /// Exemple : { "id": "uuid", "first_name": "John", "last_name": "Doe", ... }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      profilePicture: json['profile_picture'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'telephone': telephone,
      'country': country,
      'city': city,
      'profile_picture': profilePicture,
      'role': role,
      'status': status,
      'email_verified_at': emailVerifiedAt,
      'token': token,
    };
  }
}

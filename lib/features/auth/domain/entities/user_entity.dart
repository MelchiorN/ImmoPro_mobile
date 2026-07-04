/// Représente un utilisateur dans la couche domaine.
///
/// Correspond à la réponse JSON du backend Laravel :
/// { id (UUID), first_name, last_name, email, telephone, country, city,
///   profile_picture, role, status, email_verified_at }
class UserEntity {
  final String id; // UUID string
  final String firstName;
  final String lastName;
  final String email;
  final String telephone;
  final String country;
  final String city;
  final String? profilePicture;
  final String role;   // "client" | "agent" | "admin"
  final String status; // "active" | "suspended" | "blocked"
  final String? emailVerifiedAt;
  final String? token; // Sanctum bearer token (présent après login/verify-otp)

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.country,
    required this.city,
    this.profilePicture,
    required this.role,
    required this.status,
    this.emailVerifiedAt,
    this.token,
  });

  String get fullName => '$firstName $lastName';
  bool get isEmailVerified => emailVerifiedAt != null;
}

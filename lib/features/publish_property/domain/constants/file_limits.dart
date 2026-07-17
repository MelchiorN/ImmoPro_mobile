/// Limites de taille et de format pour les fichiers du formulaire de publication.
class FileLimit {
  // ── Médias (photos + vidéos) ──────────────────────────────────────────────

  /// Taille max par photo : 10 Mo
  static const int maxPhotoBytes = 10 * 1024 * 1024;

  /// Taille max par vidéo : 50 Mo
  static const int maxVideoBytes = 50 * 1024 * 1024;

  /// Nombre minimum de médias requis
  static const int minMediaCount = 3;

  /// Nombre maximum de médias
  static const int maxMediaCount = 10;

  /// Taille totale max de tous les médias : 150 Mo
  static const int maxTotalMediaBytes = 150 * 1024 * 1024;

  /// Formats photo acceptés
  static const List<String> photoExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Formats vidéo acceptés
  static const List<String> videoExtensions = ['mp4', 'mov', 'avi'];

  // ── Documents ─────────────────────────────────────────────────────────────

  /// Taille max par document : 5 Mo
  static const int maxDocumentBytes = 5 * 1024 * 1024;

  /// Taille totale max de tous les documents : 20 Mo
  static const int maxTotalDocumentBytes = 20 * 1024 * 1024;

  /// Formats document acceptés
  static const List<String> documentExtensions = ['pdf'];

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Formate un nombre d'octets en unité lisible (Mo, Ko).
  static String formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} Ko';
    }
    return '$bytes octets';
  }

  /// Retourne vrai si l'extension est un format photo valide.
  static bool isValidPhoto(String path) {
    final ext = path.split('.').last.toLowerCase();
    return photoExtensions.contains(ext);
  }

  /// Retourne vrai si l'extension est un format vidéo valide.
  static bool isValidVideo(String path) {
    final ext = path.split('.').last.toLowerCase();
    return videoExtensions.contains(ext);
  }

  /// Retourne vrai si l'extension est un format document valide.
  static bool isValidDocument(String path) {
    final ext = path.split('.').last.toLowerCase();
    return documentExtensions.contains(ext);
  }
}

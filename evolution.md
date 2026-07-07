# ImmoPro — Journal des évolutions

Fichier unique de suivi. Chaque section = une session de travail.
Pour continuer : lire la dernière section "En cours / À faire" et reprendre.

---

## Session 1 — Feature "Publier un bien" (Flow 4 étapes)

### Date : Juillet 2026

### Ce qui a été fait

#### Mobile Flutter

**Architecture Clean Architecture mise en place :**
```
lib/features/publish_property/
  domain/
    entities/property_draft_entity.dart     → brouillon immuable (copyWith)
    repositories/publish_repository.dart    → contrat abstrait
    usecases/submit_property_usecase.dart   → cas d'usage soumission
  data/
    models/property_draft_model.dart        → sérialisation JSON
    datasources/publish_remote_datasource.dart → stub (à brancher sur l'API)
    repositories/publish_repository_impl.dart
  presentation/
    controllers/publish_controller.dart     → ChangeNotifier, gère les 4 étapes
    pages/
      step1_info_page.dart    → Étape 1 : Infos de base
      step2_media_page.dart   → Étape 2 : Photos/Vidéos
      step3_documents_page.dart → Étape 3 : Documents
      step4_summary_page.dart → Étape 4 : Récapitulatif
      verification_page.dart  → Écran confirmation (en attente)
    widgets/
      publish_app_bar.dart        → AppBar commune avec step indicator
      publish_bottom_bar.dart     → Barre bas (Retour / Suivant)
      step_indicator.dart         → Dots animés de progression
      location_picker_widget.dart → Carte OSM + GPS + geocoding
```

**Dépendances ajoutées dans pubspec.yaml :**
- `geolocator: ^13.0.2` — GPS
- `geocoding: ^3.0.0` — adresse ↔ coordonnées
- `image_picker: ^1.1.2` — photos/vidéos
- `file_picker: ^8.1.7` — documents PDF/JPG
- `flutter_map: ^7.0.2` + `latlong2: ^0.9.1` — carte OpenStreetMap
- `permission_handler: ^11.3.1` — permissions runtime
- `dotted_border: ^2.1.0`

**Permissions ajoutées :**
- Android `AndroidManifest.xml` : `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`
- iOS `Info.plist` : `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`

**Navigation :**
- Bouton `+` (`HomeBottomNavBar`) → `Navigator.pushNamed('/publish')`
- Route `/publish` enregistrée dans `main.dart` → `Step1InfoPage`
- Flow push/pop entre étapes (le controller est passé en paramètre)

#### Fonctionnalités Étape 1 — champs adaptatifs

| Type de bien       | Pièces/SDB | Surface | Description |
|--------------------|-----------|---------|-------------|
| Appartement        | ✅         | ✅       | Optionnelle |
| Maison             | ✅         | ✅       | Optionnelle |
| Villa              | ✅         | ✅       | Optionnelle |
| **Terrain**        | ❌ masqué  | ✅       | Optionnelle |
| Bureau / Commerce  | ✅         | ✅       | Optionnelle |

**Localisation (widget réutilisable) :**
- Saisie texte (adresse ou `lat, lng`) + bouton recherche
- Bouton "Ma position GPS" avec gestion des permissions
- Tap sur la carte → repositionne le pin
- Reverse geocoding automatique → remplit le champ adresse
- Carte OpenStreetMap (sans clé API)

---

## Session 2 — Backend Laravel : Feature "Bien Immobilier" ✅ TERMINÉE

### Date : Juillet 2026

### Fichiers créés / modifiés

#### Backend Laravel (`IMMOPRO_BACKEND/`)

**Migrations :**
```
database/migrations/
  2026_07_06_000001_create_biens_table.php
  2026_07_06_000002_create_media_biens_table.php
  2026_07_06_000003_create_document_biens_table.php
```

**Modèles :**
```
app/Models/
  Bien.php          → HasUuids, SoftDeletes, scopes (publie, typeBien, prixEntre...)
  MediaBien.php     → url_publique (accessor Storage::disk public)
  DocumentBien.php  → url_privee  (accessor Storage::disk local)
  User.php          → +biens(), +biensAgentAssigne() (relations ajoutées)
```

**Form Requests :**
```
app/Http/Requests/
  StoreBienRequest.php   → validation multipart, règles conditionnelles par type_bien
  UpdateBienRequest.php  → authorize() vérifie propriétaire + statut modifiable
```

**Resources API :**
```
app/Http/Resources/
  BienResource.php       → détail complet (note_admin cachée selon rôle)
  BienListResource.php   → version allégée pour les listes paginées
  MediaBienResource.php
  DocumentBienResource.php → URL privée selon rôle
```

**Controllers :**
```
app/Http/Controllers/
  Bien/
    BienController.php       → index, store (multipart+transaction DB), show, update, destroy
    BienPublicController.php → index (filtres + Haversine GPS), show
  Admin/
    BienAdminController.php  → index, show, updateStatut (machine à états)
```

**Routes (api.php mis à jour) :**
```
GET  /api/biens                     → public, biens publiés (filtres + pagination)
GET  /api/biens/{id}                → public, détail

[auth:sanctum]
POST   /api/biens                   → créer + soumettre (multipart)
GET    /api/mes-biens               → mes annonces (filtrable par statut)
GET    /api/mes-biens/{id}          → détail
PUT    /api/mes-biens/{bien}        → modifier (brouillon/rejeté seulement)
DELETE /api/mes-biens/{id}          → supprimer (non publié)

GET    /api/admin/biens             → tous les biens (admin/agent)
GET    /api/admin/biens/{id}        → détail complet
PATCH  /api/admin/biens/{id}/statut → publie / rejete / archive
```

**Machine à états statut :**
```
brouillon  → en_attente
en_attente → publie | rejete
rejete     → publie | (re-soumission → en_attente auto)
publie     → archive | rejete
archive    → publie
```

**Seeder :**
```
database/seeders/BienSeeder.php → 4 biens de test (appartement, villa, terrain, studio)
```

#### Flutter (`immopro_mobile/`)

**`api_client.dart` mis à jour :**
- Ajout `putAuth()`, `deleteAuth()`
- Ajout `postMultipart()` — upload fichiers avec token Sanctum
- Classe `MultipartFileEntry` pour les fichiers

**`publish_remote_datasource.dart` — RÉEL (plus de stub) :**
- Construit `fields` + `files` depuis `PropertyDraftModel`
- Appelle `ApiClient.postMultipart('/biens', ...)`
- Gère `typesSansChambre` pour ne pas envoyer nb_pieces pour Terrain

**`publish_controller.dart` mis à jour :**
- Catch `ApiException` → extrait erreurs 422 Laravel (champ par champ)
- Message d'erreur lisible pour l'utilisateur

### Commandes à lancer (une seule fois)

```bash
cd IMMOPRO_BACKEND

# 1. Exécuter les migrations
php artisan migrate

# 2. Créer le lien symbolique storage → public/storage
php artisan storage:link

# 3. (Optionnel) Seeder de test
php artisan db:seed --class=BienSeeder

# 4. Lancer le serveur
php artisan serve
```

---

## En cours / À faire (prochaine session)

### Priorité 1 — Tests & validation backend
- [ ] Tester POST `/api/biens` avec Postman/Insomnia (multipart)
- [ ] Vérifier les transitions de statut PATCH `/api/admin/biens/{id}/statut`
- [ ] Tester filtres GET `/api/biens` (type_bien, prix_min/max, géo)
- [ ] Ajouter middleware `role:admin,agent` sur les routes admin (actuellement non protégées par rôle)

### Priorité 2 — Middleware rôle admin/agent
Créer `app/Http/Middleware/CheckRole.php` et protéger les routes admin :
```php
Route::middleware(['auth:sanctum', 'role:admin,agent'])->group(...)
```

### Priorité 3 — Flutter : écrans liste et détail
- [ ] `MesBiensPage` — liste des annonces du propriétaire avec statuts
- [ ] `BienDetailPage` — détail public avec galerie photos
- [ ] `HomeRemoteDataSource` — brancher GET `/api/biens` sur la page d'accueil

### Priorité 4 — Notifications
- [ ] Notifier le propriétaire quand son bien est publié/rejeté
- [ ] Utiliser le modèle `Notification` existant + push mobile

### Notes techniques

**Upload multipart :**
Les médias sont stockés dans `storage/app/public/biens/{id}/medias/` (disque `public`).
Les documents dans `storage/app/local/biens/{id}/documents/` (disque `local`, privé).
`php artisan storage:link` est **obligatoire** pour que les URLs publiques fonctionnent.

**Haversine (recherche géo) :**
La requête SQL dans `BienPublicController::index()` utilise la formule Haversine standard.
Fonctionne sur MySQL/MariaDB/PostgreSQL. Sur SQLite (dev), la fonction `acos` peut ne pas être disponible — désactiver ce filtre en dev si besoin.

**Tokens Sanctum :**
Le token est stocké dans `flutter_secure_storage` sous la clé `sanctum_token`.
`ApiClient.postMultipart()` le récupère automatiquement via `getToken()`.

---

## Pour reprendre ce fichier

1. Lire **"En cours / À faire"** ci-dessus
2. Lancer les commandes backend (migrate + storage:link)
3. Tester les routes API avec Postman
4. Continuer avec le middleware rôle ou les écrans Flutter liste/détail

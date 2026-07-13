# Journalisation des Appels API (Mobile)

Ce plan décrit les modifications pour ajouter des logs de débogage pour toutes les requêtes réseau (`GET`, `POST`, `PUT`, `DELETE`) effectuées par l'application mobile. Cela permettra de suivre en temps réel dans votre console les URLs appelées, les en-têtes (headers), les corps de requêtes (payloads), les codes de retour HTTP (ex: 200, 401, 403, 500) et les réponses du serveur.

## Proposed Changes

### Mobile Client

#### [MODIFY] [api_client.dart](file:///d:/Th%20Stage/Projet/ImmoPro/immopro_mobile/lib/core/network/api_client.dart)
* Ajouter les méthodes utilitaires privées `_logRequest` et `_logResponse` pour standardiser le format d'affichage dans la console.
* Mettre à jour toutes les méthodes de requêtes publiques (`getPublic`, `getAuth`, `postAuth`, `putAuth`, `deleteAuth`) pour qu'elles utilisent ces fonctions de log.

## Verification Plan

### Manual Verification
* Démarrer l'application en mode debug (`flutter run`).
* Effectuer des actions comme la connexion, le chargement des biens ou la soumission de formulaires.
* Constater l'apparition de blocs lisibles décrivant chaque requête et réponse API directement dans le terminal de débogage.

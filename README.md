# porc

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Realtime Sync (Messages/Appels/Publications)

L'application supporte la synchronisation inter-appareils via Firebase
Firestore (chat + actualités).

Configuration minimale:

1. Créez un projet Firebase et activez Firestore.
2. Fournissez ces variables au build (dart-define):
   - `FIREBASE_API_KEY`
   - `FIREBASE_APP_ID`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_MESSAGING_SENDER_ID`
3. Optionnel:
   - `FIREBASE_AUTH_DOMAIN`
   - `FIREBASE_STORAGE_BUCKET`
   - `FIREBASE_MEASUREMENT_ID`

Pour GitHub Pages, renseignez les mêmes clés dans GitHub Secrets.
Le workflow `deploy-pages.yml` les injecte automatiquement au build web.

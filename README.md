# Kigali City Services & Places Directory

A Flutter app for locating important city services and lifestyle places in Kigali, backed by Firebase Authentication and Cloud Firestore.

**Core features**
- Email/password authentication with verification flow.
- User profile document stored in Firestore for each authenticated account.
- Listings CRUD: create, read, update, and delete places/services.
- Real-time list updates through Provider + Firestore streams.
- Search by name and filter by category.
- Listing detail with location preview and one-tap Google Maps navigation.
- Bottom navigation: Directory, My Listings, Map View, Settings.
- Settings screen with profile info and local notifications toggle simulation.

**State management and architecture**
- `Provider` is used as the state layer.
- UI screens do not call Firebase directly.
- Data flow is `UI -> Provider -> Service -> Firebase` and back through provider notifications/streams.
- Main layers used in this project:
  - `lib/models` for data models.
  - `lib/services` for Firebase Auth and Firestore operations.
  - `lib/providers` for app state and async operation states.
  - `lib/screens` for presentation and navigation.

**Firestore data model**
- `users/{uid}`
  - `email`
  - `displayName`
  - `emailVerified`
- `listings/{listingId}`
  - `name`
  - `category`
  - `address`
  - `contactNumber`
  - `description`
  - `latitude`
  - `longitude`
  - `createdBy`
  - `timestamp`
- `listings/{listingId}/reviews/{userId}`
  - `userId`
  - `userName`
  - `rating`
  - `comment`
  - `timestamp`

**Firebase setup**
1. Create a Firebase project.
2. Register Android app package name: `com.example.kigali_city_directory`.
3. Download `google-services.json` and place it in `android/app`.
4. Enable Authentication (Email/Password).
5. Enable Cloud Firestore.
6. Apply Firestore security rules similar to the policy below.

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth != null
        && resource.data.createdBy == request.auth.uid;

      match /reviews/{reviewUserId} {
        allow read: if request.auth != null;
        allow create, update, delete: if request.auth != null
          && reviewUserId == request.auth.uid;
      }
    }
  }
}
```

**Run locally**
1. `flutter pub get`
2. `flutter run -d <device_id>`

If emulator install hangs, a reliable fallback is:
- `adb install --no-streaming -r -t -g build/app/outputs/flutter-apk/app-debug.apk`

**Notes for demo recording**
- Keep Firebase Console visible while demonstrating auth and CRUD operations.
- Show both app behavior and relevant service/provider code paths.

**Tech stack**
- Flutter
- Firebase Authentication
- Cloud Firestore
- Provider
- URL Launcher

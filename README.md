# Kigali City Services & Places Directory

A Flutter mobile app to help Kigali residents locate and navigate to essential public services and lifestyle locations, with full Firebase backend integration.

## Features
- **Firebase Authentication**: Sign up, login, logout, and email verification
- **User Profiles**: Each user has a Firestore profile
- **CRUD Listings**: Create, read, update, and delete places/services (hospitals, restaurants, parks, etc.)
- **Real-time Updates**: All changes reflected instantly via Provider state management
- **Search & Filter**: Search listings by name and filter by category
- **Detail Page & Map**: View listing details with embedded Google Map and navigation button
- **Bottom Navigation**: Directory, My Listings, Map View, and Settings screens
- **Settings**: User profile info and notification toggle

## Firestore Structure
- **users** (collection)
  - [uid] (document)
    - email
    - displayName
    - emailVerified
- **listings** (collection)
  - [listingId] (document)
    - name
    - category
    - address
    - contactNumber
    - description
    - latitude
    - longitude
    - createdBy (user UID)
    - timestamp

## State Management
- Uses **Provider** for all app state
- All Firestore operations are handled in service/provider layers (never directly in UI)
- UI updates automatically on data changes

## Navigation Structure
- **Directory**: Browse/search/filter all listings
- **My Listings**: Manage your own listings
- **Map View**: See all listings on a map
- **Settings**: Profile and notification preferences

## Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com/
2. Add Android/iOS app and follow setup instructions
3. Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) and place in respective folders
4. Enable **Authentication** (Email/Password) and **Cloud Firestore** in Firebase Console
5. Update Firestore rules for security:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /listings/{listingId} {
         allow read: if true;
         allow write: if request.auth != null && request.auth.uid == request.resource.data.createdBy;
       }
     }
   }
   ```

## How to Run
1. Install dependencies: `flutter pub get`
2. Run on emulator/device: `flutter run`

## Demo Video
- See attached video for a walkthrough of all features and Firebase Console integration.

## Author
- Kigali City Directory Assignment
- Powered by Flutter, Firebase, and Provider

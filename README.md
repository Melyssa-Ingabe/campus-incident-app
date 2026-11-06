# Campus Incident Reporting App

A Flutter mobile app that lets ALU students report campus issues (water,
electricity, facilities, safety, sanitation) and lets authorised staff
review reports and update their status.

## Features
- Firebase Authentication with ALU-only email registration and email verification
- Student and staff roles with role-based access control (Firestore security rules)
- Submit incidents with category, title, description, location and optional photo
- Browse, search and filter reports; view details and a status timeline
- Staff can update status (Submitted > In Progress > Resolved)
- Photos stored on Cloudinary; incident data in Cloud Firestore

## Tech stack
Flutter, Provider (state management), Firebase Auth, Cloud Firestore, Cloudinary

## Architecture
lib/models (data), lib/services (Firebase and upload logic),
lib/providers (state), lib/screens and lib/widgets (UI), lib/utils (helpers)

## Run the app
1. flutter pub get
2. flutter run (Android or iOS device/emulator)

## Staff accounts
All users register as students. A staff account is created by changing
the user's role to "staff" in the Firestore users collection.

## Tests
flutter test

## Security rules
See firestore.rules
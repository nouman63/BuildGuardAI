# Connect your Firebase project

The app uses Firebase Authentication and Cloud Firestore. Android now reads
`android/app/google-services.json` using the Google Services Gradle plugin.
That local configuration is excluded from Git. Web configuration is separate.

## 1. Create the project

Open https://console.firebase.google.com/ and create your BuildGuard AI project.
Keep its **project ID** for the commands below.

In the Firebase console:

1. Open Authentication and enable **Email/Password** under Sign-in method.
2. Create a **Cloud Firestore Standard edition** database with the `(default)`
   database ID. Choose your intended region and start in **production mode**.
3. For web development, add `localhost` and `127.0.0.1` in Authentication's
   Settings > Authorized domains if they are absent. Add your deployed web
   hostname before testing a deployed app.

Do not create service-account keys or put admin credentials in the Flutter app.

## 2. Local configuration

### Android

The supplied Android configuration is installed locally at:

```text
android/app/google-services.json
```

Its package name must match `com.example.buildguard_ai`. Android initialization
uses native resources generated from that file; there is no need to put the API
key or project identifiers in tracked Dart source. After cloning this repository
on another computer, copy your configuration into that path before building.

```powershell
flutter pub get
flutter devices
flutter run -d DEVICE_ID
```

### Web (optional)

The Android JSON cannot configure a Firebase web app. Register a web app in
Firebase Project settings, then copy `firebase.web.example.json` to
`firebase.web.local.json`. Fill its fields using the web app's SDK configuration:

- `FIREBASE_API_KEY`: `apiKey`
- `FIREBASE_APP_ID`: the **web** `appId`
- `FIREBASE_MESSAGING_SENDER_ID`: `messagingSenderId`
- `FIREBASE_PROJECT_ID`: `projectId`
- `FIREBASE_AUTH_DOMAIN`: `authDomain`
- `FIREBASE_STORAGE_BUCKET`: `storageBucket`

Run/build using the ignored local file:

```powershell
flutter run -d chrome --dart-define-from-file=firebase.web.local.json
flutter build web --dart-define-from-file=firebase.web.local.json
```

`lib/firebase_configuration.dart` is safe to commit: it contains no project
values. A FlutterFire-generated `lib/firebase_options.dart`, if created later,
is ignored and is not used by this initialization path.

### GitHub exclusions

The `.gitignore` excludes Firebase platform configs, local web configuration,
`.firebaserc`, `.env` files, common service-account filenames and signing keys.
The rules, generic configuration loader and placeholder example stay in Git.
Run `git check-ignore android/app/google-services.json` to verify the Android
file is ignored. No tracked Firebase configuration existed when this was set up.

Firebase client settings are embedded in built apps and are not server secrets.
Keeping configuration out of Git follows this project's preference; data access
must still be protected by the included Firestore rules. Never include admin
credentials in the app. Restrict API keys appropriately in Google Cloud Console.

## 3. Deploy the included rules

```powershell
firebase deploy --only firestore:rules,firestore:indexes --project YOUR_PROJECT_ID
flutter run -d DEVICE_ID
```

To run on Android, select a connected device with `flutter devices`, then run
`flutter run -d DEVICE_ID`. The Android release manifest includes Internet access.

## 4. Verify the real connection

1. Sign up in the app. Check that the account appears in Firebase Authentication.
2. Generate a risk report. Check `users/<your-auth-uid>/riskReports` in Firestore.
3. Reload/restart: the session should restore and the report should load.
4. Log out: the app should return to the landing page and remove private screens.
5. Sign up with a second email: the first user's reports must not appear.
6. Sign back into the first account: its reports should return.
7. Analyze a floor plan: its report metadata/findings should appear under
   `users/<uid>/floorReports` and return in Floor Plan History after restart.
8. Check password reset using an email you own.

## Data and behavior

- Authentication uses Firebase's email/password provider and session stream.
- Passwords are sent only to Firebase Auth; they are never written to Firestore.
- Names are stored in the Firebase Auth display name.
- Reports live under `users/{uid}/riskReports/{reportId}` and
  `users/{uid}/floorReports/{projectId}`.
- Snapshots update saved-report lists. Signing out/account switching clears
  cached reports and cancels the previous account's subscriptions.
- Risk inputs, materials, assessment time and generated findings are stored.
  Reading an old report does not rerun the current risk heuristics.
- Saves show an error on failure, retain form inputs, and can be retried.
  A queued offline write may finish later; retries reuse the same report ID.
- Uploaded floor-plan images stay on the original device during the session.
  Firestore stores report data, not temporary file paths or image bytes.
  Add Firebase Storage separately if you need images available across devices.
- PDF export regenerates the PDF from report data; PDF files are not uploaded.
- Construction analysis remains the existing prototype; Firebase does not turn
  its sample results or heuristics into an AI model or regulatory validation.

## Local checks

```powershell
flutter analyze
flutter test
flutter build web
```

Tests use an injected backend to check session restoration, account isolation,
save failures, serialization and navigation without real user credentials.
Live Firebase connectivity and deployed rules must be verified after project setup.

Official setup: https://firebase.google.com/docs/flutter/setup

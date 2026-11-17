# BuildGuard AI — Flutter Frontend

Flutter implementation of the supplied Figma Make design, including:

- Public landing page, core feature cards and navy sign-in panel
- Firebase email/password login, sign-up, logout, password reset and session restoration
- Home, Floor Plan and Risk bottom navigation
- Profile and saved reports
- Floor-plan image selection, camera capture and sample analysis results
- Two-step risk workflow: project details and material inventory
- Material creation, editing and removal
- Input validation, expense totals, progress slider and date selection
- Expandable risk findings, category overview and PDF export
- Bundled Plus Jakarta Sans font (license in assets/fonts/OFL.txt)

## Run and verify

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for local configuration and deployment.
Android uses the ignored `android/app/google-services.json`. Web requires a
separate ignored `firebase.web.local.json` passed with `--dart-define-from-file`.
Copy your local configuration after cloning; project values are not committed.

```sh
flutter pub get
flutter run -d chrome --dart-define-from-file=firebase.web.local.json
flutter analyze
flutter test
flutter build web
```

The app uses a centered mobile-width layout on larger displays. Android and web
platform scaffolding are included. Camera access depends on device/browser support.

## Prototype limitations

Authentication uses Firebase Auth and report data is stored per user in Firestore.
Deploy the included ownership rules before using the database. Floor-plan images
remain local; cloud image storage is not included. See FIREBASE_SETUP.md for the
schema, configuration and live verification steps.
Floor-plan results are explicitly marked as samples, with no computer-vision model
or live LDA rule validation. Risk reports use transparent local heuristics for
schedule, spending, workforce and inventory; they are not AI predictions or
regulatory approval. Empty inventory is reported as not assessed.

Connect computer vision, cloud image storage and risk services before
using this application for actual project decisions. The legacy project-data route
and sample floor-plan history remain available for backend integration.

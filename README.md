# BuildGuard AI — Flutter Frontend

Flutter implementation of the supplied Figma Make design, including:

- Public landing page, core feature cards and navy sign-in panel
- Login and sign-up with local session state
- Home, Floor Plan and Risk bottom navigation
- Profile and saved reports
- Floor-plan image selection, camera capture and sample analysis results
- Two-step risk workflow: project details and material inventory
- Material creation, editing and removal
- Input validation, expense totals, progress slider and date selection
- Expandable risk findings, category overview and PDF export
- Bundled Plus Jakarta Sans font (license in assets/fonts/OFL.txt)

## Run and verify

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
flutter build web
```

The app uses a centered mobile-width layout on larger displays. Android and web
platform scaffolding are included. Camera access depends on device/browser support.

## Prototype limitations

Authentication is local only; passwords are not sent to a server or persisted.
Project data and saved reports exist only in memory and reset on restart.
Floor-plan results are explicitly marked as samples, with no computer-vision model
or live LDA rule validation. Risk reports use transparent local heuristics for
schedule, spending, workforce and inventory; they are not AI predictions or
regulatory approval. Empty inventory is reported as not assessed.

Connect real authentication, storage, computer vision and risk services before
using this application for actual project decisions. The legacy project-data route
and sample floor-plan history remain available for backend integration.

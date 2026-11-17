import 'package:flutter/material.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: SafeArea(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.cloud_off_outlined, size: 48),
                    SizedBox(height: 20),
                    Text('Firebase setup required',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    SizedBox(height: 16),
                    Text(
                        'Follow FIREBASE_SETUP.md to add the local configuration for this platform and enable Firebase Authentication and Firestore. Then rebuild the app.',
                        textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    SelectableText(
                        'Android: android/app/google-services.json\nWeb: firebase.web.local.json'),
                  ])))));
}

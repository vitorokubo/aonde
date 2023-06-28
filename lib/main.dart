import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'views/app.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: String.fromEnvironment('apiKey'),
  authDomain: String.fromEnvironment('authDomain'),
  projectId: String.fromEnvironment('projectId'),
  storageBucket: String.fromEnvironment('storageBucket'),
  messagingSenderId: String.fromEnvironment('messagingSenderId'),
  appId: String.fromEnvironment('appId'),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const App());
}

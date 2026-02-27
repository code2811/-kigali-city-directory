import 'package:flutter/material.dart';
import 'app.dart';
import 'services/firebase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  runApp(const KigaliCityDirectoryApp());
}

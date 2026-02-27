import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/directory/directory_screen.dart';
import 'screens/directory/add_listing_screen.dart';
import 'screens/main_navigation_screen.dart';

class KigaliCityDirectoryApp extends StatelessWidget {
  const KigaliCityDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali City Directory',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),
          '/main': (context) => const MainNavigationScreen(),
          '/directory': (context) => const DirectoryScreen(),
          '/add-listing': (context) => const AddListingScreen(),
        },
      ),
    );
  }
}

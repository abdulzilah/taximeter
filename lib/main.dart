import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taximeter_project/providers/history_provider.dart';
import 'package:taximeter_project/providers/settings_provider.dart';
import 'package:taximeter_project/providers/staff_provider.dart';
import 'package:taximeter_project/providers/trip_provider.dart';
import 'package:taximeter_project/screens/createTrip_screen.dart';
import 'package:taximeter_project/screens/signup_screen.dart';
import 'package:taximeter_project/utils/colors.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // Import your home screen
import 'screens/history_screen.dart'; // Import history screen
import 'screens/settings_screen.dart'; // Import settings screen
import 'providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'screens/error_screen.dart'; // Import your custom error screen

void main() {
      runApp(MyApp());

  // Set up global error handlers
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.presentError(details);
  //   // Log the error here if needed (e.g., to a remote server)
  //   _showErrorScreen(details.exception.toString());
  // };

  // runZonedGuarded(() {
  //   runApp(MyApp());
  // }, (Object error, StackTrace stackTrace) {
  //   // This will catch errors from asynchronous code
  //   _showErrorScreen(error.toString());
  // });
}

void _showErrorScreen(String errorMessage) {
  runApp(MaterialApp(
    home: ErrorScreen(errorMessage: errorMessage),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(
            create: (context) => SettingsProvider()..fetchSettings()),
        ChangeNotifierProvider(
            create: (context) => AuthProvider()..fetchUserProfile()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: coloringThemes.primary,
            colorScheme: ColorScheme.light(primary: coloringThemes.primary,)),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => SplashScreen(),
          '/onboarding': (_) => OnboardingScreen(),
          '/login': (_) => LoginScreen(),
          '/home': (_) => HomeScreen(),
          '/trips': (_) => CreateTripScreen(),
          '/history': (_) => HistoryScreen(),
          '/settings': (_) => SettingsScreen(),
        },
      ),
    );
  }
}

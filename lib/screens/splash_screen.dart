import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taximeter_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    print("here");
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    print(accessToken);
    final AuthProvider provider = AuthProvider();
    await provider.fetchUserProfile();
    print(accessToken);
    if (accessToken != null) {
      // User is signed in, navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not signed in, go to onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

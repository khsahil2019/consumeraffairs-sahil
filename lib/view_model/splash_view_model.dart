import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashViewModel extends ChangeNotifier {
  // Ye method app start hote hi 3 second wait karta hai,
  // fir check karta hai user login hai ya nahi
  Future<void> initializeApp(BuildContext context) async {
    // Thoda wait karo (3 seconds), jaise splash screen dikh rahi ho
    await Future.delayed(const Duration(seconds: 3));

    // SharedPreferences ka instance lo — yeh local storage hai phone ki
    final prefs = await SharedPreferences.getInstance();

    // Check karo user login hai ya nahi
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Agar user login hai to Dashboard screen pe bhejo
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard_screen');
    } else {
      // Agar login nahi hai to Login screen pe bhejo
      Navigator.pushReplacementNamed(context, '/login_screen');
    }
  }
}

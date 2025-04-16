import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/splash_view_model.dart';

// SplashScreen widget — yeh app open hote hi pehla screen dikhata hai
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Ye ensure karta hai ki context tabhi use ho jab widget tree build ho chuka ho
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ViewModel ko access karke app initialization start karte hain
      final splashViewModel =
          Provider.of<SplashViewModel>(context, listen: false);
      splashViewModel.initializeApp(
          context); // yeh method decide karega kaha navigate karna hai
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Logo aur loading indicator ekdum center mein
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Image.asset(
                  "assets/images/consumer affairs logo png.png"), // App logo
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor, // Loader with theme color
            ),
          ],
        ),
      ),
    );
  }
}

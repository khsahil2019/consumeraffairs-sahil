import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_model/login_view_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_txt_field.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: -100,
            right: 0,
            child: Image.asset("assets/images/top_img.png",
                fit: BoxFit.fill, height: 300),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign in to your account",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      hintText: "Email",
                      prefixIcon: Icons.person,
                      onChanged: (value) => loginViewModel.setUsername(value),
                      errorText: loginViewModel.fieldErrors['email'],
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: "Password",
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      onChanged: (value) => loginViewModel.setPassword(value),
                      errorText: loginViewModel.fieldErrors['password'],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: loginViewModel.rememberMe,
                              onChanged: (value) => loginViewModel
                                  .toggleRememberMe(value ?? false),
                            ),
                            const Text("Remember me"),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forget_pass_screen');
                            // TODO: Implement Forgot Password logic
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      title: "Sign in",
                      onPressed: () => loginViewModel.signIn(context),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.grey),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchURL(
                                    'https://affairs.digitalnoticeboard.biz/privacy-policy');
                              },
                          ),
                          const TextSpan(
                            text: ' | ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchURL(
                                    'http://affairs.digitalnoticeboard.biz/terms-conditions');
                              },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    print("Attempting to launch URL: $url");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("Could not launch $url");
      throw 'Could not launch $url';
    }
  }
}

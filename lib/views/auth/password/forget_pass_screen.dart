import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_model/forget_pass_view_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_txt_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final forgotPasswordVM = Provider.of<ForgotPasswordViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: -100,
            right: 0,
            child: Image.asset(
              "assets/images/top_img.png",
              fit: BoxFit.cover,
              height: 150,
            ),
          ),
          // Bottom Green Image
          Positioned(
            bottom: 0,
            left: -330,
            right: 0,
            child: Image.asset(
              "assets/images/bottom_img.png",
              fit: BoxFit.fitHeight,
              height: 150,
              width: 50,
            ),
          ),
          // Forgot Password Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter your registered email address",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  CustomTextField(
                    hintText: "Email",
                    prefixIcon: Icons.person,
                    onChanged: (value) => forgotPasswordVM.setEmail(value),
                    errorText: forgotPasswordVM.fieldErrors['email'],
                  ),
                  const SizedBox(height: 20),
                  // Continue Button
                  CustomButton(
                    title: "Continue",
                    onPressed: () =>
                        forgotPasswordVM.submitForgotPassword(context),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    title: "Back To Sign In",
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

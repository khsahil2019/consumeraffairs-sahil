import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_model/set_password_view_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_txt_field.dart';

class SetNewPasswordScreen extends StatelessWidget {
  const SetNewPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SetPasswordViewModel(),
      child: Consumer<SetPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Set New Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please set up your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    hintText: "Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    onChanged: viewModel.setPassword,
                    errorText: viewModel.fieldErrors['password'],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: "Confirm Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    onChanged: viewModel.setConfirmPassword,
                    errorText: viewModel.fieldErrors['confirm_password'],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    title: "Set Password",
                    onPressed: () => viewModel.submitPassword(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

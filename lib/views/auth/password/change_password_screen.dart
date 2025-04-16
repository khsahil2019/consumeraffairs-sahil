import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_model/change_password_view_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_txt_field.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
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
                    "Change Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please update your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                      hintText: "Current Password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      onChanged: viewModel.setCurrentPassword,
                      errorText: viewModel.fieldErrors['current_password']),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: "New Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    onChanged: viewModel.setNewPassword,
                    errorText: viewModel.fieldErrors['new_password'],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: "Confirm New Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    onChanged: viewModel.setConfirmPassword,
                    errorText:
                        viewModel.fieldErrors['new_password_confirmation'],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    title: "Change Password",
                    onPressed: () {
                      viewModel.submitPassword(context);
                    },
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

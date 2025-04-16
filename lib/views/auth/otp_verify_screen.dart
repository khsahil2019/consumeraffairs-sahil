import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_model/otp_verify_view_model.dart';
import '../../widgets/custom_button.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerifyOtpViewModel(),
      child: Consumer<VerifyOtpViewModel>(
        builder: (context, viewModel, child) {
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
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        const Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Enter the 6-digit code sent to your email address",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return _OtpBox(
                              controller: viewModel.otpControllers[index],
                              focusNode: viewModel.otpFocusNodes[index],
                              nextFocusNode: index < 5
                                  ? viewModel.otpFocusNodes[index + 1]
                                  : null,
                            );
                          }),
                        ),
                        if (viewModel.fieldErrors.containsKey('otp')) ...[
                          const SizedBox(height: 8),
                          Text(
                            viewModel.fieldErrors['otp']!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 40),
                        CustomButton(
                          title: "Submit",
                          onPressed: () => viewModel.submitOtp(context),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;

  const _OtpBox({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (val) {
          if (val.length == 1) {
            nextFocusNode?.requestFocus();
          } else if (val.isEmpty) {
            focusNode.previousFocus();
          }
        },
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/profile_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class ProfileScreen extends StatelessWidget {
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // ViewModel ko yahan access kiya gaya hai (Provider se)
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
        focusNode: focusNode,
        title: 'Profile',
      ),
      endDrawer: CustomEndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile photo circular avatar ke andar dikhayenge
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: ClipOval(
                    child: profileViewModel.image != null &&
                            profileViewModel.image.isNotEmpty
                        ? Image.network(
                            profileViewModel.image,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              // Agar image load nahi hui toh default image dikhayenge
                              return Image.asset(
                                'assets/images/profile_pic.png',
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/profile_pic.png',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Name show karne ke liye Text widget
              Text(
                profileViewModel.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Name edit karne ka textfield
              _buildTextField(
                initialValue: profileViewModel.name,
                onChanged: profileViewModel.updateName,
              ),

              const SizedBox(height: 16),

              // Email edit karne ka textfield
              _buildTextField(
                initialValue: profileViewModel.email,
                onChanged: profileViewModel.updateEmail,
              ),

              const SizedBox(height: 24),

              // Password change screen navigate button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, '/change_pass_screen');
                },
                child: const Text(
                  "Change Password",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable text field builder function
/// isPassword true hoga toh eye icon bhi dikhayenge
Widget _buildTextField({
  required String initialValue,
  required Function(String) onChanged,
  bool isPassword = false,
  bool obscureText = false,
  VoidCallback? toggleVisibility,
}) {
  return TextFormField(
    initialValue: initialValue,
    onChanged: onChanged,
    obscureText: obscureText,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.green, width: 1.5),
      ),
      // Agar password field hai toh suffixIcon mein eye toggle dikhana hai
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            )
          : null,
    ),
  );
}

/// Ye field abhi screen mein use nahi ho rahi
/// Agar future mein password allow karna hai toh ye ready hai
Widget _buildPasswordField(ProfileViewModel profileViewModel) {
  return _buildTextField(
    initialValue: profileViewModel.password,
    onChanged: profileViewModel.updatePassword,
    isPassword: true,
    obscureText: !profileViewModel.isPasswordVisible,
    toggleVisibility: profileViewModel.togglePasswordVisibility,
  );
}

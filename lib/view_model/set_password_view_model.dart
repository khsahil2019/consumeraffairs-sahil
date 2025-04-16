import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class SetPasswordViewModel extends ChangeNotifier {
  String _password = '';
  String _confirmPassword = '';
  bool _isPasswordValid = false;

  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isPasswordValid => _isPasswordValid;

  late final AuthRepository _authRepository;

  SetPasswordViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());
  }

  void setPassword(String value) {
    _password = value.trim();
    _validatePasswords(); // saare checks yahin se honge
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value.trim();
    _validatePasswords(); // repeat nahi karenge
    notifyListeners();
  }

  // Saari field validation yahin pe hai
  void _validatePasswords() {
    _fieldErrors.clear();

    // Basic required field checks
    if (_password.isEmpty) {
      _fieldErrors['password'] = "Password is required.";
    }
    if (_confirmPassword.isEmpty) {
      _fieldErrors['confirm_password'] = "Confirm password is required.";
    }

    // Agar dono filled hain toh aage check karo
    if (_password.isNotEmpty && _confirmPassword.isNotEmpty) {
      if (_password != _confirmPassword) {
        _fieldErrors['confirm_password'] = "Passwords do not match.";
      }

      // Basic manual password strength check (without regex)
      if (_password.length < 8) {
        _fieldErrors['password'] = "Password must be at least 8 characters.";
      } else {
        bool hasLetter = _password.contains(RegExp(r'[A-Za-z]'));
        bool hasNumber = _password.contains(RegExp(r'[0-9]'));
        bool hasSpecialChar =
            _password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

        if (!hasLetter || !hasNumber || !hasSpecialChar) {
          _fieldErrors['password'] =
              "Password must include letters, numbers, and special characters.";
        }
      }
    }

    _isPasswordValid = _fieldErrors.isEmpty;
  }

  Future<void> submitPassword(BuildContext context) async {
    _validatePasswords();
    notifyListeners();

    if (_fieldErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill in all required fields properly.")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('forgot_email') ?? '';

      final responseMessage = await _authRepository.resetPassword(
        password: _password,
        passwordConfirmation: _confirmPassword,
        email: email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login_screen');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "The password must be 8+ chars and alphanumeric with special char.")),
      );
    }
  }
}

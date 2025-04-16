import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  bool isButtonDisabled = false;
  String _email = '';
  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  late final AuthRepository _authRepository;

  ForgotPasswordViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());
  }

  String get email => _email;

  void setEmail(String value) {
    _email = value;
    if (_email.isEmpty) {
      _fieldErrors['email'] = "Email is required.";
    } else {
      _fieldErrors.remove('email');
    }
    notifyListeners();
  }

  Future<void> submitForgotPassword(BuildContext context) async {
    if (_email.isEmpty) {
      _fieldErrors['email'] = "Email is required.";
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email!')),
      );
      return;
    }

    isButtonDisabled = true;
    notifyListeners();


    Future.delayed(const Duration(seconds: 10), () {
      isButtonDisabled = false;
      notifyListeners();
    });


    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final responseMessage = await _authRepository.forgotPassword(
        email: _email,
        bearerToken: token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage),backgroundColor: Colors.green),
      );


      await prefs.setString('forgot_email', _email);
      debugPrint("Saved email: $_email");


      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamed(context, '/otp_screen');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter valid email address"),backgroundColor: Colors.red),
      );
    }
  }
}

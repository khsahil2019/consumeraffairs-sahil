import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';
import '../views/auth/login_screen.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  late final AuthRepository _authRepository;

  ChangePasswordViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());
  }

  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;

  void setCurrentPassword(String value) {
    _currentPassword = value;
    if (value.isEmpty) {
      _fieldErrors['current_password'] = "Current password is required.";
    } else {
      _fieldErrors.remove('current_password');
    }
    notifyListeners();
  }

  void setNewPassword(String value) {
    _newPassword = value;
    if (value.isEmpty) {
      _fieldErrors['new_password'] = "New password is required.";
    } else {
      _fieldErrors.remove('new_password');
    }
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    if (value.isEmpty) {
      _fieldErrors['new_password_confirmation'] =
          "Confirm password is required.";
    } else {
      _fieldErrors.remove('new_password_confirmation');
    }
    notifyListeners();
  }

  Future<void> submitPassword(BuildContext context) async {
    _fieldErrors = {};
    notifyListeners();

    if (_currentPassword.isEmpty)
      _fieldErrors['current_password'] = "Current password is required.";
    if (_newPassword.isEmpty)
      _fieldErrors['new_password'] = "New password is required.";
    if (_confirmPassword.isEmpty)
      _fieldErrors['new_password_confirmation'] =
          "Confirm password is required.";
    notifyListeners();

    if (_fieldErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      final responseMessage = await _authRepository.changePassword(
        bearerToken: token,
        currentPassword: _currentPassword,
        newPassword: _newPassword,
        confirmPassword: _confirmPassword,
        userId: userId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage), backgroundColor: Colors.green),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login_screen');
      });
    } on ValidationException catch (ve) {
      _fieldErrors = ve.fieldErrors;
      print("Field errors from API: $_fieldErrors");
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

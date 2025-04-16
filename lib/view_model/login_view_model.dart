import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/utils/device_info.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class LoginViewModel extends ChangeNotifier {
  String _username = '';
  String _password = '';
  String _role = '';
  bool _rememberMe = false;
  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  late final AuthRepository _authRepository;

  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  LoginViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());
  }

  String get username => _username;
  String get password => _password;
  String get role => _role;
  bool get rememberMe => _rememberMe;

  void setUsername(String value) {
    _username = value;
    if (value.isEmpty) {
      _fieldErrors['email'] = "Email is required.";
    } else {
      _fieldErrors.remove('email');
    }
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    if (value.isEmpty) {
      _fieldErrors['password'] = "Password is required.";
    } else {
      _fieldErrors.remove('password');
    }
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<void> signIn(BuildContext context) async {
    // Check internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check your connection and try again'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _fieldErrors = {};
    notifyListeners();

    if (_username.isEmpty || _password.isEmpty) {
      if (_username.isEmpty) _fieldErrors['email'] = "Email is required.";
      if (_password.isEmpty) _fieldErrors['password'] = "Password is required.";
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    try {
      final String deviceToken = await _deviceInfoService.getDeviceToken();
      final String deviceType = _deviceInfoService.getDeviceType();

      final loginResponse = await _authRepository.login(
        email: _username,
        password: _password,
        deviceToken: deviceToken,
        deviceType: deviceType,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.data.token);
      await prefs.setString('role', loginResponse.data.role);

      await prefs.setString('email', _username);
      await prefs.setString('role', loginResponse.data.role);
      await prefs.setInt('user_id', loginResponse.data.id);
      await prefs.setBool('is_logged_in', true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(loginResponse.message),
            backgroundColor: Colors.green),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (loginResponse.data.isFirstLogin) {
          Navigator.pushReplacementNamed(context, '/change_pass_screen');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard_screen');
        }
      });
    } on ValidationException catch (ve) {
      _fieldErrors = ve.fieldErrors;
      debugPrint("Field errors from login API: $_fieldErrors");
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login_screen');
  }
}

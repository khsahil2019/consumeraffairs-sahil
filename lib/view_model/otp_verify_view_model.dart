import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class VerifyOtpViewModel extends ChangeNotifier {
  late final AuthRepository _authRepository;


  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes =
  List.generate(6, (index) => FocusNode());


  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  VerifyOtpViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());
  }


  String get otp => otpControllers.map((controller) => controller.text).join();


  Future<void> submitOtp(BuildContext context) async {
    _fieldErrors = {};
    notifyListeners();

    if (otp.length < 6) {
      _fieldErrors['otp'] = "Please enter the full 6-digit code.";
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all 6 digits.")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final email = prefs.getString('email') ?? '';

      final responseMessage = await _authRepository.verifyOtp(
        email: email,
        otp: otp,
        bearerToken: token,
      );


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage), backgroundColor: Colors.green),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamed(context, '/set_pass_screen');
      });

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }


  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}


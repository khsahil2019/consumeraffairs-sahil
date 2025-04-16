import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/auth_model/profile_model.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class ProfileViewModel extends ChangeNotifier {
  // Ye variables profile data ko store karte hain
  String _name = "";
  String _email = "";
  String _password = "********";
  String _image = "";
  bool _isPasswordVisible = false;
  int totalSubmissions = 0;
  int pendingData = 0;
  int overdueData = 0;
  int completedData = 0;
  bool _isOnline = true;

  // Getters - ye variables ko bahar access karne ke liye hain
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get image => _image;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isOnline => _isOnline;

  // Auth repo se data fetch karenge
  late final AuthRepository _authRepository;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ProfileViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());

    _loadProfileFromCache(); // Sabse pehle local data load karte hain (agar available ho)
    _monitorConnectivity(); // Internet connectivity monitor karte hain
    fetchProfile(); // Phir fresh data API se fetch karte hain
  }

  /// API se profile data fetch karke update aur cache mein save karte hain
  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      ProfileModel profile = await _authRepository.getProfile(
        bearerToken: token,
        userId: userId,
      );

      // API se mila data set kar rahe hain
      _name = profile.name;
      _email = profile.email;
      _image = profile.image;
      totalSubmissions = profile.survey_count;
      pendingData = profile.pending_survey;
      overdueData = profile.overdue_survey;
      completedData = profile.completed_survey;

      await _saveProfileToCache(); // Local storage mein save karte hain
      notifyListeners(); // UI ko update karne ke liye notify karte hain
    } catch (e) {
      debugPrint(
          "Error fetching profile: $e"); // Agar error aaye to print kar dete hain
    }
  }

  /// Profile data ko SharedPreferences mein save karte hain
  Future<void> _saveProfileToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _name);
    await prefs.setString('profile_email', _email);
    await prefs.setString('profile_image', _image);
    await prefs.setInt('profile_totalSubmissions', totalSubmissions);
    await prefs.setInt('profile_pendingData', pendingData);
    await prefs.setInt('profile_overdueData', overdueData);
    await prefs.setInt('profile_completedData', completedData);
  }

  /// Local storage (cache) se profile data load karte hain
  Future<void> _loadProfileFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    _name = prefs.getString('profile_name') ?? "";
    _email = prefs.getString('profile_email') ?? "";
    _image = prefs.getString('profile_image') ?? "";
    totalSubmissions = prefs.getInt('profile_totalSubmissions') ?? 0;
    pendingData = prefs.getInt('profile_pendingData') ?? 0;
    overdueData = prefs.getInt('profile_overdueData') ?? 0;
    completedData = prefs.getInt('profile_completedData') ?? 0;

    notifyListeners(); // UI ko update kar dete hain
  }

  /// Internet connectivity ka status check karte hain aur agar offline se online aaye to profile auto refresh karte hain
  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      bool wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;

      // Jaise hi net wapas aata hai, profile auto refresh kar lo
      if (wasOffline && _isOnline) {
        fetchProfile();
      }

      notifyListeners(); // UI update
    });
  }

  /// Password show/hide toggle
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Name update karne ka method
  void updateName(String newName) {
    _name = newName;
    _saveProfileToCache(); // Cache update
    notifyListeners();
  }

  /// Email update karne ka method
  void updateEmail(String newEmail) {
    _email = newEmail;
    _saveProfileToCache(); // Cache update
    notifyListeners();
  }

  /// Password update (sirf locally)
  void updatePassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }

  /// Jab ye ViewModel destroy ho jaye, tab connectivity listener band kar do
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

import 'dart:convert';
import 'package:cunsumer_affairs_app/view_model/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/task_model.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class DashboardViewModel extends ChangeNotifier {
  String userName = "Steve";
  int totalSubmissions = 0;
  int pendingData = 0;
  int overdueData = 0;
  int completedData = 0;

  List<Survey> tasks = []; // Using Survey model as tasks
  bool isOfflineData = false; // Flag to show offline data message

  final AuthRepository _authRepository =
      AuthRepository(apiService: ApiService());

  Future<void> initialize(BuildContext context) async {
    final profileVM = context.read<ProfileViewModel>();
    totalSubmissions = profileVM.totalSubmissions;
    pendingData = profileVM.pendingData;
    overdueData = profileVM.overdueData;
    completedData = profileVM.completedData;

    await loadCachedSurveyList(); // Load local data first
    await fetchSurveyList(); // Try fetching fresh data
  }

  Future<void> fetchSurveyList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        debugPrint("Missing authentication token or user ID");
        return;
      }

      tasks = await _authRepository.fetchSurveyList(
        bearerToken: token,
        userId: userId,
      );

      await saveSurveyListToCache(); // Save fresh data
      isOfflineData = false; // Mark as online data
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching survey list: $e");
    }
  }

  Future<void> loadOfflineSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveyJson = prefs.getString('cached_surveys');

      if (surveyJson != null) {
        final List<dynamic> decodedData = jsonDecode(surveyJson);
        tasks = decodedData.map((e) => Survey.fromJson(e)).toList();
        notifyListeners();

        // ✅ Log all retrieved survey data
        debugPrint("🔹 [Loaded Offline Surveys]: ${jsonEncode(decodedData)}");
      } else {
        debugPrint("⚠️ No cached surveys found.");
      }
    } catch (e) {
      debugPrint("❌ Error loading offline surveys: $e");
    }
  }

  Future<void> saveSurveyListToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveyJson =
          jsonEncode(tasks.map((survey) => survey.toJson()).toList());
      await prefs.setString('cached_surveys', surveyJson);
    } catch (e) {
      debugPrint("Error saving survey list to cache: $e");
    }
  }

  Future<void> loadCachedSurveyList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveyJson = prefs.getString('cached_surveys');

      if (surveyJson != null) {
        final List<dynamic> decodedJson = jsonDecode(surveyJson);
        tasks = decodedJson.map((json) => Survey.fromJson(json)).toList();
        isOfflineData = true; // Mark as offline data
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading survey list from cache: $e");
    }
  }
}

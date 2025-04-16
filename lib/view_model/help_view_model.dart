import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/help_model.dart';
import '../data/repositories/help_repo.dart';

class HelpViewModel extends ChangeNotifier {
  final HelpRepository _repository = HelpRepository();

  bool isLoading = false;
  String errorMessage = '';
  List<HelpFAQ> helpQuestions = [];

  Future<void> fetchHelpQuestions() async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      print("Fetching FAQs with Token: $token");

      helpQuestions = await _repository.getHelpFAQs(bearerToken: token);

      print("Help FAQs Count: ${helpQuestions.length}");

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      print("Error fetching Help FAQs: $errorMessage");
      notifyListeners();
    }
  }
}

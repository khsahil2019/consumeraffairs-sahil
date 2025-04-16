import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/submitted_survey_details_model.dart';
import '../data/repositories/survey_repo.dart';

class SurveyDetailsViewModel extends ChangeNotifier {
  final SurveyRepository _surveyRepository = SurveyRepository();

  bool isLoading = false;
  String errorMessage = '';
  SubmittedSurveyDetails? surveyDetails;
  Future<void> fetchSurveyDetails(int submittedSurveyId, {required bool isSavedSurvey}) async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = isSavedSurvey
          ? await _surveyRepository.getSingleSavedSurveyDetails(
        submittedSurveyId: submittedSurveyId,
        bearerToken: token,
      )
          : await _surveyRepository.getSingleSurveyDetails(
        submittedSurveyId: submittedSurveyId,
        bearerToken: token,
      );

      print("📦 mil gya response: $response");

      if (response != null && response is Map<String, dynamic>) {
        surveyDetails = SubmittedSurveyDetails.fromJson(response);
        print("✅ Loaded Survey: ${surveyDetails!.name} in Zone: ${surveyDetails!.zone.name}");
      } else {
        errorMessage = "Invalid survey response.";
        print("⚠️ Invalid or empty response: $response");
      }
    } catch (e, stackTrace) {
      print("❌ Error occurred: $e");
      print("📍 Stack trace: $stackTrace");
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }





}

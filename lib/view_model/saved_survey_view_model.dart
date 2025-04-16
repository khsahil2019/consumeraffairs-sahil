import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/submitted_survey_model.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class SurveySavedListViewModel extends ChangeNotifier {
  late final AuthRepository _authRepository;

  bool isLoading = false;
  String errorMessage = '';

  List<Map<String, dynamic>> zones = []; // Zones ki list (area wise)
  List<Map<String, dynamic>> categories =
      []; // Categories ki list (jaise fruits, vegetables etc.)

  List<Map<String, dynamic>> marketsForSelectedZone =
      []; // Selected zone ke markets

  String? selectedZoneId; // Select kiya hua zone
  String? selectedMarketId; // Select kiya hua market
  String? selectedCategoryId; // Select kiya hua category

  DateTime? startDate; // Survey search ka start date
  DateTime? endDate; // Survey search ka end date

  TextEditingController searchController =
      TextEditingController(); // Search bar ke liye controller

  List<SubmittedSurvey> savedSurveys = []; // Saved survey data list

  // Constructor: jab class banegi, tab repo initialize hoga
  SurveySavedListViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());
  }

  // Server se zones & categories data load karo
  Future<void> loadFilterData() async {
    try {
      isLoading = true;
      notifyListeners(); // UI ko bolte hain loading dikhao

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final result = await _authRepository.getFiltersMasterData(
        bearerToken: token,
      );

      zones = (result['zones'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      categories = (result['categories'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Default zone/category set kar rahe hain
      if (zones.isNotEmpty) {
        selectedZoneId = zones.first['id'].toString();
        _updateMarketsForZone(
            selectedZoneId!); // Pehle zone ke markets bhi load karo
      }

      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first['id'].toString();
      }

      isLoading = false;
      notifyListeners(); // UI ko update karo
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString(); // Error handle karo
      notifyListeners();
    }
  }

  // Zone change hone pe markets update karo
  void selectZone(String zoneId) {
    selectedZoneId = zoneId;
    _updateMarketsForZone(zoneId);
    selectedMarketId = null; // market reset
    notifyListeners();
  }

  // Sare filters clear kar do
  void clearFilters() {
    selectedZoneId = null;
    selectedMarketId = null;
    selectedCategoryId = null;
    searchController.clear();
    startDate = null;
    endDate = null;
    notifyListeners();
  }

  // Saved surveys list clear karo
  void clearSurveys() {
    savedSurveys = [];
    notifyListeners();
  }

  // Selected zone ke markets filter karo
  void _updateMarketsForZone(String zoneId) {
    final zoneObj = zones.firstWhere(
      (z) => z['id'].toString() == zoneId,
      orElse: () => {},
    );

    // Agar market mil gaya zone ke andar, to usse set karo
    if (zoneObj.isNotEmpty && zoneObj['markets'] != null) {
      final List<dynamic> markets = zoneObj['markets'] as List<dynamic>;
      marketsForSelectedZone =
          markets.map((m) => m as Map<String, dynamic>).toList();
    } else {
      marketsForSelectedZone = []; // warna empty kar do
    }
  }

  void selectMarket(String marketId) {
    selectedMarketId = marketId;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void searchSurveys(String query) {
    // Agar aapko local search lagani ho future mein
    notifyListeners();
  }

  // Server se user ke saved surveys fetch karo
  Future<void> fetchSavedSurveys() async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      final result = await _authRepository.getSavedSurveys(
        bearerToken: token,
        userId: userId,
      );

      savedSurveys = result;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Specific survey ko delete karo
  Future<void> deleteSurvey(int submittedSurveyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      final success = await _authRepository.deleteSubmittedSurvey(
        bearerToken: token,
        userId: userId,
        submittedSurveyId: submittedSurveyId,
      );

      // Agar delete success ho gaya to list se bhi hata do
      if (success) {
        savedSurveys.removeWhere((survey) => survey.id == submittedSurveyId);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString(); // error catch karo
      notifyListeners();
    }
  }
}

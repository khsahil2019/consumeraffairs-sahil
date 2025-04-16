import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/submitted_survey_model.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class SurveyListViewModel extends ChangeNotifier {
  // Auth repository to handle API calls
  late final AuthRepository _authRepository;

  // UI state
  bool isLoading = false;
  String errorMessage = '';

  // Master filter data
  List<Map<String, dynamic>> zones = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> marketsForSelectedZone = [];

  // Selected filter values
  String? selectedZoneId;
  String? selectedMarketId;
  String? selectedCategoryId;

  // Date range filter
  DateTime? startDate;
  DateTime? endDate;

  // Search input
  TextEditingController searchController = TextEditingController();

  // Final list of submitted surveys
  List<SubmittedSurvey> submittedSurveys = [];

  SurveyListViewModel() {
    _authRepository = AuthRepository(apiService: ApiService());
  }

  /// Load zones, markets and categories for filtering surveys
  Future<void> loadFilterData() async {
    try {
      isLoading = true;
      notifyListeners();

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

      // Set default selections
      if (zones.isNotEmpty) {
        selectedZoneId = zones.first['id'].toString();
        _updateMarketsForZone(selectedZoneId!);
      }
      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first['id'].toString();
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Handle zone selection change and update markets list accordingly
  void selectZone(String zoneId) {
    selectedZoneId = zoneId;
    _updateMarketsForZone(zoneId);
    selectedMarketId = null; // Reset market selection
    notifyListeners();
  }

  /// Reset all filters and search inputs
  void clearFilters() {
    selectedZoneId = null;
    selectedMarketId = null;
    selectedCategoryId = null;
    searchController.clear();
    startDate = null;
    endDate = null;
    notifyListeners();
  }

  /// Clear all submitted survey data (used before fetching fresh data)
  void clearSurveys() {
    submittedSurveys = [];
    notifyListeners();
  }

  /// Update markets based on selected zone
  void _updateMarketsForZone(String zoneId) {
    final zoneObj = zones.firstWhere(
      (z) => z['id'].toString() == zoneId,
      orElse: () => {},
    );
    if (zoneObj.isNotEmpty && zoneObj['markets'] != null) {
      final List<dynamic> markets = zoneObj['markets'] as List<dynamic>;
      marketsForSelectedZone =
          markets.map((m) => m as Map<String, dynamic>).toList();
    } else {
      marketsForSelectedZone = [];
    }
  }

  /// Set selected market
  void selectMarket(String marketId) {
    selectedMarketId = marketId;
    notifyListeners();
  }

  /// Set selected category
  void selectCategory(String categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// Set selected start date
  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  /// Set selected end date
  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  /// Placeholder for searching surveys (can filter `submittedSurveys` later)
  void searchSurveys(String query) {
    // Implement actual search filter logic if needed
    notifyListeners();
  }

  /// Fetch submitted surveys from backend
  Future<void> fetchSubmittedSurveys() async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      final result = await _authRepository.getSubmittedSurveys(
        bearerToken: token,
        userId: userId,
      );

      submittedSurveys = result;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Delete a submitted survey and update the list
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

      if (success) {
        submittedSurveys
            .removeWhere((survey) => survey.id == submittedSurveyId);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}

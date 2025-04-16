import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cunsumer_affairs_app/data/models/survey_commodity_model.dart';
import 'package:cunsumer_affairs_app/data/models/survey_detail_model.dart';
import 'package:cunsumer_affairs_app/data/repositories/auth_repositories.dart';
import 'package:cunsumer_affairs_app/data/services/api_services.dart';
import 'package:cunsumer_affairs_app/view_model/productSurvey/offline/offline_product_survey_detail_view_model.dart';
import 'package:cunsumer_affairs_app/view_model/productSurvey/online/online_product_survey_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductSurveyDetailViewModel extends ChangeNotifier {
  late final AuthRepository _authRepository;
  late final OnlineProductSurveyDetailViewModel onlineViewModel;
  late final OfflineProductSurveyDetailViewModel offlineViewModel;

  String errorMessage = "";
  bool isLoading = false;
  bool _isSaving = false;
  bool _isSubmitting = false;
  String _saveButtonText = "Save";
  String _submitButtonText = "Submit";

  bool get isSaving => _isSaving;
  bool get isSubmitting => _isSubmitting;
  String get saveButtonText => _saveButtonText;
  String get submitButtonText => _submitButtonText;

  int? fetchedSurveyId;
  int? fetchedZoneId;
  int? fetchedUnitId;
  int? fetchedBrandId;
  String zoneName = "";

  List<GenericItem> markets = [];
  List<Category> categories = [];
  GenericItem? selectedMarket;
  Category? selectedCategory;
  List<Commodity> availableCommodities = [];

  List<ValidatedCommodity> validatedCommodities = [];
  List<Map<String, dynamic>> validationApiResponse = [];

  bool isValidationSuccess = false;
  Map<int, TextEditingController> priceControllers = {};
  Map<int, TextEditingController> expiryControllers = {};
  Map<int, TextEditingController> availabilityControllers = {};

  Map<int, String> priceMap = {};
  Map<int, String> availabilityMap = {};
  Map<int, FocusNode> expiryFocusNodes = {};
  Map<int, bool> isEditable = {};
  Map<int, String> expiryDateMap = {};
  Map<int, bool> isSubmitted = {};
  Map<int, bool> isSaved = {};
  Map<int, String> selectedImages = {};
  Map<int, int> commodityToSubmittedSurveyId = {};

  Map<int, bool> isPriceTouched = {};
  bool isOfflineSubmitted = false;

  BuildContext? _context;
  Timer? _animationTimer;

  ProductSurveyDetailViewModel(this._context) {
    _authRepository = AuthRepository(apiService: ApiService());
    onlineViewModel = OnlineProductSurveyDetailViewModel(this, _authRepository);
    offlineViewModel = OfflineProductSurveyDetailViewModel(this);
    _loadSubmittedStatus();
    _setupNetworkListener();
  }

  void _startButtonAnimation(String type) {
    int dotCount = 1;
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      dotCount = (dotCount % 3) + 1;
      if (type == "save") {
        _saveButtonText = "Saving${"." * dotCount}";
      } else {
        _submitButtonText = "Submitting${"." * dotCount}";
      }
      notifyListeners();
    });
  }

  void _stopButtonAnimation(String type) {
    _animationTimer?.cancel();
    if (type == "save") {
      _saveButtonText = "Save";
    } else {
      _submitButtonText = "Submit";
    }
    notifyListeners();
  }

  void setIsSaving(bool value) {
    _isSaving = value;
    if (value) {
      _startButtonAnimation("save");
    } else {
      _stopButtonAnimation("save");
    }
  }

  void setIsSubmitting(bool value) {
    _isSubmitting = value;
    if (value) {
      _startButtonAnimation("submit");
    } else {
      _stopButtonAnimation("submit");
    }
  }

  int get totalCategories => markets.length * categories.length;
  int get submittedCategories {
    if (fetchedZoneId == null) return 0;
    final submittedCategoryIds = validatedCommodities
        .where((commodity) =>
            commodity.isSubmit == true && commodity.zoneId == fetchedZoneId)
        .map((commodity) => commodity.commodity?.categoryId)
        .where((id) => id != null)
        .toSet();
    debugPrint(
        "Submitted Categories for Zone $fetchedZoneId: ${submittedCategoryIds.length}");
    return submittedCategoryIds.length;
  }

  int get remainingCategories => totalCategories - submittedCategories;

  Future<void> _loadSubmittedStatus() async {
    await offlineViewModel.loadSubmittedStatus();
    isOfflineSubmitted = await _checkOfflineSubmission();
    notifyListeners();
  }

  Future<bool> _checkOfflineSubmission() async {
    final prefs = await SharedPreferences.getInstance();
    final surveyId = fetchedSurveyId?.toString() ?? '';
    return prefs.containsKey('offline_submission_$surveyId') ||
        prefs.getBool('submitted_online_$surveyId') == true;
  }

  Future<void> _markAsSubmittedOnline() async {
    final prefs = await SharedPreferences.getInstance();
    final surveyId = fetchedSurveyId?.toString() ?? '';
    await prefs.setBool('submitted_online_$surveyId', true);
    isOfflineSubmitted = false;
    notifyListeners();
  }

  void setSelectedMarket(GenericItem? item) {
    selectedMarket = item;
    notifyListeners();
  }

  void initializeControllers(int commodityId) {
    expiryFocusNodes[commodityId] ??= FocusNode();

    if (!priceControllers.containsKey(commodityId)) {
      final value = priceMap[commodityId] ?? "";
      priceControllers[commodityId] = TextEditingController(text: value);
    }

    if (!availabilityControllers.containsKey(commodityId)) {
      final value = availabilityMap[commodityId] ?? "moderate";
      availabilityControllers[commodityId] = TextEditingController(text: value);
    }

    if (!expiryControllers.containsKey(commodityId)) {
      final value = expiryDateMap[commodityId] ?? "";
      expiryControllers[commodityId] = TextEditingController(text: value);
    }
  }

  void cancelSurvey(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> fetchSurveyDetail(int surveyId) async {
    final isOnline = await isInternetAvailable();
    if (isOnline) {
      await onlineViewModel.fetchSurveyDetail(surveyId);
    } else {
      await offlineViewModel.fetchSurveyDetail(surveyId);
    }
    selectedMarket = null;
    selectedCategory = null;
    availableCommodities = [];
    commodityToSubmittedSurveyId.clear();
    await _loadSubmittedStatus();
  }

  Future<void> fetchValidatedCommodities(
      int zoneId, int surveyId, int marketId, int categoryId) async {
    final isOnline = await isInternetAvailable();
    if (isOnline) {
      await onlineViewModel.fetchValidatedCommodities(
          zoneId, surveyId, marketId, categoryId);
    } else {
      await offlineViewModel.fetchValidatedCommodities(
          zoneId, surveyId, marketId, categoryId);
    }
    commodityToSubmittedSurveyId.clear();
  }

  void setSelectedCategory(Category? item) async {
    selectedCategory = item;
    availableCommodities = item?.commodities ?? [];

    if (selectedCategory != null &&
        selectedMarket != null &&
        fetchedZoneId != null &&
        fetchedSurveyId != null) {
      await fetchValidatedCommodities(fetchedZoneId!, fetchedSurveyId!,
          selectedMarket!.id, selectedCategory!.id);
    }
    notifyListeners();
  }

  Future<void> saveSurvey(BuildContext context) async {
    try {
      setIsSaving(true);
      final isOnline = await isInternetAvailable();
      if (isOnline) {
        await onlineViewModel.saveSurvey(context);
      } else {
        await offlineViewModel.saveSurvey(context);
      }
    } catch (e) {
      debugPrint("❌ Save Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Save Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setIsSaving(false);
    }
  }

  Future<void> submitSurvey(BuildContext context) async {
    if (isOfflineSubmitted || isSubmitting) return;
    try {
      setIsSubmitting(true);
      final isOnline = await isInternetAvailable();
      if (isOnline) {
        await onlineViewModel.submitSurvey(context);
        await _markAsSubmittedOnline();
      } else {
        await offlineViewModel.submitSurvey(context);
        isOfflineSubmitted = true;
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Submit Error: $e");
      debugPrint("📌 Stack Trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submit Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  Future<void> syncOfflineData() async {
    if (!isOfflineSubmitted || _context == null) return;
    try {
      setIsSubmitting(true);
      await onlineViewModel.syncOfflineData(_context!);
      await _markAsSubmittedOnline();
    } finally {
      setIsSubmitting(false);
    }
  }

  void updateAvailability(int commodityId, String availability) {
    offlineViewModel.updateAvailability(commodityId, availability);
  }

  void updateExpiryDate(int commodityId, String date) {
    offlineViewModel.updateExpiryDate(commodityId, date);
  }

  void updateImage(int commodityId, String imagePath) {
    offlineViewModel.updateImage(commodityId, imagePath);
  }

  void updatePrice(int commodityId, String price) {
    priceMap[commodityId] = price;
    final controller = priceControllers[commodityId];
    if (controller != null) {
      controller.text = price;
    }
    isPriceTouched[commodityId] = true;
    notifyListeners();
  }

  bool get isAnyCommoditySubmitted {
    for (var commodity in validatedCommodities) {
      if (commodity.isSubmit) {
        return true;
      }
    }
    return false;
  }

  bool get isSubmitButtonDisabled => isOfflineSubmitted || isSubmitting;

  Future<bool> isInternetAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _setupNetworkListener() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none && isOfflineSubmitted) {
        await syncOfflineData();
        if (_context != null) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            SnackBar(
              content: Text("Offline submissions synced successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
}

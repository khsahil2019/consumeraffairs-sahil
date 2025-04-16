import 'dart:async';
import 'dart:developer';
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
    final keys = prefs.getKeys();
    return keys.any((key) => key.startsWith('offline_submission_$surveyId')) ||
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
    selectedCategory = null;
    validatedCommodities.clear();
    log("Cleared validatedCommodities on market change");
    notifyListeners();
  }

  void initializeControllers(int commodityId) {
    expiryFocusNodes[commodityId] ??= FocusNode();

    if (!priceControllers.containsKey(commodityId)) {
      priceControllers[commodityId] =
          TextEditingController(text: priceMap[commodityId] ?? "");
    }

    if (!availabilityControllers.containsKey(commodityId)) {
      availabilityControllers[commodityId] = TextEditingController(
          text: availabilityMap[commodityId]?.toLowerCase() ?? "moderate");
    }

    if (!expiryControllers.containsKey(commodityId)) {
      expiryControllers[commodityId] =
          TextEditingController(text: expiryDateMap[commodityId] ?? "");
    }
  }

  void cancelSurvey(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> fetchSurveyDetail(int surveyId) async {
    isLoading = true;
    notifyListeners();
    try {
      final isOnline = await isInternetAvailable();
      log("Fetching survey detail, isOnline: $isOnline, surveyId: $surveyId");
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
    } catch (e) {
      log("Error fetching survey detail: $e");
      errorMessage = "Failed to load survey details";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchValidatedCommodities(
      int zoneId, int surveyId, int marketId, int categoryId) async {
    try {
      final isOnline = await isInternetAvailable();
      log("Fetching validated commodities, isOnline: $isOnline, "
          "zoneId: $zoneId, surveyId: $surveyId, marketId: $marketId, categoryId: $categoryId");
      if (isOnline) {
        await onlineViewModel.fetchValidatedCommodities(
            zoneId, surveyId, marketId, categoryId);
      } else {
        await offlineViewModel.fetchValidatedCommodities(
            zoneId, surveyId, marketId, categoryId);
      }
      commodityToSubmittedSurveyId.clear();
      log("Validated commodities loaded: ${validatedCommodities.length}, "
          "isValidationSuccess: $isValidationSuccess");
      for (var c in validatedCommodities) {
        log("Commodity id: ${c.id}, isSubmit: ${c.isSubmit}, "
            "name: ${c.commodity?.name ?? 'N/A'}");
      }
    } catch (e) {
      log("Error fetching validated commodities: $e");
      errorMessage = "Failed to load commodities";
      validatedCommodities.clear();
    } finally {
      notifyListeners();
    }
  }

  void setSelectedCategory(Category? item) async {
    selectedCategory = item;
    availableCommodities = item?.commodities ?? [];
    log("Selected category: ${item?.name}, availableCommodities: ${availableCommodities.length}");

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
      log("Saving survey, isOnline: $isOnline, commodities: ${validatedCommodities.length}");
      if (isOnline) {
        await onlineViewModel.saveSurvey(context);
      } else {
        await offlineViewModel.saveSurvey(context);
      }
      if (_context != null && context.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text("Survey saved successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      log("❌ Save Error: $e");
      if (_context != null && context.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text("Save Failed: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setIsSaving(false);
    }
  }

  Future<void> submitSurvey(BuildContext context) async {
    if (isSubmitting) return;
    try {
      setIsSubmitting(true);
      final isOnline = await isInternetAvailable();
      log("Submitting survey, isOnline: $isOnline, commodities: ${validatedCommodities.length}");
      if (isOnline) {
        await onlineViewModel.submitSurvey(context);
        await _markAsSubmittedOnline();
      } else {
        await offlineViewModel.submitSurvey(context);
        isOfflineSubmitted = await _checkOfflineSubmission();
      }
      if (_context != null && context.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text("Survey submitted successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      log("❌ Submit Error: $e");
      log("📌 Stack Trace: $stackTrace");
      if (_context != null && context.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text("Submit Failed: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setIsSubmitting(false);
    }
  }

  Future<void> syncOfflineData() async {
    if (!isOfflineSubmitted || _context == null) return;
    try {
      setIsSubmitting(true);
      log("Syncing offline data");
      await onlineViewModel.syncOfflineData(_context!);
      await _markAsSubmittedOnline();
      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text("Offline submissions synced successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      log("❌ Sync Error: $e");
    } finally {
      setIsSubmitting(false);
    }
  }

  void updateAvailability(int commodityId, String availability) {
    if (isEditable[commodityId] == false) return;
    availabilityMap[commodityId] = availability;
    if (availabilityControllers.containsKey(commodityId)) {
      availabilityControllers[commodityId]?.text = availability;
    } else {
      availabilityControllers[commodityId] =
          TextEditingController(text: availability);
    }
    offlineViewModel.updateAvailability(commodityId, availability);
    notifyListeners();
  }

  void updateExpiryDate(int commodityId, String date) {
    if (isEditable[commodityId] == false) return;
    expiryDateMap[commodityId] = date;
    if (expiryControllers.containsKey(commodityId)) {
      expiryControllers[commodityId]?.text = date;
    } else {
      expiryControllers[commodityId] = TextEditingController(text: date);
    }
    offlineViewModel.updateExpiryDate(commodityId, date);
    notifyListeners();
  }

  void updateImage(int commodityId, String imagePath) {
    if (isEditable[commodityId] == false) return;
    selectedImages[commodityId] = imagePath;
    offlineViewModel.updateImage(commodityId, imagePath);
    notifyListeners();
  }

  void updatePrice(int commodityId, String price) {
    if (isEditable[commodityId] == false) return;
    priceMap[commodityId] = price;
    if (priceControllers.containsKey(commodityId)) {
      priceControllers[commodityId]?.text = price;
    } else {
      priceControllers[commodityId] = TextEditingController(text: price);
    }
    offlineViewModel.updatePrice(commodityId, price);
    notifyListeners();
  }

  bool get isAnyCommoditySubmitted {
    return validatedCommodities.any((commodity) => commodity.isSubmit);
  }

  bool get isSubmitButtonDisabled =>
      isSubmitting ||
      validatedCommodities.isEmpty ||
      validatedCommodities.every((c) => c.isSubmit);

  Future<bool> isInternetAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _setupNetworkListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none && isOfflineSubmitted) {
        await syncOfflineData();
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    expiryFocusNodes.values.forEach((node) => node.dispose());
    priceControllers.values.forEach((controller) => controller.dispose());
    availabilityControllers.values
        .forEach((controller) => controller.dispose());
    expiryControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

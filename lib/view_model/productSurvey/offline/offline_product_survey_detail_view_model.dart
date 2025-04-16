import 'dart:convert';
import 'dart:developer';
import 'package:cunsumer_affairs_app/data/models/survey_commodity_model.dart';
import 'package:cunsumer_affairs_app/data/models/survey_detail_model.dart';
import 'package:cunsumer_affairs_app/view_model/productSurvey/product_survey_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineProductSurveyDetailViewModel {
  final ProductSurveyDetailViewModel _viewModel;

  OfflineProductSurveyDetailViewModel(this._viewModel);

  Future<void> loadSubmittedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final surveyId = _viewModel.fetchedSurveyId ?? 0;
    final storedData = prefs.getString('validated_commodities_$surveyId');
    if (storedData != null) {
      final decodedData = jsonDecode(storedData) as List;
      _viewModel.validatedCommodities =
          decodedData.map((c) => ValidatedCommodity.fromJson(c)).toList();
      debugPrint(
          "Loaded submitted status from local for Survey $surveyId: ${_viewModel.validatedCommodities.map((c) => c.isSubmit)}");
    } else {
      _viewModel.validatedCommodities = [];
      debugPrint("No submitted status found for Survey $surveyId");
    }
    _viewModel.notifyListeners();
  }

  Future<void> fetchSurveyDetail(int surveyId) async {
    try {
      _viewModel.isLoading = true;
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('survey_detail_$surveyId');
      if (storedData != null) {
        final decodedData = jsonDecode(storedData);
        _viewModel.fetchedSurveyId = decodedData['id'];
        _viewModel.fetchedZoneId = decodedData['zone']['id'];
        _viewModel.zoneName = decodedData['zone']['name'];
        _viewModel.markets = (decodedData['markets'] as List)
            .map((m) => GenericItem.fromJson(m))
            .toList();
        _viewModel.categories = (decodedData['categories'] as List)
            .map((c) => Category.fromJson(c))
            .toList();
        debugPrint("Successfully loaded survey detail for ID: $surveyId");
      } else {
        _viewModel.errorMessage =
            "No offline data available for survey ID: $surveyId";
        debugPrint(_viewModel.errorMessage);
      }

      _viewModel.isLoading = false;
      _viewModel.notifyListeners();
    } catch (e) {
      _viewModel.isLoading = false;
      _viewModel.errorMessage = "Error fetching offline survey detail: $e";
      debugPrint("❌ Error fetching offline survey detail: $e");
      _viewModel.notifyListeners();
    }
  }

  Future<void> fetchValidatedCommodities(
      int zoneId, int surveyId, int marketId, int categoryId) async {
    try {
      _viewModel.isLoading = true;
      _viewModel.notifyListeners();

      _viewModel.validatedCommodities.clear();
      _viewModel.priceMap.clear();
      _viewModel.availabilityMap.clear();
      _viewModel.expiryDateMap.clear();
      _viewModel.selectedImages.clear();
      _viewModel.isSaved.clear();
      _viewModel.isSubmitted.clear();
      _viewModel.priceControllers.clear();
      _viewModel.expiryControllers.clear();
      _viewModel.availabilityControllers.clear();

      final prefs = await SharedPreferences.getInstance();
      final key = 'validated_commodities_${surveyId}_$marketId$categoryId';
      final storedCommodities = prefs.getString(key);

      if (storedCommodities != null) {
        final decodedData = jsonDecode(storedCommodities) as List;
        _viewModel.validatedCommodities =
            decodedData.map((c) => ValidatedCommodity.fromJson(c)).toList();
        _viewModel.isValidationSuccess = true;

        for (var commodity in _viewModel.validatedCommodities) {
          int commodityId = commodity.id;
          commodity.isEditable = !commodity.isSubmit;
          _viewModel.isEditable[commodityId] = commodity.isEditable;
          _viewModel.isSubmitted[commodityId] = commodity.isSubmit;
          _viewModel.isSaved[commodityId] = commodity.isSave;

          _viewModel.priceMap[commodityId] = commodity.amount ?? "";
          _viewModel.availabilityMap[commodityId] =
              commodity.availability ?? "moderate";
          _viewModel.expiryDateMap[commodityId] =
              commodity.commodityExpiryDate ?? ""; // Ensure this is set
          _viewModel.selectedImages[commodityId] =
              commodity.commodityImageUrl ?? "";

          // Initialize or update the controller
          _viewModel.expiryControllers[commodityId] = TextEditingController(
              text: _viewModel.expiryDateMap[commodityId] ?? "");
        }
        debugPrint(
            "✅ Loaded offline validated commodities for $surveyId/$marketId/$categoryId");
      } else {
        _viewModel.isValidationSuccess = false;
        debugPrint(
            "⚠️ No offline validated commodities found for $surveyId/$marketId/$categoryId");
      }

      await loadLocalCommodityUpdates(surveyId, marketId, categoryId);

      _viewModel.isLoading = false;
      _viewModel.notifyListeners();
    } catch (e) {
      _viewModel.isValidationSuccess = false;
      _viewModel.errorMessage = "Error fetching validated commodities: $e";
      _viewModel.isLoading = false;
      debugPrint("❌ Error in Offline Validation: $e");
      _viewModel.notifyListeners();
    }
  }

  Future<void> _saveLocalCommodityUpdate(
      int surveyId, int marketId, int categoryId, int commodityId) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        'commodity_update_${surveyId}_${marketId}_${categoryId}_$commodityId';
    final data = {
      'commodity_id': commodityId,
      'price': _viewModel.priceMap[commodityId] ?? "",
      'availability': _viewModel.availabilityMap[commodityId] ?? "moderate",
      'expiry_date': _viewModel.expiryDateMap[commodityId] ?? "",
      'image': _viewModel.selectedImages[commodityId] ?? "",
      'is_submitted': _viewModel.isSubmitted[commodityId] ?? false,
      'is_saved': _viewModel.isSaved[commodityId] ?? false,
    };
    await prefs.setString(key, jsonEncode(data));
    debugPrint("✅ Saved local commodity update for $key: $data");
  }

  Future<void> loadLocalCommodityUpdates(
      int surveyId, int marketId, int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    for (var commodity in _viewModel.validatedCommodities) {
      final commodityId = commodity.id;
      final key =
          'commodity_update_${surveyId}_${marketId}_${categoryId}_$commodityId';
      final storedData = prefs.getString(key);

      if (storedData != null) {
        final decodedData = jsonDecode(storedData);
        _viewModel.priceMap[commodityId] = decodedData['price'] ?? "";
        _viewModel.availabilityMap[commodityId] =
            decodedData['availability'] ?? "moderate";
        _viewModel.expiryDateMap[commodityId] =
            decodedData['expiry_date'] ?? ""; // Ensure this is updated
        _viewModel.selectedImages[commodityId] = decodedData['image'] ?? "";
        _viewModel.isSubmitted[commodityId] =
            decodedData['is_submitted'] ?? false;
        _viewModel.isSaved[commodityId] = decodedData['is_saved'] ?? false;

        // Update the controller with the latest expiry date
        if (_viewModel.expiryControllers.containsKey(commodityId)) {
          _viewModel.expiryControllers[commodityId]!.text =
              _viewModel.expiryDateMap[commodityId] ?? "";
        } else {
          _viewModel.expiryControllers[commodityId] = TextEditingController(
              text: _viewModel.expiryDateMap[commodityId] ?? "");
        }
        debugPrint("✅ Loaded local commodity update for $key: $decodedData");
      }
    }
    _viewModel.notifyListeners();
  }

  Future<void> saveSurvey(BuildContext context) async {
    try {
      //  _viewModel.isLoading = true;//
      _viewModel.setIsSaving(true);
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (_viewModel.selectedMarket == null ||
          _viewModel.selectedCategory == null) {
        throw "Please select both Market and Category before saving.";
      }

      final surveyId = _viewModel.fetchedSurveyId ?? 0;
      final zoneId = _viewModel.fetchedZoneId ?? 0;
      final marketId = _viewModel.selectedMarket!.id;
      final categoryId = _viewModel.selectedCategory!.id;

      List<Map<String, dynamic>> commodityUpdates = [];

      for (var commodity in _viewModel.validatedCommodities) {
        final commodityId = commodity.id;
        _viewModel.initializeControllers(commodityId);

        final price = _viewModel.priceControllers[commodityId]?.text.trim() ??
            _viewModel.priceMap[commodityId] ??
            "";
        final availability =
            _viewModel.availabilityControllers[commodityId]?.text.trim() ??
                _viewModel.availabilityMap[commodityId] ??
                "moderate";
        final expiryDate =
            _viewModel.expiryControllers[commodityId]?.text.trim() ??
                _viewModel.expiryDateMap[commodityId] ??
                "";
        final image = _viewModel.selectedImages[commodityId] ?? "";

        // Update local maps
        _viewModel.priceMap[commodityId] = price;
        _viewModel.availabilityMap[commodityId] = availability;
        _viewModel.expiryDateMap[commodityId] = expiryDate;
        _viewModel.selectedImages[commodityId] = image;
        _viewModel.isSaved[commodityId] = true;

        commodityUpdates.add({
          'commodity_id': commodityId,
          'price': price,
          'availability': availability,
          'expiry_date': expiryDate,
          'image': image,
          'unit_id': commodity.unit?.id ?? 0,
          'brand_id': commodity.brand?.id ?? 0,
        });

        // Save individual update
        await _saveLocalCommodityUpdate(
            surveyId, marketId, categoryId, commodityId);
      }

      if (commodityUpdates.isEmpty) {
        throw "No commodities to save.";
      }

      final offlineData = {
        'user_id': userId,
        'zone_id': zoneId,
        'survey_id': surveyId,
        'market_id': marketId,
        'category_id': categoryId,
        'submitted_by': userId,
        'commodities': commodityUpdates,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final key = 'offline_survey_data_${surveyId}_${marketId}_${categoryId}';
      await prefs.setString(key, jsonEncode(offlineData));
      debugPrint("✅ Saved offline survey data to $key: $offlineData");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Saved offline. Will sync when online."),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      debugPrint("❌ Error in Offline Save: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.yellow.shade100,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // _viewModel.isLoading = false;
      _viewModel.setIsSaving(false);
      _viewModel.notifyListeners();
    }
  }

  void updateAvailability(int commodityId, String availability) {
    availability = availability.trim().toLowerCase();
    _viewModel.availabilityMap[commodityId] = availability;
    _viewModel.availabilityControllers[commodityId] =
        TextEditingController(text: availability);
    if (_viewModel.fetchedSurveyId != null &&
        _viewModel.selectedMarket != null &&
        _viewModel.selectedCategory != null) {
      _saveLocalCommodityUpdate(
          _viewModel.fetchedSurveyId!,
          _viewModel.selectedMarket!.id,
          _viewModel.selectedCategory!.id,
          commodityId);
    }
    _viewModel.notifyListeners();
  }

  Future<void> submitSurvey(BuildContext context) async {
    try {
      // _viewModel.isLoading = true;
      _viewModel.setIsSubmitting(true);
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (_viewModel.selectedMarket == null ||
          _viewModel.selectedCategory == null) {
        throw "Please select both Market and Category properly.";
      }

      if (_viewModel.fetchedZoneId == null ||
          _viewModel.fetchedSurveyId == null) {
        throw "Zone or Survey ID not found. Please validate or save the survey first.";
      }

      List<int> commodityIds = [];
      List<int> submittedSurveyIds = [];
      List<String> amounts = [];
      List<String> availabilities = [];
      List<int> unitIds = [];
      List<int> brandIds = [];
      List<String> commodityExpiryDates = [];
      List<String> commodityImages = [];

      Map<int, int> savedCommodityToSurveyMap =
          _viewModel.commodityToSubmittedSurveyId;
      Set<int> processedCommodityIds = {};

      _viewModel.fetchedBrandId = prefs.getInt('fetchedBrandId');
      _viewModel.fetchedUnitId = prefs.getInt('fetchedUnitId');

      for (var entry in savedCommodityToSurveyMap.entries) {
        int commodityId = entry.key;
        int submittedSurveyId = entry.value;

        ValidatedCommodity? validated;
        try {
          validated = _viewModel.validatedCommodities
              .firstWhere((c) => c.commodity!.id == commodityId);
        } catch (_) {
          validated = null;
        }

        String controllerPrice =
            _viewModel.priceControllers[commodityId]?.text.trim() ?? "";
        String fallbackPrice = _viewModel.priceMap[commodityId]?.trim() ?? "";
        String validPrice = _viewModel.isPriceTouched[commodityId] == true &&
                controllerPrice.isNotEmpty
            ? controllerPrice
            : (validated?.amount ?? fallbackPrice);

        String controllerAvailability = _viewModel
                .availabilityControllers[commodityId]?.text
                .trim()
                .toLowerCase() ??
            "";
        String validAvailability = controllerAvailability.isNotEmpty
            ? controllerAvailability
            : (validated?.availability?.toLowerCase() ??
                _viewModel.availabilityMap[commodityId]?.toLowerCase() ??
                "low");

        String expiryDate = _viewModel.expiryDateMap[commodityId] ??
            validated?.commodityExpiryDate ??
            "";
        String image = _viewModel.selectedImages[commodityId] ?? "";

        commodityIds.add(commodityId);
        submittedSurveyIds.add(submittedSurveyId);
        amounts.add(validPrice);
        availabilities.add(validAvailability);
        unitIds.add(_viewModel.fetchedUnitId ?? validated?.unit?.id ?? 0);
        brandIds.add(_viewModel.fetchedBrandId ?? validated?.brand?.id ?? 0);
        commodityExpiryDates.add(expiryDate);
        commodityImages.add(image);

        processedCommodityIds.add(commodityId);
      }

      for (var commodity in _viewModel.validatedCommodities) {
        int commodityId = commodity.commodity!.id;
        if (processedCommodityIds.contains(commodityId)) continue;

        int submittedSurveyId =
            _viewModel.commodityToSubmittedSurveyId[commodityId] ??
                commodity.id;

        String price = _viewModel.priceControllers[commodityId]?.text.trim() ??
            _viewModel.priceMap[commodityId] ??
            commodity.amount ??
            "";
        String availability = _viewModel
                .availabilityControllers[commodityId]?.text
                .trim()
                .toLowerCase() ??
            _viewModel.availabilityMap[commodityId] ??
            commodity.availability ??
            "low";
        String expiryDate = _viewModel.expiryDateMap[commodityId] ??
            commodity.commodityExpiryDate ??
            "";
        String image = _viewModel.selectedImages[commodityId] ?? "";

        int unitId = commodity.unit?.id ?? 0;
        int brandId = commodity.brand?.id ?? 0;

        String validPrice = (price.isNotEmpty && double.tryParse(price) != null)
            ? price
            : (commodity.amount ?? "0");

        commodityIds.add(commodityId);
        submittedSurveyIds.add(submittedSurveyId);
        amounts.add(validPrice);
        availabilities.add(availability);
        unitIds.add(unitId);
        brandIds.add(brandId);
        commodityExpiryDates.add(expiryDate);
        commodityImages.add(image);
      }

      // Save offline submission data
      final offlineData = {
        'token': prefs.getString('token') ?? '',
        'userId': userId,
        'zoneId': _viewModel.fetchedZoneId,
        'surveyId': _viewModel.fetchedSurveyId,
        'marketId': _viewModel.selectedMarket!.id,
        'categoryId': _viewModel.selectedCategory!.id,
        'submittedBy': userId,
        'commodityIds': commodityIds,
        'submittedSurveyIds': submittedSurveyIds,
        'amounts': amounts,
        'availabilities': availabilities,
        'unitIds': unitIds,
        'brandIds': brandIds,
        'commodityExpiryDates': commodityExpiryDates,
        'commodityImages': commodityImages,
        'timestamp': DateTime.now().toIso8601String(),
        'isSubmittedOffline': true,
      };

      final key =
          'offline_submission_${_viewModel.fetchedSurveyId}_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(key, jsonEncode(offlineData));

      // Update local state
      for (var commodity in _viewModel.validatedCommodities) {
        _viewModel.isSubmitted[commodity.id] = true;
        _viewModel.isEditable[commodity.id] = false;
      }
      _viewModel.isOfflineSubmitted =
          true; // Mark as submitted offline in view model

      debugPrint("✅ Survey submitted offline and saved for later sync: $key");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Survey submitted offline. It will sync when online."),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      debugPrint("❌ Error in Offline Submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Offline Submit Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // _viewModel.isLoading = false;
      _viewModel.setIsSubmitting(false);
      _viewModel.notifyListeners();
    }
  }

  void updateExpiryDate(int commodityId, String date) {
    date = date.trim();
    _viewModel.expiryDateMap[commodityId] = date;
    _viewModel.expiryControllers[commodityId] =
        TextEditingController(text: date); // Ensure controller is updated
    if (_viewModel.fetchedSurveyId != null &&
        _viewModel.selectedMarket != null &&
        _viewModel.selectedCategory != null) {
      _saveLocalCommodityUpdate(
          _viewModel.fetchedSurveyId!,
          _viewModel.selectedMarket!.id,
          _viewModel.selectedCategory!.id,
          commodityId);
    }
    _viewModel.notifyListeners();
  }

  void updateImage(int commodityId, String imagePath) {
    _viewModel.selectedImages[commodityId] = imagePath;
    if (_viewModel.fetchedSurveyId != null &&
        _viewModel.selectedMarket != null &&
        _viewModel.selectedCategory != null) {
      _saveLocalCommodityUpdate(
          _viewModel.fetchedSurveyId!,
          _viewModel.selectedMarket!.id,
          _viewModel.selectedCategory!.id,
          commodityId);
    }
    _viewModel.notifyListeners();
  }

  void updatePrice(int commodityId, String price) {
    price = price.trim();
    _viewModel.priceMap[commodityId] = price;
    _viewModel.priceControllers[commodityId] =
        TextEditingController(text: price);
    _viewModel.isPriceTouched[commodityId] = true;
    if (_viewModel.fetchedSurveyId != null &&
        _viewModel.selectedMarket != null &&
        _viewModel.selectedCategory != null) {
      _saveLocalCommodityUpdate(
          _viewModel.fetchedSurveyId!,
          _viewModel.selectedMarket!.id,
          _viewModel.selectedCategory!.id,
          commodityId);
    }
    debugPrint("📦 priceMap[$commodityId] = $price");
    _viewModel.notifyListeners();
  }
}

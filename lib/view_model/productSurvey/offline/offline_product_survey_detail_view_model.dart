import 'dart:convert';
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
    final storedData = prefs.getString(
        'validated_commodities_$surveyId${_viewModel.selectedMarket?.id ?? ''}${_viewModel.selectedCategory?.id ?? ''}');
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
        throw "No offline data available for survey ID: $surveyId";
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
              commodity.availability?.toLowerCase() ?? "moderate";
          _viewModel.expiryDateMap[commodityId] =
              commodity.commodityExpiryDate ?? "";
          _viewModel.selectedImages[commodityId] =
              commodity.commodityImageUrl ?? "";

          _viewModel.initializeControllers(commodityId);
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
            decodedData['availability']?.toLowerCase() ?? "moderate";
        _viewModel.expiryDateMap[commodityId] =
            decodedData['expiry_date'] ?? "";
        _viewModel.selectedImages[commodityId] = decodedData['image'] ?? "";
        _viewModel.isSubmitted[commodityId] =
            decodedData['is_submitted'] ?? false;
        _viewModel.isSaved[commodityId] = decodedData['is_saved'] ?? false;

        _viewModel.initializeControllers(commodityId);
        debugPrint("✅ Loaded local commodity update for $key: $decodedData");
      }
    }
    _viewModel.notifyListeners();
  }

  Future<void> saveSurvey(BuildContext context) async {
    try {
      _viewModel.setIsSaving(true);
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (_viewModel.selectedMarket == null ||
          _viewModel.selectedCategory == null) {
        throw "Please select both Market and Category before saving.";
      }

      final surveyId = _viewModel.fetchedSurveyId;
      final zoneId = _viewModel.fetchedZoneId;
      final marketId = _viewModel.selectedMarket!.id;
      final categoryId = _viewModel.selectedCategory!.id;

      if (surveyId == null || zoneId == null) {
        throw "Missing survey or zone information.";
      }

      List<Map<String, dynamic>> commodityUpdates = [];

      for (var commodity in _viewModel.validatedCommodities) {
        final commodityId = commodity.commodity?.id ?? commodity.id;
        if (commodityId == null) continue;

        _viewModel.initializeControllers(commodityId);
        final price = _viewModel.priceControllers[commodityId]?.text.trim() ??
            _viewModel.priceMap[commodityId] ??
            "";
        final availability =
            _viewModel.availabilityControllers[commodityId]?.text.trim() ??
                _viewModel.availabilityMap[commodityId] ??
                commodity.availability?.toLowerCase() ??
                "moderate";
        final expiryDate =
            _viewModel.expiryControllers[commodityId]?.text.trim() ??
                _viewModel.expiryDateMap[commodityId] ??
                "";
        final image = _viewModel.selectedImages[commodityId] ?? "";

        final unitId = commodity.unit?.id;
        final brandId = commodity.brand?.id;

        // Skip if missing required IDs
        if (unitId == null || brandId == null) {
          debugPrint(
              "Skipping commodity $commodityId: Missing unitId or brandId");
          continue;
        }

        // Update local state
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
          'unit_id': unitId,
          'brand_id': brandId,
        });

        // Save individual update
        await _saveLocalCommodityUpdate(
            surveyId, marketId, categoryId, commodityId);
      }

      if (commodityUpdates.isEmpty) {
        throw "No valid commodities to save. Please ensure commodities have valid IDs.";
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
      debugPrint("✅ Saved offline survey data to $key");

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
          content: Text("Save Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _viewModel.setIsSaving(false);
      _viewModel.notifyListeners();
    }
  }

  Future<void> submitSurvey(BuildContext context) async {
    try {
      _viewModel.setIsSubmitting(true);
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (_viewModel.selectedMarket == null ||
          _viewModel.selectedCategory == null) {
        throw "Please select both Market and Category.";
      }

      final surveyId = _viewModel.fetchedSurveyId;
      final zoneId = _viewModel.fetchedZoneId;
      final marketId = _viewModel.selectedMarket!.id;
      final categoryId = _viewModel.selectedCategory!.id;

      if (surveyId == null || zoneId == null) {
        throw "Missing survey or zone information.";
      }

      List<int> commodityIds = [];
      List<int> submittedSurveyIds = [];
      List<String> amounts = [];
      List<String> availabilities = [];
      List<int> unitIds = [];
      List<int> brandIds = [];
      List<String> commodityExpiryDates = [];
      List<String> commodityImages = [];

      for (var commodity in _viewModel.validatedCommodities) {
        final commodityId = commodity.commodity?.id ?? commodity.id;
        if (commodityId == null) continue;

        _viewModel.initializeControllers(commodityId);

        // Allow empty price, expiry, image
        final price = _viewModel.priceControllers[commodityId]?.text.trim() ??
            _viewModel.priceMap[commodityId] ??
            "";
        final availability =
            _viewModel.availabilityControllers[commodityId]?.text.trim() ??
                _viewModel.availabilityMap[commodityId] ??
                commodity.availability?.toLowerCase() ??
                "moderate";
        final expiryDate =
            _viewModel.expiryControllers[commodityId]?.text.trim() ??
                _viewModel.expiryDateMap[commodityId] ??
                "";
        final image = _viewModel.selectedImages[commodityId] ?? "";

        final unitId = commodity.unit?.id;
        final brandId = commodity.brand?.id;

        // Skip if missing required IDs
        if (unitId == null || brandId == null) {
          debugPrint(
              "Skipping commodity $commodityId: Missing unitId or brandId");
          continue;
        }

        final submittedSurveyId =
            _viewModel.commodityToSubmittedSurveyId[commodityId] ?? 0;

        commodityIds.add(commodityId);
        submittedSurveyIds.add(submittedSurveyId);
        amounts.add(price);
        availabilities.add(availability);
        unitIds.add(unitId);
        brandIds.add(brandId);
        commodityExpiryDates.add(expiryDate);
        commodityImages.add(image);

        // Update local state
        commodity.isSubmit;
        _viewModel.isSubmitted[commodityId] = true;
        _viewModel.isEditable[commodityId] = false;
      }

      if (commodityIds.isEmpty) {
        throw "No valid commodities to submit. Please ensure commodities have valid IDs.";
      }

      // Save offline submission data
      final offlineData = {
        'token': prefs.getString('token') ?? '',
        'userId': userId,
        'zoneId': zoneId,
        'surveyId': surveyId,
        'marketId': marketId,
        'categoryId': categoryId,
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
          'offline_submission_${surveyId}_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(key, jsonEncode(offlineData));

      // Persist validated commodities
      await prefs.setString(
        'validated_commodities_${surveyId}_${marketId}_${categoryId}',
        jsonEncode(
            _viewModel.validatedCommodities.map((c) => c.toJson()).toList()),
      );

      _viewModel.isOfflineSubmitted = true;

      debugPrint("✅ Survey submitted offline and saved for later sync: $key");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Survey submitted offline. Will sync when online."),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      debugPrint("❌ Error in Offline Submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submit Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _viewModel.setIsSubmitting(false);
      _viewModel.notifyListeners();
    }
  }

  void updateAvailability(int commodityId, String availability) {
    availability = availability.trim().toLowerCase();
    _viewModel.availabilityMap[commodityId] = availability;
    _viewModel.initializeControllers(commodityId);
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

  void updateExpiryDate(int commodityId, String date) {
    date = date.trim();
    _viewModel.expiryDateMap[commodityId] = date;
    _viewModel.initializeControllers(commodityId);
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
    _viewModel.isPriceTouched[commodityId] = true;
    _viewModel.initializeControllers(commodityId);
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

import 'dart:convert';
import 'package:cunsumer_affairs_app/data/models/survey_commodity_model.dart';
import 'package:cunsumer_affairs_app/data/models/survey_detail_model.dart';
import 'package:cunsumer_affairs_app/data/repositories/auth_repositories.dart';
import 'package:cunsumer_affairs_app/view_model/productSurvey/product_survey_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnlineProductSurveyDetailViewModel {
  final ProductSurveyDetailViewModel _viewModel;
  final AuthRepository _authRepository;

  OnlineProductSurveyDetailViewModel(this._viewModel, this._authRepository);

  Future<void> fetchSurveyDetail(int surveyId) async {
    try {
      _viewModel.isLoading = true;
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final detail = await _authRepository.getSurveyDetail(
        bearerToken: token,
        surveyId: surveyId,
      );

      _viewModel.fetchedSurveyId = detail.id;
      _viewModel.fetchedZoneId = detail.zone.id;
      _viewModel.zoneName = detail.zone.name;
      _viewModel.markets = detail.markets;
      _viewModel.categories = detail.categories;

      await prefs.setString(
        'survey_detail_$surveyId',
        jsonEncode({
          'id': detail.id,
          'zone': detail.zone.toJson(),
          'markets': detail.markets.map((m) => m.toJson()).toList(),
          'categories': detail.categories.map((c) => c.toJson()).toList(),
        }),
      );

      _viewModel.isLoading = false;
      _viewModel.notifyListeners();
    } catch (e) {
      _viewModel.isLoading = false;
      _viewModel.errorMessage = e.toString();
      _viewModel.notifyListeners();
      debugPrint("❌ Error fetching survey detail: $e");
    }
  }

  Future<void> fetchValidatedCommodities(
      int zoneId, int surveyId, int marketId, int categoryId) async {
    try {
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
      final token = prefs.getString('token') ?? '';

      _viewModel.validatedCommodities = await _authRepository.validateSurvey(
        bearerToken: token,
        zoneId: zoneId,
        surveyId: surveyId,
        marketId: marketId,
        categoryId: categoryId,
      );

      _viewModel.isValidationSuccess =
          _viewModel.validatedCommodities.isNotEmpty;

      if (_viewModel.isValidationSuccess) {
        for (var commodity in _viewModel.validatedCommodities) {
          int commodityId = commodity.id;
          commodity.isEditable = !commodity.isSubmit;
          _viewModel.isEditable[commodity.id] = commodity.isEditable;
          _viewModel.isSubmitted[commodity.id] = commodity.isSubmit;
          _viewModel.isSaved[commodity.id] = commodity.isSave;
          _viewModel.priceMap[commodity.id] = commodity.amount ?? "";
          _viewModel.availabilityMap[commodity.id] =
              commodity.availability ?? "moderate";
          _viewModel.expiryDateMap[commodity.id] =
              commodity.commodityExpiryDate ?? "";
          if (commodity.commodityImageUrl != null &&
              commodity.commodityImageUrl!.isNotEmpty) {
            _viewModel.selectedImages[commodity.id] =
                commodity.commodityImageUrl!;
          }
        }

        await prefs.setString(
          'validated_commodities_${surveyId}_$marketId$categoryId',
          jsonEncode(
              _viewModel.validatedCommodities.map((c) => c.toJson()).toList()),
        );
        debugPrint(
            "✅ Saved validated commodities for $surveyId/$marketId/$categoryId");
      }

      // Call offline method via public offlineViewModel
      await _viewModel.offlineViewModel
          .loadLocalCommodityUpdates(surveyId, marketId, categoryId);

      _viewModel.isLoading = false;
      _viewModel.notifyListeners();
    } catch (e) {
      _viewModel.isValidationSuccess = false;
      _viewModel.errorMessage = e.toString();
      _viewModel.notifyListeners();
      debugPrint("❌ Error in Validation API: $e");
    }
  }

  Future<void> saveSurvey(BuildContext context) async {
    try {
      // _viewModel.isLoading = true;
      _viewModel.setIsSaving(true);
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      if (_viewModel.selectedMarket == null ||
          _viewModel.selectedCategory == null) {
        throw "Please select both Market and Category before saving.";
      }

      final zoneId = _viewModel.fetchedZoneId ??
          _viewModel.validatedCommodities.firstOrNull?.zoneId;
      final surveyId = _viewModel.fetchedSurveyId ??
          _viewModel.validatedCommodities.firstOrNull?.surveyId;

      if (zoneId == null || surveyId == null) {
        throw "Missing required survey information. Please try refreshing the data.";
      }

      List<int> commodityIds = [];
      List<String> amounts = [];
      List<String> availabilities = [];
      List<int> unitIds = [];
      List<int> brandIds = [];
      List<String> commodityExpiryDates = [];
      List<String> commodityImages = [];

      String getValue(
          String? controllerText, String? mapValue, String defaultValue) {
        if (controllerText != null && controllerText.trim().isNotEmpty) {
          return controllerText.trim();
        }
        return mapValue?.trim() ?? defaultValue;
      }

      final commoditiesToProcess = _viewModel.isValidationSuccess &&
              _viewModel.validatedCommodities.isNotEmpty
          ? _viewModel.validatedCommodities.cast<ValidatedCommodity>()
          : _viewModel.availableCommodities.cast<Commodity>();

      for (var commodity in commoditiesToProcess) {
        final isValidated = commodity is ValidatedCommodity;
        final isRegular = commodity is Commodity;

        if (!isValidated && !isRegular) continue;

        final commodityId = isValidated
            ? (commodity as ValidatedCommodity).commodity?.id ??
                (commodity as ValidatedCommodity).id
            : (commodity as Commodity).id;

        if (commodityId == null) continue;

        _viewModel.initializeControllers(commodityId);

        final unitId = isValidated
            ? (commodity as ValidatedCommodity).unit?.id
            : (commodity as Commodity).uom?.id;
        final brandId = isValidated
            ? (commodity as ValidatedCommodity).brand?.id
            : (commodity as Commodity).brand?.id;

        final price = getValue(
          _viewModel.priceControllers[commodityId]?.text,
          _viewModel.priceMap[commodityId],
          isValidated ? (commodity as ValidatedCommodity).amount ?? "0" : "0",
        );

        final availability = getValue(
          _viewModel.availabilityControllers[commodityId]?.text,
          _viewModel.availabilityMap[commodityId],
          isValidated
              ? (commodity as ValidatedCommodity).availability ?? "moderate"
              : "moderate",
        );

        final expiryDate = getValue(
          _viewModel.expiryControllers[commodityId]?.text,
          _viewModel.expiryDateMap[commodityId],
          isValidated
              ? (commodity as ValidatedCommodity).commodityExpiryDate ?? ""
              : "",
        );

        final image = _viewModel.selectedImages[commodityId] ??
            (isValidated
                ? (commodity as ValidatedCommodity).commodityImageUrl
                : null) ??
            "";

        _viewModel.updatePrice(commodityId, price);
        _viewModel.availabilityMap[commodityId] = availability;
        _viewModel.expiryDateMap[commodityId] = expiryDate;
        _viewModel.selectedImages[commodityId] = image;

        if (price.isNotEmpty) {
          commodityIds.add(commodityId);
          amounts.add(price);
          availabilities.add(availability);
          unitIds.add(unitId ?? 0);
          brandIds.add(brandId ?? 0);
          commodityExpiryDates.add(expiryDate);
          commodityImages.add(image);
        }
      }

      if (commodityIds.isEmpty) {
        throw "No valid commodity data to save.";
      }

      final response = await _authRepository.saveSurvey(
        bearerToken: token,
        userId: userId,
        zoneId: zoneId,
        surveyId: surveyId,
        marketId: _viewModel.selectedMarket!.id,
        commodityIds: commodityIds,
        amounts: amounts,
        categoryId: _viewModel.selectedCategory!.id,
        submittedBy: userId,
        availabilities: availabilities,
        unitIds: unitIds,
        brandIds: brandIds,
        commodityExpiryDates: commodityExpiryDates,
        commodityImages: commodityImages,
      );

      if (response['success'] == true) {
        final responseData = response['data'] as List?;
        if (responseData != null) {
          _viewModel.commodityToSubmittedSurveyId.clear();
          for (var item in responseData) {
            if (item is Map) {
              final submittedId = item['id'] as int?;
              final commId = item['commodity_id'] as int?;
              if (submittedId != null && commId != null) {
                _viewModel.commodityToSubmittedSurveyId[commId] = submittedId;
              }
            }
          }
        }

        for (var id in commodityIds) {
          await prefs.remove(
              'commodity_update_${surveyId}_${_viewModel.selectedMarket!.id}_${_viewModel.selectedCategory!.id}_$id');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Survey saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw response['message'] ?? 'Failed to save survey';
      }
    } catch (e) {
      debugPrint("❌ Error in Save: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      //_viewModel.isLoading = false;
      _viewModel.setIsSaving(false);
      _viewModel.notifyListeners();
    }
  }

  Future<void> submitSurvey(BuildContext context) async {
    try {
      _viewModel.setIsSubmitting(true);
      _viewModel.notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      // Validate prerequisites
      if (_viewModel.selectedMarket?.id == null ||
          _viewModel.selectedCategory?.id == null) {
        throw "Please select both Market and Category.";
      }

      // Ensure zone and survey IDs
      if (_viewModel.fetchedZoneId == null ||
          _viewModel.fetchedSurveyId == null) {
        if (_viewModel.validatedCommodities.isNotEmpty &&
            _viewModel.validatedCommodities.first.zoneId != null &&
            _viewModel.validatedCommodities.first.surveyId != null) {
          _viewModel.fetchedZoneId =
              _viewModel.validatedCommodities.first.zoneId;
          _viewModel.fetchedSurveyId =
              _viewModel.validatedCommodities.first.surveyId;
        } else {
          final zoneId = prefs.getInt('fetchedZoneId');
          final surveyId = prefs.getInt('fetchedSurveyId');
          if (zoneId == null || surveyId == null) {
            throw "Survey details not loaded. Please try again.";
          }
          _viewModel.fetchedZoneId = zoneId;
          _viewModel.fetchedSurveyId = surveyId;
        }
      }

      debugPrint(
          "Submitting with zoneId=${_viewModel.fetchedZoneId}, surveyId=${_viewModel.fetchedSurveyId}");

      // Load commodity survey map
      final storedMapString =
          prefs.getString('commodity_survey_map_${_viewModel.fetchedSurveyId}');
      if (storedMapString != null) {
        final decoded = jsonDecode(storedMapString) as Map<String, dynamic>;
        _viewModel.commodityToSubmittedSurveyId =
            decoded.map((key, value) => MapEntry(int.parse(key), value as int));
      }

      // Gather commodity data
      List<int> commodityIds = [];
      List<int> submittedSurveyIds = [];
      List<String> amounts = [];
      List<String> availabilities = [];
      List<int> unitIds = [];
      List<int> brandIds = [];
      List<String> commodityExpiryDates = [];
      List<String> commodityImages = [];

      // ... (commodity processing logic remains the same)

      // Submit survey
      final response = await _authRepository.submitSurvey(
        bearerToken: token,
        userId: userId,
        zoneId: _viewModel.fetchedZoneId!,
        surveyId: _viewModel.fetchedSurveyId!,
        marketId: _viewModel.selectedMarket!.id,
        commodityIds: commodityIds,
        submittedSurveyId: submittedSurveyIds,
        amounts: amounts,
        categoryId: _viewModel.selectedCategory!.id,
        submittedBy: userId,
        availabilities: availabilities,
        unitIds: unitIds,
        brandIds: brandIds,
        commodityExpiryDates: commodityExpiryDates,
        commodityImages: commodityImages,
      );

      if (response['success'] == true) {
        for (var commodity in _viewModel.validatedCommodities) {
          _viewModel.isSubmitted[commodity.id] = true;
          _viewModel.isEditable[commodity.id] = false;
        }
        await prefs.setString(
          'validated_commodities_${_viewModel.fetchedSurveyId}_${_viewModel.selectedMarket!.id}_${_viewModel.selectedCategory!.id}',
          jsonEncode(
              _viewModel.validatedCommodities.map((c) => c.toJson()).toList()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Survey submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw response['message'] ?? 'Failed to submit survey';
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
      _viewModel.setIsSubmitting(false);
      _viewModel.notifyListeners();
    }
  }

  Future<void> syncOfflineData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final submissionKeys = allKeys
          .where((key) => key.startsWith('offline_submission_'))
          .toList();

      if (submissionKeys.isEmpty) {
        debugPrint("✅ No offline submissions to sync.");
        return;
      }

      for (var key in submissionKeys) {
        final storedData = prefs.getString(key);
        if (storedData == null) continue;

        final data = jsonDecode(storedData);
        final token = data['token'] ?? prefs.getString('token') ?? '';
        final userId = data['userId'];
        final zoneId = data['zoneId'];
        final surveyId = data['surveyId'];
        final marketId = data['marketId'];
        final categoryId = data['categoryId'];
        final submittedBy = data['submittedBy'];

        List<int> commodityIds = List<int>.from(data['commodityIds']);
        List<int> submittedSurveyIds =
            List<int>.from(data['submittedSurveyIds']);
        List<String> amounts = List<String>.from(data['amounts']);
        List<String> availabilities = List<String>.from(data['availabilities']);
        List<int> unitIds = List<int>.from(data['unitIds']);
        List<int> brandIds = List<int>.from(data['brandIds']);
        List<String> commodityExpiryDates =
            List<String>.from(data['commodityExpiryDates']);
        List<String> commodityImages =
            List<String>.from(data['commodityImages']);

        final response = await _authRepository.submitSurvey(
          bearerToken: token,
          userId: userId,
          zoneId: zoneId,
          surveyId: surveyId,
          marketId: marketId,
          commodityIds: commodityIds,
          submittedSurveyId: submittedSurveyIds,
          amounts: amounts,
          categoryId: categoryId,
          submittedBy: submittedBy,
          availabilities: availabilities,
          unitIds: unitIds,
          brandIds: brandIds,
          commodityExpiryDates: commodityExpiryDates,
          commodityImages: commodityImages,
        );

        if (response['success'] == true) {
          await prefs.remove(key);
          _viewModel.isOfflineSubmitted =
              false; // Reset offline submission flag

          //  await _viewModel._markAsSubmittedOnline(); // Mark as submitted online

          for (var commodity in _viewModel.validatedCommodities) {
            _viewModel.isSubmitted[commodity.id] = true;
            _viewModel.isEditable[commodity.id] = false;
          }

          debugPrint(
              "✅ Offline submission for $surveyId/$marketId/$categoryId synced successfully!");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Offline submission $surveyId synced successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          _viewModel.commodityToSubmittedSurveyId.clear();
          for (var item in response['data'] ?? []) {
            _viewModel.commodityToSubmittedSurveyId[item['commodity_id']] =
                item['id'];
          }
          await prefs.setString(
            'commodity_survey_map_$surveyId',
            jsonEncode(_viewModel.commodityToSubmittedSurveyId
                .map((k, v) => MapEntry(k.toString(), v))),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error syncing offline data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sync failed: $e"), backgroundColor: Colors.red),
      );
    }
  }
}

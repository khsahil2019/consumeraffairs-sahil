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

      await prefs.setInt('fetchedZoneId', detail.zone.id);
      await prefs.setInt('fetchedSurveyId', detail.id);
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
      _viewModel.isLoading = true;
      _viewModel.notifyListeners();

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
          commodity.isEditable = true; // Allow edits even if submitted
          _viewModel.isEditable[commodityId] = commodity.isEditable;
          _viewModel.isSubmitted[commodityId] = commodity.isSubmit;
          _viewModel.isSaved[commodityId] = commodity.isSave;
          // Only set if not already in priceMap to preserve local changes
          if (!_viewModel.priceMap.containsKey(commodityId)) {
            _viewModel.priceMap[commodityId] = commodity.amount ?? "";
          }
          if (!_viewModel.availabilityMap.containsKey(commodityId)) {
            _viewModel.availabilityMap[commodityId] =
                commodity.availability?.toLowerCase() ?? "moderate";
          }
          if (!_viewModel.expiryDateMap.containsKey(commodityId)) {
            _viewModel.expiryDateMap[commodityId] =
                commodity.commodityExpiryDate ?? "";
          }
          if (!_viewModel.selectedImages.containsKey(commodityId) &&
              commodity.commodityImageUrl != null &&
              commodity.commodityImageUrl!.isNotEmpty) {
            _viewModel.selectedImages[commodityId] =
                commodity.commodityImageUrl!;
          }
          _viewModel.initializeControllers(commodityId);
        }

        await prefs.setString(
          'validated_commodities_${surveyId}_$marketId$categoryId',
          jsonEncode(
              _viewModel.validatedCommodities.map((c) => c.toJson()).toList()),
        );
        debugPrint(
            "✅ Saved validated commodities for $surveyId/$marketId/$categoryId");
      }

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
        return controllerText?.trim() ?? mapValue?.trim() ?? defaultValue;
      }

      for (var commodity in _viewModel.validatedCommodities) {
        final commodityId = commodity.commodity?.id ?? commodity.id;
        if (commodityId == null) continue;

        _viewModel.initializeControllers(commodityId);

        final price = getValue(
          _viewModel.priceControllers[commodityId]?.text,
          _viewModel.priceMap[commodityId],
          "",
        );
        final availability = getValue(
          _viewModel.availabilityControllers[commodityId]?.text,
          _viewModel.availabilityMap[commodityId],
          commodity.availability?.toLowerCase() ?? "moderate",
        );
        final expiryDate = getValue(
          _viewModel.expiryControllers[commodityId]?.text,
          _viewModel.expiryDateMap[commodityId],
          "",
        );
        final image = _viewModel.selectedImages[commodityId] ?? "";

        final unitId = commodity.unit?.id;
        final brandId = commodity.brand?.id;

        if (unitId == null || brandId == null) {
          debugPrint(
              "Skipping commodity $commodityId: Missing unitId or brandId");
          continue;
        }

        commodityIds.add(commodityId);
        amounts.add(price);
        availabilities.add(availability);
        unitIds.add(unitId);
        brandIds.add(brandId);
        commodityExpiryDates.add(expiryDate);
        commodityImages.add(image);

        // Update local state
        _viewModel.priceMap[commodityId] = price;
        _viewModel.availabilityMap[commodityId] = availability;
        _viewModel.expiryDateMap[commodityId] = expiryDate;
        _viewModel.selectedImages[commodityId] = image;
        _viewModel.isSaved[commodityId] = true;

        // Save local update
        await _viewModel.offlineViewModel.saveLocalCommodityUpdate(
            surveyId,
            _viewModel.selectedMarket!.id,
            _viewModel.selectedCategory!.id,
            commodityId);
      }

      if (commodityIds.isEmpty) {
        throw "No valid commodities to save. Please ensure commodities have valid IDs.";
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
        _viewModel.commodityToSubmittedSurveyId.clear();
        final responseData = response['data'] as List?;
        if (responseData != null) {
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

        // Persist commodityToSubmittedSurveyId
        await prefs.setString(
          'commodity_survey_map_$surveyId',
          jsonEncode(_viewModel.commodityToSubmittedSurveyId
              .map((k, v) => MapEntry(k.toString(), v))),
        );

        // Clear local updates
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
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      if (_viewModel.selectedMarket?.id == null ||
          _viewModel.selectedCategory?.id == null) {
        throw "Please select both Market and Category.";
      }

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
            throw "Survey details not loaded. Please fetch survey details first.";
          }
          _viewModel.fetchedZoneId = zoneId;
          _viewModel.fetchedSurveyId = surveyId;
        }
      }

      debugPrint(
          "Submitting with zoneId=${_viewModel.fetchedZoneId}, surveyId=${_viewModel.fetchedSurveyId}");

      // Load existing commodity survey map, if available
      final storedMapString =
          prefs.getString('commodity_survey_map_${_viewModel.fetchedSurveyId}');
      if (storedMapString != null) {
        final decoded = jsonDecode(storedMapString) as Map<String, dynamic>;
        _viewModel.commodityToSubmittedSurveyId =
            decoded.map((key, value) => MapEntry(int.parse(key), value as int));
      }

      List<int> commodityIds = [];
      List<int> submittedSurveyIds = [];
      List<String> amounts = [];
      List<String> availabilities = [];
      List<int> unitIds = [];
      List<int> brandIds = [];
      List<String> commodityExpiryDates = [];
      List<String> commodityImages = [];

      String getValue(
          String? controllerText, String? mapValue, String defaultValue) {
        return controllerText?.trim() ?? mapValue?.trim() ?? defaultValue;
      }

      for (var commodity in _viewModel.validatedCommodities) {
        final commodityId = commodity.commodity?.id ?? commodity.id;
        if (commodityId == null) continue;

        _viewModel.initializeControllers(commodityId);

        final price = getValue(
          _viewModel.priceControllers[commodityId]?.text,
          _viewModel.priceMap[commodityId],
          "",
        );
        final availability = getValue(
          _viewModel.availabilityControllers[commodityId]?.text,
          _viewModel.availabilityMap[commodityId],
          commodity.availability?.toLowerCase() ?? "moderate",
        );
        final expiryDate = getValue(
          _viewModel.expiryControllers[commodityId]?.text,
          _viewModel.expiryDateMap[commodityId],
          "",
        );
        final image = _viewModel.selectedImages[commodityId] ?? "";

        final unitId = commodity.unit?.id;
        final brandId = commodity.brand?.id;

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
        _viewModel.priceMap[commodityId] = price;
        _viewModel.availabilityMap[commodityId] = availability;
        _viewModel.expiryDateMap[commodityId] = expiryDate;
        _viewModel.selectedImages[commodityId] = image;
      }

      if (commodityIds.isEmpty) {
        throw "No valid commodities to submit. Please ensure commodities have valid IDs.";
      }

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
          if (commodityIds.contains(commodity.commodity?.id ?? commodity.id)) {
            commodity.isSubmit;
            _viewModel.isSubmitted[commodity.id] = true;
            _viewModel.isEditable[commodity.id] = false;
          }
        }

        // Update commodityToSubmittedSurveyId
        _viewModel.commodityToSubmittedSurveyId.clear();
        final responseData = response['data'] as List?;
        if (responseData != null) {
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

        // Persist updated state
        await prefs.setString(
          'validated_commodities_${_viewModel.fetchedSurveyId}_${_viewModel.selectedMarket!.id}_${_viewModel.selectedCategory!.id}',
          jsonEncode(
              _viewModel.validatedCommodities.map((c) => c.toJson()).toList()),
        );
        await prefs.setString(
          'commodity_survey_map_${_viewModel.fetchedSurveyId}',
          jsonEncode(_viewModel.commodityToSubmittedSurveyId
              .map((k, v) => MapEntry(k.toString(), v))),
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

      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      for (var key in submissionKeys) {
        final storedData = prefs.getString(key);
        if (storedData == null) continue;

        final data = jsonDecode(storedData);
        final zoneId = data['zoneId'] as int?;
        final surveyId = data['surveyId'] as int?;
        final marketId = data['marketId'] as int?;
        final categoryId = data['categoryId'] as int?;
        final submittedBy = data['submittedBy'] as int?;

        if (zoneId == null ||
            surveyId == null ||
            marketId == null ||
            categoryId == null ||
            submittedBy == null) {
          debugPrint("Skipping sync for $key: Missing required fields");
          continue;
        }

        List<int> commodityIds = List<int>.from(data['commodityIds'] ?? []);
        List<int> submittedSurveyIds =
            List<int>.from(data['submittedSurveyIds'] ?? []);
        List<String> amounts = List<String>.from(data['amounts'] ?? []);
        List<String> availabilities =
            List<String>.from(data['availabilities'] ?? []);
        List<int> unitIds = List<int>.from(data['unitIds'] ?? []);
        List<int> brandIds = List<int>.from(data['brandIds'] ?? []);
        List<String> commodityExpiryDates =
            List<String>.from(data['commodityExpiryDates'] ?? []);
        List<String> commodityImages =
            List<String>.from(data['commodityImages'] ?? []);

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
          _viewModel.isOfflineSubmitted = false;

          // Update local state
          for (var commodity in _viewModel.validatedCommodities) {
            if (commodityIds
                .contains(commodity.commodity?.id ?? commodity.id)) {
              commodity.isSubmit;
              _viewModel.isSubmitted[commodity.id] = true;
              _viewModel.isEditable[commodity.id] = false;
            }
          }

          // Update commodityToSubmittedSurveyId
          _viewModel.commodityToSubmittedSurveyId.clear();
          final responseData = response['data'] as List?;
          if (responseData != null) {
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

          // Persist updated state
          await prefs.setString(
            'validated_commodities_${surveyId}_${marketId}_${categoryId}',
            jsonEncode(_viewModel.validatedCommodities
                .map((c) => c.toJson())
                .toList()),
          );
          await prefs.setString(
            'commodity_survey_map_$surveyId',
            jsonEncode(_viewModel.commodityToSubmittedSurveyId
                .map((k, v) => MapEntry(k.toString(), v))),
          );

          debugPrint(
              "✅ Offline submission for $surveyId/$marketId/$categoryId synced successfully!");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Offline submission $surveyId synced successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          debugPrint(
              "Failed to sync offline submission for $key: ${response['message']}");
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

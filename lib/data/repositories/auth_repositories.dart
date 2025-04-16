import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/approved_commodity_model.dart';
import '../models/approved_list_model.dart';
import '../models/auth_model/login_model.dart';
import '../models/auth_model/profile_model.dart';
import '../models/submitted_survey_model.dart';
import '../models/survey_commodity_model.dart';
import '../models/survey_detail_model.dart';
import '../models/task_model.dart';
import '../services/api_services.dart';
import 'package:http_parser/http_parser.dart';

class ValidationException implements Exception {
  final Map<String, String> fieldErrors;
  final String message;

  ValidationException(this.fieldErrors, {this.message = 'Validation error'});
}

class AuthRepository {
  final ApiService apiService;
  AuthRepository({required this.apiService});

  Future<LoginResponse> login({
    required String email,
    required String password,
    required String deviceToken,
    required String deviceType,
  }) async {
    final response = await apiService.post('api/login', {
      'email': email,
      'password': password,
      'device_token': deviceToken,
      'device_type': deviceType,
    });

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 422) {
      if (jsonResponse['success'] == true) {
        return LoginResponse.fromJson(jsonResponse);
      } else {
        if (jsonResponse['data'] != null) {
          final Map<String, String> fieldErrors = {};
          (jsonResponse['data'] as Map<String, dynamic>)
              .forEach((field, errors) {
            if (errors is List && errors.isNotEmpty) {
              fieldErrors[field] = errors.first.toString();
            }
          });
          debugPrint("Parsed field errors: $fieldErrors");
          throw ValidationException(fieldErrors,
              message: jsonResponse['message'] ?? 'Validation error');
        } else {
          throw (jsonResponse['message'] ??
              'Failed to login. Please try again later');
        }
      }
    } else {
      final errorMessage =
          jsonResponse.containsKey('message') && jsonResponse['message'] != null
              ? jsonResponse['message']
              : 'Please try again later';

      debugPrint("Error: $errorMessage");
      throw (errorMessage);
    }
  }

  Future<String> forgotPassword({
    required String email,
    required String bearerToken,
  }) async {
    final endpoint = 'api/forgot-password';

    final body = {
      'email': email,
    };

    print("ForgotPassword Request Body: $body");

    final response = await apiService.postFormData(
      endpoint,
      body,
      bearerToken: bearerToken,
    );

    final jsonResponse = jsonDecode(response.body);
    print("resjason$jsonResponse");

    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        return jsonResponse['message'] ?? 'Success';
      } else {
        throw (jsonResponse['message'] ?? 'Unknown error');
      }
    } else {
      final errorMessage =
          jsonResponse.containsKey('message') && jsonResponse['message'] != null
              ? jsonResponse['message']
              : 'Please try again later';

      debugPrint("Forgot Password Error: $errorMessage");
      throw (errorMessage);
    }
  }

  Future<String> changePassword(
      {required String bearerToken,
      required String currentPassword,
      required String newPassword,
      required String confirmPassword,
      required int userId}) async {
    const endpoint = 'api/change-password';
    final body = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
      'id': userId.toString(),
    };

    debugPrint("Sending changePassword request with body: $body");

    final response = await apiService.postFormData(
      endpoint,
      body,
      bearerToken: bearerToken,
    );

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    // Parse JSON response
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    debugPrint("Decoded JSON response: $jsonResponse");

    if (response.statusCode == 200 || response.statusCode == 422) {
      if (jsonResponse['success'] == true) {
        return jsonResponse['message'] ?? 'Password changed successfully';
      } else {
        if (jsonResponse['data'] != null) {
          final Map<String, String> fieldErrors = {};
          (jsonResponse['data'] as Map<String, dynamic>)
              .forEach((field, errors) {
            if (errors is List && errors.isNotEmpty) {
              fieldErrors[field] = errors.first.toString();
            }
          });
          debugPrint("Parsed field errors: $fieldErrors");
          throw ValidationException(fieldErrors,
              message: jsonResponse['message'] ?? 'Validation error');
        } else {
          throw (jsonResponse['message'] ?? 'Failed to change password');
        }
      }
    } else {
      final errorMessage =
          jsonResponse.containsKey('message') && jsonResponse['message'] != null
              ? jsonResponse['message']
              : 'Please try again later';

      debugPrint("Change Password Error: $errorMessage");
      throw (errorMessage);
    }
  }

  Future<String> verifyOtp({
    required String email,
    required String otp,
    required String bearerToken,
  }) async {
    const endpoint = 'api/verify-otp';
    final body = {
      'email': email,
      'otp': otp,
    };

    debugPrint("VerifyOtp Request Body: $body");

    final response = await apiService.postFormData(
      endpoint,
      body,
      bearerToken: bearerToken,
    );

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    // Parse JSON response
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    debugPrint("Decoded JSON response: $jsonResponse");

    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true) {
        return jsonResponse['message'] ?? 'OTP verified successfully';
      } else {
        if (jsonResponse['data'] != null) {
          final Map<String, String> fieldErrors = {};
          (jsonResponse['data'] as Map<String, dynamic>)
              .forEach((field, errors) {
            if (errors is List && errors.isNotEmpty) {
              fieldErrors[field] = errors.first.toString();
            }
          });
          debugPrint("Parsed field errors: $fieldErrors");
          throw ValidationException(fieldErrors,
              message: jsonResponse['message'] ?? 'Validation error');
        } else {
          throw (jsonResponse['message'] ?? 'Failed to verify OTP');
        }
      }
    } else {
      final errorMessage =
          jsonResponse.containsKey('message') && jsonResponse['message'] != null
              ? jsonResponse['message']
              : 'Please try again later';

      debugPrint("Verify OTP Error: $errorMessage");
      throw (errorMessage);
    }
  }

  Future<String> logout({
    required String bearerToken,
    required int userId,
  }) async {
    const endpoint = 'api/logout';
    final body = {
      'id': userId.toString(),
    };

    debugPrint("Sending logout request with body: $body");

    final response = await apiService.postFormData(
      endpoint,
      body,
      bearerToken: bearerToken,
    );

    debugPrint("Logout response status: ${response.statusCode}");
    debugPrint("Logout response body: ${response.body}");

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    debugPrint("Decoded JSON response: $jsonResponse");

    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true) {
        return jsonResponse['message'] ?? 'Logged out successfully';
      } else {
        throw (jsonResponse['message'] ?? 'Logout failed');
      }
    } else {
      final errorMessage =
          jsonResponse.containsKey('message') && jsonResponse['message'] != null
              ? jsonResponse['message']
              : 'Please try again later';

      debugPrint("Logout Error: $errorMessage");
      throw (errorMessage);
    }
  }

  Future<String> resetPassword({
    required String password,
    required String passwordConfirmation,
    required String email,
  }) async {
    const endpoint = 'api/reset-password';
    final body = {
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    debugPrint("Sending resetPassword request with body: $body");

    final response = await apiService.postFormData(
      endpoint,
      body,
    );

    debugPrint("ResetPassword response status: ${response.statusCode}");
    debugPrint("ResetPassword response body: ${response.body}");

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    debugPrint("Decoded JSON response: $jsonResponse");

    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true) {
        return jsonResponse['message'] ?? 'Password reset successfully.';
      } else {
        throw (jsonResponse['message'] ?? 'Failed to reset password');
      }
    } else {
      final errorMessage =
          jsonResponse.containsKey('message') && jsonResponse['message'] != null
              ? jsonResponse['message']
              : 'Please try again later';

      debugPrint("Reset Password Error: $errorMessage");
      throw (errorMessage);
    }
  }

  Future<ProfileModel> getProfile({
    required String bearerToken,
    required int userId,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/profile?id=$userId');
    log("[GET PROFILE] Request URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      log("[GET PROFILE] Status Code: ${response.statusCode}");
      log("[GET PROFILE] Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          log("[GET PROFILE] Decoded JSON: $jsonResponse");

          if (jsonResponse['success'] == true) {
            if (jsonResponse['data'] == null) {
              log("[GET PROFILE] Warning: 'data' is null");
              throw Exception("Profile data is missing.");
            }

            // Clean image URL if exists
            String? image = jsonResponse['data']['image'];
            if (image != null) {
              image = image.replaceAll(r'\/', '/');
              log("[GET PROFILE] Cleaned Image URL: $image");
            } else {
              log("[GET PROFILE] No image found in profile data.");
            }

            // Return ProfileModel from JSON
            return ProfileModel.fromJson({
              ...jsonResponse['data'],
              'image': image ?? '',
            });
          } else {
            log("[GET PROFILE] API returned success=false with message: ${jsonResponse['message']}");
            throw Exception(jsonResponse['message']);
          }
        } catch (e) {
          log("[GET PROFILE] JSON parsing error: $e");
          throw Exception("Invalid response format from server.");
        }
      } else {
        log("[GET PROFILE] Error: Unexpected status code ${response.statusCode}");
        throw Exception(
            "Failed to get profile. Server returned ${response.statusCode}.");
      }
    } catch (e) {
      log("[GET PROFILE] Exception: $e");
      throw Exception("Something went wrong while fetching profile: $e");
    }
  }

  // Future<ProfileModel> getProfile({
  //   required String bearerToken,
  //   required int userId,
  // }) async {
  //   final url = Uri.parse('${ApiService.baseUrl}/api/profile?id=$userId');
  //   debugPrint("Calling GET Profile at: $url");

  //   final response = await http.get(url, headers: {
  //     'Authorization': 'Bearer $bearerToken',
  //     'Content-Type': 'application/json',
  //   });

  //   debugPrint("GetProfile response status: ${response.statusCode}");
  //   debugPrint("GetProfile response body: ${response.body}");

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //     if (jsonResponse['success'] == true) {
  //       String image = jsonResponse['data']['image'].replaceAll(r'\/', '/');

  //       debugPrint("Cleaned Image URL: $image");

  //       return ProfileModel.fromJson({
  //         ...jsonResponse['data'],
  //         'image': image,
  //       });
  //     } else {
  //       throw Exception(jsonResponse['message']);
  //     }
  //   } else {
  //     throw Exception('Failed to get profile. Please try again later');
  //   }
  // }

  Future<String> updateProfile({
    required String bearerToken,
    required int userId,
    required String name,
    File? imageFile, // optional
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/update-profile');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $bearerToken';

    request.fields['id'] = userId.toString();
    request.fields['name'] = name;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    final decoded = jsonDecode(responseBody);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return decoded['message'] ?? 'Profile updated';
    } else {
      throw Exception(decoded['message'] ?? 'Failed to update profile');
    }
  }

  Future<List<Survey>> fetchSurveyList({
    required String bearerToken,
    required int userId,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/suvery-list?id=$userId');
    debugPrint("Fetching survey list from: $url");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $bearerToken',
      'Content-Type': 'application/json',
    });

    debugPrint("Survey list response status: ${response.statusCode}");
    debugPrint("Survey list response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        SurveyResponse surveyResponse = SurveyResponse.fromJson(jsonResponse);
        return surveyResponse.data;
      } else {
        throw Exception(
            jsonResponse['message'] ?? 'Failed to fetch survey list');
      }
    } else {
      throw Exception(
          'Failed to fetch survey list. Status code: ${response.statusCode}');
    }
  }

  Future<bool> deleteSubmittedSurvey({
    required String bearerToken,
    required int userId,
    required int submittedSurveyId,
  }) async {
    const String endpoint = 'api/delete-submitted-survey';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    print("Deleting Survey ID: $submittedSurveyId");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'user_id': userId.toString(),
        'submited_survey_id': submittedSurveyId.toString(), // ✅ Fixing the typo
      },
    );

    print("Delete API Response: ${response.body}");

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      print("Survey Deleted Successfully");
      return true;
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to delete survey');
    }
  }

  Future<SurveyDetail> getSurveyDetail({
    required String bearerToken,
    required int surveyId,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/get-survey?id=$surveyId');
    debugPrint("📡 Fetching survey detail from: $url");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $bearerToken',
      'Content-Type': 'application/json',
    });

    debugPrint("📦 Response Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'];

        // Extract fields for logging
        final surveyName = data['name'];
        final surveyCode = data['survey_id'];
        final zoneName = data['zone']?['name'] ?? 'Unknown';
        final startDate = data['start_date'];
        final endDate = data['end_date'];
        final isComplete = data['is_complete'] == 1 ? '✅ Yes' : '❌ No';
        final status = data['status'];
        final isApproved =
            data['is_approve'] == '1' ? '✅ Approved' : '❌ Not Approved';
        final createdAt = data['created_at'];
        final markets = data['markets'] as List<dynamic>;
        final categories = data['categories'] as List<dynamic>;

        // Format and print
        log('''
🔍 Survey Details Fetched:
────────────────────────────────────
🆔 Survey ID     : $surveyCode
📋 Name          : $surveyName
📍 Zone          : $zoneName
📅 Start Date    : $startDate
📅 End Date      : $endDate
📌 Completed     : $isComplete
🔐 Approved      : $isApproved
📊 Status        : $status
🕒 Created At    : $createdAt
🏪 Markets (${markets.length}):
${markets.map((m) => "   • ${m['name']}").join('\n')}
📦 Categories (${categories.length}):
${categories.map((c) {
          final catName = c['name'];
          final commodities = (c['commodities'] as List<dynamic>).map((com) {
            final brand = com['brand']?['name'] ?? 'Unknown Brand';
            final unit = com['unit_value'] ?? 'Unknown Unit';
            return "     ◦ ${com['name']} ($brand, $unit)";
          }).join('\n');
          return "   • $catName:\n$commodities";
        }).join('\n')}
────────────────────────────────────
''');

        return SurveyDetail.fromJson(data);
      } else {
        throw Exception(
            jsonResponse['message'] ?? '❌ Failed to fetch survey details');
      }
    } else {
      throw Exception(
          '❌ Failed to fetch survey details. Status code: ${response.statusCode}');
    }
  }

  Future<List<ValidatedCommodity>> validateSurvey({
    required String bearerToken,
    required int zoneId,
    required int surveyId,
    required int marketId,
    required int categoryId,
  }) async {
    const String endpoint = 'api/validate-survey';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'zone_id': zoneId,
        'survey_id': surveyId,
        'market_id': marketId,
        'category_id': categoryId,
      }),
    );

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    print("response validate survey${response.body}");

    // ✅ Handle Success Response (Status Code 200)
    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      return (jsonResponse['data'] as List)
          .map((item) =>
              ValidatedCommodity.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception(jsonResponse['message'] ?? 'Failed to fetch survey data');
  }

  Future<String> submitSurveyWithImage({
    required String bearerToken,
    required int userId,
    required int zoneId,
    required int surveyId,
    required int marketId,
    required int commodityId,
    required int unitId,
    required int brandId,
    required double amount,
    required int categoryId,
    required int submittedBy,
    required String availability,
    required String commodityExpiryDate,
    required String commodityImagePath,
  }) async {
    final endpoint = 'api/submit-survey';
    final url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $bearerToken'
      ..headers['Content-Type'] = 'multipart/form-data';

    request.fields['user_id'] = userId.toString();
    request.fields['zone_id'] = zoneId.toString();
    request.fields['survey_id'] = surveyId.toString();
    request.fields['market_id'] = marketId.toString();
    request.fields['commodity_id'] = commodityId.toString();
    request.fields['unit_id'] = unitId.toString();
    request.fields['brand_id'] = brandId.toString();
    request.fields['amount'] = amount.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['submitted_by'] = submittedBy.toString();
    request.fields['availability'] = availability;
    request.fields['commodity_expiry_date'] = commodityExpiryDate;

    File imageFile = File(commodityImagePath);
    if (!await imageFile.exists()) {
      throw Exception("Image file not found at path: $commodityImagePath");
    }

    final fileExtension = commodityImagePath.split('.').last.toLowerCase();
    if (!['jpeg', 'jpg', 'png'].contains(fileExtension)) {
      throw Exception("Invalid image file type. Must be jpeg, jpg, or png.");
    }

    request.files.add(await http.MultipartFile.fromPath(
        'commodity_image', commodityImagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint("Submit survey response status: ${response.statusCode}");
    debugPrint("Submit survey response body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['message'] ?? 'Survey submitted successfully!';
      } else {
        throw Exception(jsonResponse['message'] ?? 'Survey submission failed.');
      }
    } else if (response.statusCode == 422) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['data'] != null) {
        final Map<String, String> fieldErrors = {};
        (jsonResponse['data'] as Map<String, dynamic>).forEach((field, errors) {
          if (errors is List && errors.isNotEmpty) {
            fieldErrors[field] = errors.first.toString();
          }
        });
        throw ValidationException(fieldErrors,
            message: jsonResponse['message'] ?? 'Validation error');
      } else {
        throw Exception(jsonResponse['message'] ?? 'Survey submission failed');
      }
    } else {
      throw Exception(
          'Failed to submit survey. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getFiltersMasterData({
    required String bearerToken,
  }) async {
    const endpoint = 'api/get-filters-master-data';
    final url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    debugPrint("Fetching filter data from: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    debugPrint("Filter data response status: ${response.statusCode}");
    debugPrint("Filter data response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            jsonResponse['message'] ?? 'Failed to fetch filter data');
      }
    } else {
      throw Exception(
          'Failed to fetch filter data. Status code: ${response.statusCode}');
    }
  }

  Future<List<SubmittedSurvey>> getSubmittedSurveys({
    required String bearerToken,
    required int userId,
  }) async {
    const endpoint = 'api/submitted-survey-list';

    final queryParameters = {
      'id': userId.toString(),
    };

    final uri = Uri.parse('${ApiService.baseUrl}/$endpoint')
        .replace(queryParameters: queryParameters);

    debugPrint("Fetching submitted surveys with URI: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    debugPrint("Submitted surveys response status: ${response.statusCode}");
    debugPrint("Submitted surveys response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((item) => SubmittedSurvey.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch surveys');
      }
    } else {
      throw Exception(
          'Failed to fetch surveys. Status code: ${response.statusCode}');
    }
  }

  Future<List<SubmittedSurvey>> getSavedSurveys({
    required String bearerToken,
    required int userId,
  }) async {
    const endpoint = 'api/saved-survey-list';

    final queryParameters = {
      'id': userId.toString(),
    };

    final uri = Uri.parse('${ApiService.baseUrl}/$endpoint')
        .replace(queryParameters: queryParameters);

    debugPrint("Fetching saved surveys with URI: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    debugPrint("saved surveys response status: ${response.statusCode}");
    debugPrint("saved surveys response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((item) => SubmittedSurvey.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch surveys');
      }
    } else {
      throw Exception(
          'Failed to fetch surveys. Status code: ${response.statusCode}');
    }
  }
// ✅ Required for detecting file type

  Future<Map<String, dynamic>> saveSurvey({
    required String bearerToken,
    required int userId,
    required int zoneId,
    required int surveyId,
    required int marketId,
    required List<int> commodityIds,
    required List<String> amounts,
    required int categoryId,
    required int submittedBy,
    required List<String> availabilities,
    required List<int> unitIds,
    required List<int> brandIds,
    required List<String> commodityExpiryDates,
    required List<String> commodityImages,
  }) async {
    const String endpoint = 'api/save-survey';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $bearerToken';
    print('amounts$amounts');

    request.fields['user_id'] = userId.toString();
    request.fields['zone_id'] = zoneId.toString();
    request.fields['survey_id'] = surveyId.toString();
    request.fields['market_id'] = marketId.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['submitted_by'] = submittedBy.toString();

    for (int i = 0; i < commodityIds.length; i++) {
      request.fields['commodity_id[$i]'] = commodityIds[i].toString();
      request.fields['amount[$i]'] = amounts[i];
      request.fields['availability[$i]'] = availabilities[i].toLowerCase();
      request.fields['unit_id[$i]'] = unitIds[i].toString();
      request.fields['brand_id[$i]'] = brandIds[i].toString();
      request.fields['commodity_expiry_date[$i]'] = commodityExpiryDates[i];

      if (commodityImages[i].isNotEmpty) {
        File imageFile = File(commodityImages[i]);
        if (await imageFile.exists()) {
          String? mimeType = lookupMimeType(imageFile.path);
          var multipartFile = await http.MultipartFile.fromPath(
            'commodity_image[$i]',
            imageFile.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          );
          request.files.add(multipartFile);
        }
      }
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);
    print("staus cpde${jsonResponse}");

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      List<int> submittedSurveyIds = (jsonResponse['data'] as List)
          .map((item) => item['id'] as int)
          .toList();

      String message = jsonResponse.containsKey('message')
          ? jsonResponse['message']
          : 'Survey saved successfully.';

      print("save response: $jsonResponse");

      return {
        'success': true,
        'submitted_survey_ids': submittedSurveyIds,
        'message': message,
        'data': jsonResponse['data'],
      };
    } else {
      throw (jsonResponse['message'] ?? 'Failed to save survey');
    }
  }

  Future<Map<String, dynamic>> submitSurvey({
    required String bearerToken,
    required int userId,
    required int zoneId,
    required int surveyId,
    required int marketId,
    required List<int> commodityIds,
    required List<int> submittedSurveyId,
    required List<String> amounts,
    required int categoryId,
    required int submittedBy,
    required List<String> availabilities,
    required List<int> unitIds,
    required List<int> brandIds,
    required List<String> commodityExpiryDates,
    required List<String> commodityImages,
  }) async {
    const String endpoint = 'api/submit-survey';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $bearerToken';

    request.fields['user_id'] = userId.toString();
    request.fields['zone_id'] = zoneId.toString();
    request.fields['survey_id'] = surveyId.toString();
    request.fields['market_id'] = marketId.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['submitted_by'] = submittedBy.toString();

    for (int i = 0; i < commodityIds.length; i++) {
      request.fields['commodity_id[$i]'] = commodityIds[i].toString();
      request.fields['submited_survey_id[$i]'] =
          submittedSurveyId[i].toString();
      request.fields['amount[$i]'] = amounts[i];
      request.fields['availability[$i]'] = availabilities[i].toLowerCase();
      request.fields['unit_id[$i]'] = unitIds[i].toString();
      request.fields['brand_id[$i]'] = brandIds[i].toString();
      request.fields['commodity_expiry_date[$i]'] = commodityExpiryDates[i];

      if (commodityImages[i].isNotEmpty) {
        File imageFile = File(commodityImages[i]);
        if (await imageFile.exists()) {
          String? mimeType = lookupMimeType(imageFile.path);
          var multipartFile = await http.MultipartFile.fromPath(
            'commodity_image[$i]',
            imageFile.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          );
          request.files.add(multipartFile);
        }
      }
    }

    var response = await request.send();
    print("response$response");
    var responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);
    print("response$jsonResponse");
    print("response${response.statusCode}");

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      return jsonResponse;
    } else {
      throw (jsonResponse['message'] ?? 'Failed to save survey');
    }
  }

  Future<ApprovedDetailModel> getAssignedSurveyDetail({
    required String bearerToken,
    required int id,
  }) async {
    final url =
        Uri.parse('${ApiService.baseUrl}/api/assigned-submitted-survey?id=$id');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      });

      debugPrint(
          "📡 Assigned Survey Detail → ${response.statusCode} : ${response.body}");

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return ApprovedDetailModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(
            jsonResponse['message'] ?? 'Failed to load assigned survey');
      }
    } catch (e) {
      debugPrint('❌ Exception in getAssignedSurveyDetail: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  Future<List<AssignedCommodityModel>> getAssignedSurveyCommodities({
    required String bearerToken,
    required int userId,
    required int surveyId,
    required int marketId,
    required int categoryId,
  }) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/assigned-survey-commodity?user_id=$userId&survey_id=$surveyId&market_id=$marketId&category_id=$categoryId',
    );

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      });

      debugPrint(
          "📡 Assigned Commodities → ${response.statusCode} : ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => AssignedCommodityModel.fromJson(e)).toList();
      } else {
        throw Exception(
            jsonResponse['message'] ?? 'Failed to load commodities');
      }
    } catch (e) {
      debugPrint('❌ Exception in getAssignedSurveyCommodities: $e');
      throw Exception('Unable to fetch commodity list');
    }
  }

  Future<String> approveSurvey({
    required String bearerToken,
    required int userId,
    required int zoneId,
    required int surveyId,
    required int marketId,
    required int categoryId,
    required int submittedBy,
    required List<int> commodityIds,
    required List<int> unitIds,
    required List<int> brandIds,
    required List<String> amounts,
    required List<String> expiryDates,
    required List<int> submittedSurveyIds,
  }) async {
    const String endpoint = 'api/approve-survey';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $bearerToken';

    request.fields['user_id'] = userId.toString();
    request.fields['zone_id'] = zoneId.toString();
    request.fields['survey_id'] = surveyId.toString();
    request.fields['market_id'] = marketId.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['submitted_by'] = submittedBy.toString();

    for (int i = 0; i < commodityIds.length; i++) {
      request.fields['commodity_id[$i]'] = commodityIds[i].toString();
      request.fields['unit_id[$i]'] = unitIds[i].toString();
      request.fields['brand_id[$i]'] = brandIds[i].toString();
      request.fields['amount[$i]'] = amounts[i];

      request.fields['commodity_expiry_date[$i]'] = expiryDates[i];
      request.fields['submited_survey_id[$i]'] =
          submittedSurveyIds[i].toString();
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      return jsonResponse['message'] ?? 'Survey approved';
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to approve survey');
    }
  }
}

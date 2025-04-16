import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_services.dart';

class SurveyRepository {


  Future<Map<String, dynamic>> getSingleSurveyDetails({
    required String bearerToken,
    required int submittedSurveyId,
  }) async {
    const String endpoint = 'api/submitted-survey-commodities';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint')
        .replace(queryParameters: {
      'id': submittedSurveyId.toString(),
    });

    print("Fetching Survey Details from: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    print("Survey Details Response: ${response.body}");

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      return jsonResponse['data'];
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to fetch survey details');
    }
  }


  Future<Map<String, dynamic>> getSingleSavedSurveyDetails({
    required String bearerToken,
    required int submittedSurveyId,
  }) async {
    const String endpoint = 'api/saved-survey-commodities';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint')
        .replace(queryParameters: {
      'id': submittedSurveyId.toString(),
    });

    print("Fetching Saved Survey Details from: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    print("Survey Saved Details Response: ${response.body}");

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['success'] == true) {
      return jsonResponse['data'];
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to fetch saved survey details');
    }
  }

  Future<Map<String, dynamic>> updateSurvey({
    required String bearerToken,
    required int submittedSurveyId,
    required int updatedBy,
    required String amount,
    required String availability,
  }) async {
    const String endpoint = 'api/update-survey';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    final formattedAmount = double.tryParse(amount)?.toStringAsFixed(2) ?? "0.00";
    final formattedAvailability = availability.isNotEmpty ? availability : "moderate";

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'updated_by': updatedBy,
        'submited_survey_id': submittedSurveyId,
        'amount': formattedAmount,
        'availability': formattedAvailability,
      }),
    );

    print("Updating Survey at: $url");
    print("Update Request Body: ${jsonEncode({
      'updated_by': updatedBy,
      'submited_survey_id': submittedSurveyId,
      'amount': formattedAmount,
      'availability': formattedAvailability,
    })}");
    print("Update Response: ${response.body}");

    return jsonDecode(response.body);
  }


}

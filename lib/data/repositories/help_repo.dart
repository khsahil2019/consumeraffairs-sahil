import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/help_model.dart';
import '../services/api_services.dart';


class HelpRepository {
  Future<List<HelpFAQ>> getHelpFAQs({required String bearerToken}) async {
    const String endpoint = 'api/help-faq';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint');

    print("Fetching Help FAQs from: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    print("Help API Status: ${response.statusCode}");
    print("Help API Response: ${response.body}");

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'] ?? [];


        print("Parsed Data: $data");

        return data.map((item) => HelpFAQ.fromJson(item)).toList();
      } else {
        print("API Error: ${jsonResponse['message']}");
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch FAQs');
      }
    } else {
      print("API Fetch Error: ${jsonResponse['message']}");
      throw Exception(jsonResponse['message'] ?? 'Failed to fetch FAQs');
    }
  }
}

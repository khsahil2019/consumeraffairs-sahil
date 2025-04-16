import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_services.dart';

class NotificationRepository {
  Future<List<Map<String, dynamic>>> fetchNotifications({required String bearerToken, required int userId}) async {
    const String endpoint = 'api/get-notification';
    final Uri url = Uri.parse('${ApiService.baseUrl}/$endpoint').replace(queryParameters: {'id': userId.toString()});


    print("Fetching notifications from: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw (jsonResponse.containsKey('message') ? jsonResponse['message'] : 'Failed to fetch notifications');
      }
    } else {
      throw (jsonResponse.containsKey('message') ? jsonResponse['message'] : 'Failed to fetch notifications');
    }
  }
}

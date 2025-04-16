// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../data/repositories/notification_repo.dart';

// class NotificationViewModel extends ChangeNotifier {
//   final NotificationRepository _repository = NotificationRepository();

//   List<Map<String, dynamic>> notifications = [];
//   bool isLoading = false;
//   String errorMessage = '';

//   Future<void> fetchNotifications() async {
//     try {
//       isLoading = true;
//       notifyListeners();

//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final userId = prefs.getInt('user_id') ?? 0;

//       if (token.isEmpty || userId == 0) {
//         throw Exception("User authentication failed.");
//       }

//       notifications = await _repository.fetchNotifications(
//         bearerToken: token,
//         userId: userId,
//       );

//       isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       isLoading = false;
//       errorMessage = e.toString();
//       notifyListeners();
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/notification_repo.dart';
import 'dart:convert';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchNotifications() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      if (token.isEmpty || userId == 0) {
        throw Exception("User authentication failed.");
      }

      notifications = await _repository.fetchNotifications(
        bearerToken: token,
        userId: userId,
      );

      // Cache notifications
      await prefs.setString(
        'cached_notifications_$userId',
        jsonEncode(notifications),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCachedNotifications() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final cachedData = prefs.getString('cached_notifications_$userId');

      if (cachedData != null) {
        notifications = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
      } else {
        notifications = [];
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load cached notifications.';
      notifyListeners();
    }
  }
}

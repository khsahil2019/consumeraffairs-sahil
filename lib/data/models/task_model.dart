import 'package:flutter/cupertino.dart';

class SurveyResponse {
  final bool success;
  final String message;
  final List<Survey> data;

  SurveyResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => Survey.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Survey {
  final int id;
  final String? surveyId;
  final String name;
  final int zoneId;
  final String startDate;
  final String endDate;
  final bool isComplete;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOverdue;
  final Zone zone;

  Survey({
    required this.id,
    required this.surveyId,
    required this.name,
    required this.zoneId,
    required this.startDate,
    required this.endDate,
    required this.isComplete,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isOverdue,
    required this.zone,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'name': name,
      'zone_id': zoneId,
      'start_date': startDate,
      'end_date': endDate,
      'is_complete': isComplete,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_overdue': isOverdue,
      'zone': zone.toJson(), // Ensure Zone has a toJson() method
    };
  }

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      surveyId: json['survey_id'],
      name: json['name'],
      zoneId: json['zone_id'],
      startDate: json['start_date'] ?? '', // ✅ Store as String
      endDate: json['end_date'] ?? '',
      isComplete: json['is_complete'] is bool
          ? json['is_complete']
          : json['is_complete'] == 1,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isOverdue: json['is_overdue'] is bool
          ? json['is_overdue']
          : json['is_overdue'] == 1,
      zone: json['zone'] != null
          ? Zone.fromJson(json['zone'] as Map<String, dynamic>)
          : Zone(
              id: 0,
              name: "Unknown",
              status: "N/A",
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()),
    );
  }
  DateTime? get startDateTime => _parseDate(startDate);
  DateTime? get endDateTime => _parseDate(endDate);

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr); // ✅ Works for "YYYY-MM-DD HH:MM:SS"
    } catch (e) {
      debugPrint("Date parsing error: $e");
      return null;
    }
  }
}

class Zone {
  final int id;
  final String name;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Zone({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  // Convert Zone object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

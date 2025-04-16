/// Model: SubmittedSurvey
/// ----------------------
/// This model represents a survey that has been filled and submitted by the user.
/// It's used to parse data from the API, manage the data in memory, and
/// pass the data to UI widgets like survey cards or lists.
///
/// Fields:
/// - id: Primary key of the submitted survey
/// - surveyId: Original survey reference ID (nullable)
/// - name: Name/title of the survey
/// - zoneId: Zone where the survey was conducted
/// - startDate: Survey start date (in DateTime format)
/// - endDate: Survey end date (in DateTime format)
/// - isComplete: Whether the survey was fully completed (true/false)
library;

class SubmittedSurvey {
  final int id;
  final String? surveyId;
  final String name;
  final int zoneId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isComplete;

  SubmittedSurvey({
    required this.id,
    required this.surveyId,
    required this.name,
    required this.zoneId,
    required this.startDate,
    required this.endDate,
    required this.isComplete,
  });

  /// Creates a SubmittedSurvey object from raw JSON.
  factory SubmittedSurvey.fromJson(Map<String, dynamic> json) {
    return SubmittedSurvey(
      id: json['id'],
      surveyId: json['survey_id'],
      name: json['name'],
      zoneId: json['zone_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isComplete: json['is_complete'] == 1, // 1 means true, 0 means false
    );
  }

  /// Converts this object back to a JSON map (optional but useful for logging, caching, etc.)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'name': name,
      'zone_id': zoneId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_complete': isComplete ? 1 : 0,
    };
  }
}

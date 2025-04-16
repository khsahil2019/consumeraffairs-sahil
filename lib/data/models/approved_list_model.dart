class ApprovedDetailModel {
  final int id;
  final String surveyId;
  final String name;
  final int zoneId;
  final int investigationOfficer;
  final String startDate;
  final String endDate;
  final int isComplete;
  final String status;
  final String createdAt;
  final String updatedAt;
  final ApprovedZone zone;
  final List<ApprovedMarket> markets;
  final List<ApprovedCategory> categories;

  ApprovedDetailModel({
    required this.id,
    required this.surveyId,
    required this.name,
    required this.zoneId,
    required this.investigationOfficer,
    required this.startDate,
    required this.endDate,
    required this.isComplete,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.zone,
    required this.markets,
    required this.categories,
  });

  factory ApprovedDetailModel.fromJson(Map<String, dynamic> json) {
    return ApprovedDetailModel(
      id: json['id'],
      surveyId: json['survey_id'],
      name: json['name'],
      zoneId: json['zone_id'],
      investigationOfficer: json['investigation_officer'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isComplete: json['is_complete'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      zone: ApprovedZone.fromJson(json['zone']),
      markets: List<ApprovedMarket>.from(
        json['markets'].map((x) => ApprovedMarket.fromJson(x)),
      ),
      categories: List<ApprovedCategory>.from(
        json['categories'].map((x) => ApprovedCategory.fromJson(x)),
      ),
    );
  }
}
class ApprovedZone {
  final int id;
  final String name;

  ApprovedZone({
    required this.id,
    required this.name,
  });

  factory ApprovedZone.fromJson(Map<String, dynamic> json) {
    return ApprovedZone(
      id: json['id'],
      name: json['name'],
    );
  }
}
class ApprovedMarket {
  final int id;
  final String name;

  ApprovedMarket({
    required this.id,
    required this.name,
  });

  factory ApprovedMarket.fromJson(Map<String, dynamic> json) {
    return ApprovedMarket(
      id: json['id'],
      name: json['name'],
    );
  }
}
class ApprovedCategory {
  final int id;
  final String name;

  ApprovedCategory({
    required this.id,
    required this.name,
  });

  factory ApprovedCategory.fromJson(Map<String, dynamic> json) {
    return ApprovedCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

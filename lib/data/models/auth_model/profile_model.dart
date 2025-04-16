class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String image;
  final int survey_count;
  final int completed_survey;
  final int pending_survey;
  final int overdue_survey;
  final String role;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.survey_count,
    required this.completed_survey,
    required this.pending_survey,
    required this.overdue_survey,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
      survey_count: json['survey_count'],
      completed_survey: json['completed_survey'],
      pending_survey: json['pending_survey'],
      overdue_survey: json['overdue_survey'],
      role: json['role'],
    );
  }
}

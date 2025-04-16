class HelpFAQ {
  final int id;
  final String title;
  final String description;

  HelpFAQ({required this.id, required this.title, required this.description});

  factory HelpFAQ.fromJson(Map<String, dynamic> json) {
    return HelpFAQ(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
    );
  }
}

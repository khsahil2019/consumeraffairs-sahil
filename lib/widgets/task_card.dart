import 'dart:developer';

import 'package:cunsumer_affairs_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/task_model.dart';
import '../core/constants/app_routes.dart';

class TaskCard extends StatelessWidget {
  final Survey survey; // The survey/task data passed to the card

  const TaskCard({Key? key, required this.survey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the status of the task (Overdue / Completed / Pending)
    String statusText;
    Color statusColor;

    if (survey.isOverdue) {
      statusText = "Overdue";
      statusColor = Colors.red;
    } else if (survey.isComplete) {
      statusText = "Completed";
      statusColor = Colors.green;
    } else {
      statusText = "Pending";
      statusColor = Colors.orange;
    }

    // Check if the current date is within the survey's active date range
    bool isSurveyActive = _isSurveyInDateRange(survey);

    return Card(
      margin:
          const EdgeInsets.symmetric(vertical: 8), // Adds spacing between cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12), // Padding inside the card
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- LEFT SIDE: Text Info ----------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task/Survey title
                  Text(
                    survey.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Status badge (Overdue, Completed, Pending)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Start date
                  Text(
                    "Start Date: ${formatDate(survey.startDate)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  // End date
                  Text(
                    "End Date: ${formatDate(survey.endDate)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // ---------- RIGHT SIDE: Start Survey Button ----------
            GestureDetector(
              onTap: isSurveyActive
                  ? () {
                      // Navigate to the survey screen with ID
                      log('''
🔍 Survey Tapped:
-----------------------------
🆔 ID           : ${survey.id}
📋 Name         : ${survey.name}
📍 Zone ID      : ${survey.zoneId}
📅 Start Date   : ${survey.startDate}
📅 End Date     : ${survey.endDate}
✅ Is Complete  : ${survey.isComplete}
⚠️ Is Overdue   : ${survey.isOverdue}
⏰ StartDateTime: ${survey.startDateTime}
⏳ EndDateTime  : ${survey.endDateTime}
-----------------------------
''');

                      Navigator.pushNamed(
                        context,
                        AppRoutes.productSurveyScreen,
                        arguments: survey.id,
                      );
                    }
                  : null, // Disable button if survey is not active
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSurveyActive ? AppColors.primaryColor : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Start Survey",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// This checks whether the current date is within the survey's start and end dates
  bool _isSurveyInDateRange(Survey survey) {
    DateTime now = DateTime.now();
    DateTime? start = survey.startDateTime;
    DateTime? end = survey.endDateTime;

    if (start == null || end == null) return false;

    return now.isAfter(start.subtract(const Duration(seconds: 1))) &&
        now.isBefore(end.add(const Duration(days: 1)));
  }

  /// Converts date string to a readable format like "09 April 2025"
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";

    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat("dd MMMM yyyy").format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }
}

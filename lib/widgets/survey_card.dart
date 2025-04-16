import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/submitted_survey_model.dart';
import '../core/constants/app_colors.dart';
import '../views/commodity_details_screen.dart';

class SurveyCard extends StatelessWidget {
  final SubmittedSurvey survey;
  final bool isSavedSurvey;

  const SurveyCard({Key? key, required this.survey, required this.isSavedSurvey,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  survey.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),


                Text(
                  "Start Date: ${formatDate(survey.startDate.toString())}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "End Date: ${formatDate(survey.endDate.toString())}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),


                const SizedBox(height: 10),


              ],
            ),
            GestureDetector(
              onTap: () {
                print("Navigating to Survey Details with ID: ${survey.id}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurveyDetailsScreen(submittedSurveyId: survey.id, isSavedSurvey: isSavedSurvey,),
                  ),
                );

              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "View Survey",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
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

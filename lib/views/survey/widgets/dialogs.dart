import 'package:cunsumer_affairs_app/view_model/productSurvey/product_survey_detail_view_model.dart';
import 'package:flutter/material.dart';

void showSubmitConfirmationDialog(
    BuildContext context, ProductSurveyDetailViewModel viewModel) {
  final isTablet = MediaQuery.of(context).size.width > 600;
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text("Confirm Submission",
            style: TextStyle(fontSize: isTablet ? 18 : 16)),
        content: Text(
            "Are you sure you want to submit the survey? If you submit the survey then you are not able to edit.",
            style: TextStyle(fontSize: isTablet ? 16 : 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("No",
                style:
                    TextStyle(color: Colors.red, fontSize: isTablet ? 16 : 14)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                viewModel.submitSurvey(context);
              });
            },
            child: Text("Yes",
                style: TextStyle(
                    color: Colors.green, fontSize: isTablet ? 16 : 14)),
          ),
        ],
      );
    },
  );
}

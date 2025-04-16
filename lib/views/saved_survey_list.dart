import 'package:cunsumer_affairs_app/view_model/saved_survey_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/survey_list_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/survey_card.dart';

class SurveySavedListScreen extends StatefulWidget {
  const SurveySavedListScreen({Key? key}) : super(key: key);

  @override
  _SurveySavedListScreenState createState() => _SurveySavedListScreenState();
}

class _SurveySavedListScreenState extends State<SurveySavedListScreen> {
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SurveySavedListViewModel>(context, listen: false).fetchSavedSurveys();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SurveySavedListViewModel>();

    return Scaffold(
      appBar: CustomAppBar(title: 'In-Progress Surveys', focusNode: focusNode,),
      endDrawer: CustomEndDrawer(),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.savedSurveys.isEmpty
          ? const Center(child: Text("No in-progress surveys found."))
          : ListView.builder(
        itemCount: viewModel.savedSurveys.length,
        itemBuilder: (context, index) {
          return SurveyCard(
            survey: viewModel.savedSurveys[index],
            isSavedSurvey: true,
          );

        },
      ),
    );
  }
}

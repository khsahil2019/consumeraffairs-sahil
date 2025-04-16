import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/survey_list_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/survey_card.dart';

class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({Key? key}) : super(key: key);

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Screen render hone ke baad survey fetch kar rahe hain
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurveyListViewModel>().fetchSubmittedSurveys();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SurveyListViewModel>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Submitted Surveys',
        focusNode: focusNode,
      ),
      endDrawer: CustomEndDrawer(),
      body: _buildBody(viewModel),
    );
  }

  /// Survey list body ka logic alag method mein shift kiya for clarity
  Widget _buildBody(SurveyListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.submittedSurveys.isEmpty) {
      return const Center(child: Text("No submitted surveys found."));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      itemCount: viewModel.submittedSurveys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return SurveyCard(
          survey: viewModel.submittedSurveys[index],
          isSavedSurvey: false, // ✅ Already submitted survey
        );
      },
    );
  }
}

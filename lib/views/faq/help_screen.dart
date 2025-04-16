import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/help_model.dart';
import '../../view_model/help_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HelpViewModel>().fetchHelpQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Help", focusNode: FocusNode()),
      endDrawer: CustomEndDrawer(),
      body: Consumer<HelpViewModel>(
        builder: (context, viewModel, _) {
          return viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.helpQuestions.isEmpty
                  ? const Center(child: Text("No FAQs available"))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: viewModel.helpQuestions.length,
                        itemBuilder: (context, index) {
                          final faq = viewModel.helpQuestions[index];
                          return FAQItem(faq: faq);
                        },
                      ),
                    );
        },
      ),
    );
  }
}

// 🔹 Expandable FAQ Widget
class FAQItem extends StatefulWidget {
  final HelpFAQ faq;
  const FAQItem({Key? key, required this.faq}) : super(key: key);

  @override
  _FAQItemState createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.faq.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(_isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.faq.description,
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

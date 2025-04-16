import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/submitted_survey_details_model.dart';
import '../view_model/commodity_details_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';

class SurveyDetailsScreen extends StatefulWidget {
  final int? submittedSurveyId;
  final bool? isSavedSurvey;

  const SurveyDetailsScreen({
    Key? key,
    this.submittedSurveyId,
    this.isSavedSurvey,
  }) : super(key: key);

  @override
  _SurveyDetailsScreenState createState() => _SurveyDetailsScreenState();
}

class _SurveyDetailsScreenState extends State<SurveyDetailsScreen> {
  final FocusNode focusNode = FocusNode();
  int? selectedMarketIndex;
  Map<int, bool> expandedCategories = {}; // Track expanded categories

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.submittedSurveyId != null) {
        context.read<SurveyDetailsViewModel>().fetchSurveyDetails(
              widget.submittedSurveyId!,
              isSavedSurvey: widget.isSavedSurvey!,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SurveyDetailsViewModel>();

    return Scaffold(
      appBar: CustomAppBar(
        title: "Survey Details",
        focusNode: focusNode,
        showBackButton: true,
        showMenu: false,
      ),
      endDrawer: CustomEndDrawer(),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.surveyDetails == null
              ? const Center(child: Text("No data available"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                            "Survey Name", viewModel.surveyDetails!.name),
                        _buildTextField(
                            "Zone", viewModel.surveyDetails!.zone.name),
                        const SizedBox(height: 12),
                        _buildMarketDropdown(viewModel),
                        const SizedBox(height: 16),
                        if (selectedMarketIndex != null)
                          Column(
                            children: viewModel.surveyDetails!
                                .markets[selectedMarketIndex!].categories
                                .asMap()
                                .entries
                                .map((entry) =>
                                    _buildCategoryCard(entry.key, entry.value))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }

  Widget _buildMarketDropdown(SurveyDetailsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Select Market",
          border: OutlineInputBorder(),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: selectedMarketIndex,
            hint: const Text("Choose a market"),
            onChanged: (int? newIndex) {
              setState(() {
                selectedMarketIndex = newIndex;
              });
            },
            items: List.generate(
              viewModel.surveyDetails!.markets.length,
              (index) {
                final market = viewModel.surveyDetails!.markets[index];
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(market.marketName),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(int index, Category category) {
    bool isExpanded = expandedCategories[index] ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expandedCategories[index] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10), bottom: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.categoryName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildCommoditiesTable(category),
        ],
      ),
    );
  }

  Widget _buildCommoditiesTable(Category category) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text("Commodity",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text("Unit", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text("Brand", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
          // DataColumn(label: Text("Availability", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("Expiry Date",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          // DataColumn(label: Text("Image", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows:
            category.surveys.map((entry) => _buildCommodityRow(entry)).toList(),
      ),
    );
  }

  DataRow _buildCommodityRow(SurveyEntry entry) {
    return DataRow(cells: [
      DataCell(Text(entry.commodity?.name ?? 'Unknown')),
      DataCell(Text(entry.commodity?.uom?.name ?? 'Unknown')),
      DataCell(Text(entry.commodity?.brand?.name ?? 'Unknown')),
      DataCell(Text(entry.amount)),
      // DataCell(Text(entry.availability)),
      DataCell(Text(entry.commodityExpiryDate ?? 'N/A')),
      // DataCell(Text(entry.commodityImage ?? 'N/A')),
    ]);
  }

  // Widget _buildCommoditiesTable(Category category) {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: DataTable(
  //       columns: const [
  //         DataColumn(label: Text("Commodity", style: TextStyle(fontWeight: FontWeight.bold))),
  //         DataColumn(label: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
  //         DataColumn(label: Text("Availability", style: TextStyle(fontWeight: FontWeight.bold))),
  //         DataColumn(label: Text("Expiry Date", style: TextStyle(fontWeight: FontWeight.bold))),
  //       ],
  //       rows: category.surveys.map((commodity) => _buildCommodityRow(commodity.commodity)).toList(),
  //     ),
  //   );
  // }

  // DataRow _buildCommodityRow(Commodity commodity) {
  //   return DataRow(cells: [
  //     DataCell(Text(commodity.name)),
  //     DataCell(Text(commodity.amount)),
  //     DataCell(Text(commodity.availability)),
  //     DataCell(Text(commodity.expiryDate ?? 'N/A')),
  //
  //   ]);
  // }
}

import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cunsumer_affairs_app/views/survey/widgets/dialogs.dart';
import 'package:cunsumer_affairs_app/views/survey/widgets/table_widgets.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/survey_detail_model.dart';
import '../../view_model/productSurvey/product_survey_detail_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class ProductSurveyDetailsScreen extends StatefulWidget {
  const ProductSurveyDetailsScreen({super.key});

  @override
  State<ProductSurveyDetailsScreen> createState() =>
      _ProductSurveyDetailsScreenState();
}

class _ProductSurveyDetailsScreenState extends State<ProductSurveyDetailsScreen>
    with WidgetsBindingObserver {
  final FocusNode focusNode = FocusNode();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      final surveyId = args is int ? args : null;
      if (surveyId != null) {
        await context
            .read<ProductSurveyDetailViewModel>()
            .fetchSurveyDetail(surveyId);
      }
      if (await isInternetAvailable()) {
        await context.read<ProductSurveyDetailViewModel>().syncOfflineData();
      }
    });
  }

  Future<void> refreshData() async {
    final viewModel =
        Provider.of<ProductSurveyDetailViewModel>(context, listen: false);
    final args = ModalRoute.of(context)?.settings.arguments;
    final surveyId = args is int ? args : null;

    if (surveyId != null) {
      await viewModel.fetchSurveyDetail(surveyId);
      if (viewModel.selectedMarket != null &&
          viewModel.selectedCategory != null) {
        await viewModel.fetchValidatedCommodities(
          viewModel.fetchedZoneId!,
          surveyId,
          viewModel.selectedMarket!.id,
          viewModel.selectedCategory!.id,
        );
      }
    }
    if (await isInternetAvailable()) {
      await viewModel.syncOfflineData();
    }
    if (mounted) setState(() {});
  }

  Future<bool> isInternetAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductSurveyDetailViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;

    final padding = isTablet ? 24.0 : 16.0;
    final baseFontSize = isTablet ? 16.0 : 12.0;

    return Scaffold(
      appBar: CustomAppBar(
        focusNode: focusNode,
        title: 'Submit Commodity Survey',
        showBackButton: true,
        showMenu: false,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshData,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: isTablet ? 28 : 24,
                        ),
                        //   SizedBox(width: padding / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.zoneName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 20 : 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: padding),
                    DropdownButtonFormField2(
                      isExpanded: true,
                      value: viewModel.selectedMarket,
                      items: viewModel.markets.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: baseFontSize + 2),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        viewModel.setSelectedMarket(val);
                        viewModel.setSelectedCategory(null);
                        log("Selected Market: ${val?.name}");
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "Select Market",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: padding / 2,
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        offset: const Offset(0, 8),
                        elevation: 4,
                        padding: EdgeInsets.zero,
                        maxHeight: screenHeight * 0.4,
                      ),
                    ),
                    SizedBox(height: padding),
                    GestureDetector(
                      onTap: () {
                        if (viewModel.selectedMarket == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "⚠ Please select a market first.",
                                style: TextStyle(fontSize: baseFontSize + 2),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: AbsorbPointer(
                        absorbing: viewModel.selectedMarket == null,
                        child: DropdownButtonFormField2<Category>(
                          isExpanded: true,
                          value: viewModel.selectedCategory,
                          items: viewModel.categories.map((cat) {
                            return DropdownMenuItem<Category>(
                              value: cat,
                              child: Text(
                                cat.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: baseFontSize + 2),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            viewModel.setSelectedCategory(val);
                            log("Selected Category: ${val?.name}");
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: "Select Category",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: padding,
                              vertical: padding / 2,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            offset: const Offset(0, 8),
                            elevation: 4,
                            maxHeight: screenHeight * 0.4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: padding),
                    viewModel.selectedCategory == null
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(padding),
                              child: Text(
                                "To proceed, choose a Market and Category first..",
                                style: TextStyle(
                                  fontSize: baseFontSize + 4,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : buildCommodityTable(viewModel, screenWidth,
                            isLandscape, isTablet, padding, context),
                    SizedBox(height: padding),
                    if (!viewModel.isAnyCommoditySubmitted)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomButton(
                              title: "Save",
                              onPressed: () => viewModel.saveSurvey(context),
                            ),
                          ),
                          SizedBox(width: padding),
                          Expanded(
                            child: CustomButton(
                              title: "Submit",
                              onPressed: () {
                                showSubmitConfirmationDialog(
                                    context, viewModel);
                              },
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: padding),
                  ],
                ),
              ),
            ),
    );
  }
}

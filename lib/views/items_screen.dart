import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../view_model/items_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_drawer.dart';

class SubmitProductSurveyScreen extends StatelessWidget {
  final String? itemName;
  final String? categoryName;

  SubmitProductSurveyScreen({this.itemName, this.categoryName});

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductSurveyViewModel>();


    viewModel.selectedMarket = itemName;
    viewModel.selectedCategory = categoryName;


    if (categoryName != null && viewModel.categoryCommodities.containsKey(categoryName)) {
      viewModel.updateCommodities(viewModel.categoryCommodities[categoryName]!);
    }

    return Scaffold(
      appBar: CustomAppBar(focusNode: focusNode, title: 'Submit Commodity Survey'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              DropdownButtonFormField<String>(
                value: itemName,
                decoration: InputDecoration(labelText: 'Market *'),
                items: [
                  DropdownMenuItem(
                    value: itemName,
                    child: Text(itemName!),
                  ),
                ],
                onChanged: null, // Disable interaction
              ),
              SizedBox(height: 16),


              DropdownButtonFormField<String>(
                value: viewModel.selectedCategory,
                decoration: InputDecoration(labelText: 'Category *'),
                items: viewModel.categoryCommodities.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  viewModel.updateCategory(value);

                  viewModel.updateCommodities(viewModel.categoryCommodities[value]!);
                },
              ),
              SizedBox(height: 16),


              DropdownButtonFormField<String>(
                value: viewModel.selectedCommodity,
                decoration: InputDecoration(labelText: 'Commodity Name *'),
                items: viewModel.commodities.map((commodity) {
                  return DropdownMenuItem(
                    value: commodity,
                    child: Text(commodity),
                  );
                }).toList(),
                onChanged: (value) {
                  viewModel.updateCommodity(value);
                },
              ),

              SizedBox(height: 16),
              TextFormField(
                controller: viewModel.unitController,
                decoration: InputDecoration(labelText: 'Unit *'),
                readOnly: true,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: viewModel.brandController,
                decoration: InputDecoration(labelText: 'Brand'),
                readOnly: true,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: viewModel.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price *'),
              ),
              SizedBox(height: 16),
              Text('Availability Level *', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: RadioListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Low',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: 'Low',
                      groupValue: viewModel.availabilityLevel,
                      onChanged: (value) {
                        viewModel.updateAvailability(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Moderate',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: 'Moderate',
                      groupValue: viewModel.availabilityLevel,
                      onChanged: (value) {
                        viewModel.updateAvailability(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'High',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: 'High',
                      groupValue: viewModel.availabilityLevel,
                      onChanged: (value) {
                        viewModel.updateAvailability(value);
                      },
                    ),
                  ),
                ],
              ),


              SizedBox(height: 16),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton.icon(
                  onPressed: viewModel.pickImage,
                  icon: Icon(Icons.upload, color: Colors.grey),
                  label: Text('Upload Image', style: TextStyle(color: Colors.grey)),
                ),
              ),
              if (viewModel.selectedImage != null) ...[
                SizedBox(height: 8),
                Image.file(viewModel.selectedImage!),
              ],
              SizedBox(height: 16),
              CustomButton(
                title: 'Submit',
                onPressed: () async {
                  final hasInternet = await viewModel.checkInternet();
                  if (hasInternet) {
                    viewModel.submitSurvey();
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('No Internet'),
                        content: Text('Would you like to save the survey offline?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              viewModel.saveSurveyOffline(context);

                              Navigator.pop(context);
                            },
                            child: Text('Save Offline'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),

              SizedBox(height: 16),
              CustomButton(
                onPressed: () => Navigator.pop(context),
                title: 'Cancel',
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
      endDrawer: CustomEndDrawer(),
    );
  }
}

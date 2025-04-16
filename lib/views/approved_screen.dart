import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../view_model/approved_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class ApprovedScreen extends StatefulWidget {
  const ApprovedScreen({super.key});

  @override
  State<ApprovedScreen> createState() => _ApprovedScreenState();
}

class _ApprovedScreenState extends State<ApprovedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final surveyId = ModalRoute.of(context)?.settings.arguments as int?;
      if (surveyId != null) {
        context.read<ApprovedViewModel>().fetchAssignedSurveyDetail(surveyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApprovedViewModel>();

    return Scaffold(
      appBar: CustomAppBar(
        title: "Approved Survey",
        showBackButton: true,
        showMenu: false,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Zone
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text(vm.zoneName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Market Dropdown
            DropdownButtonFormField2(
              isExpanded: true,
              value: vm.selectedMarket,
              items: vm.markets.map((market) {
                return DropdownMenuItem(
                  value: market,
                  child: Text(market.name),
                );
              }).toList(),
              onChanged: (val) {
                vm.setSelectedMarket(val);
                vm.setSelectedCategory(null);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select Market",
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Category Dropdown
            DropdownButtonFormField2(
              isExpanded: true,
              value: vm.selectedCategory,
              items: vm.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (val) => vm.setSelectedCategory(val),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select Category",
              ),
            ),
            const SizedBox(height: 16),
            // ✅ Table Header & Rows
            if (vm.assignedCommodities.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey[300],
                child: Row(
                  children: const [
                    Expanded(child: Text("Commodity", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Brand", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Unit", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Expiry", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Image", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              ...vm.assignedCommodities.map((c) {
                final id = c.commodityId;
                //vm.initControllers(vm.selectedMarket!.id, vm.selectedCategory!.id);

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(c.commodity.name)),
                      Expanded(child: Text(c.commodity.brand.name)),
                      Expanded(child: Text(c.commodity.uom.name)),

                      Expanded(
                        child: TextFormField(
                          controller: vm.priceControllers[id],
                          enabled: vm.status == "0",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          onChanged: (val) => vm.updatePrice(id, val),
                        ),
                      ),


                      Expanded(
                        child: TextField(
                          controller: vm.expiryControllers[id],
                          readOnly: true,
                          enabled: vm.status == "0",
                          onTap: vm.status == "0" ? () => vm.pickExpiryDate(context, id) : null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),


                      Expanded(
                        child: GestureDetector(
                          onTap: vm.status == "0" ? () => vm.pickImage(context, id) : null,
                          child: vm.selectedImages[id]?.isNotEmpty == true
                              ? Image.file(
                            File(vm.selectedImages[id]!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : (c.commodity.image.isNotEmpty
                              ? Image.network(
                            "https://affairs.digitalnoticeboard.biz/submittedSurvey/${c.commodity.image}",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image, size: 40, color: Colors.grey)),
                        ),
                      ),

                    ],
                  ),
                );
              }).toList(),

              if (vm.assignedCommodities.isNotEmpty && vm.status=="0")
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: CustomButton(
                    title: vm.isLoading ? "Approving..." : "Approve",
                    onPressed: () {
                      if (!vm.isLoading) {
                        vm.approveSurvey(context);
                      }
                    },
                  ),
                ),

            ] else ...[
              const SizedBox(height: 150),
              const Center(
                child: Text(
                  "No submitted survey with this category",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ]


          ]
        ),
      ),
    );
  }
}

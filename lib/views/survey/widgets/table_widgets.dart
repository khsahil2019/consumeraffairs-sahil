import 'dart:developer';
import 'dart:io';
import 'package:cunsumer_affairs_app/data/models/survey_commodity_model.dart';
import 'package:cunsumer_affairs_app/data/models/survey_detail_model.dart';
import 'package:cunsumer_affairs_app/view_model/productSurvey/product_survey_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'image_utils.dart';

Widget buildCommodityTable(
    ProductSurveyDetailViewModel viewModel,
    double screenWidth,
    bool isLandscape,
    bool isTablet,
    double padding,
    BuildContext context) {
  final availableWidth = screenWidth - (padding * 2);
  final baseWidth = availableWidth / (isTablet ? 6 : 5);

  final commodityWidth = baseWidth * (isTablet ? 1.4 : 1.0);
  final brandWidth = baseWidth * (isTablet ? 1.2 : 0.9);
  final unitWidth = baseWidth * (isTablet ? 0.6 : 0.7);
  final priceWidth = baseWidth * (isTablet ? 0.6 : 0.8);
  final expiryWidth = baseWidth * (isTablet ? 1.0 : 1.7);
  final imageWidth = baseWidth * (isTablet ? 0.6 : 0.9);

  double scaleFactor = 1.0;
  final totalWidth = commodityWidth +
      brandWidth +
      unitWidth +
      priceWidth +
      expiryWidth +
      imageWidth;
  if (isTablet && totalWidth > availableWidth) {
    scaleFactor = availableWidth / totalWidth;
  }

  final adjustedCommodityWidth = commodityWidth * scaleFactor;
  final adjustedBrandWidth = brandWidth * scaleFactor;
  final adjustedUnitWidth = unitWidth * scaleFactor;
  final adjustedPriceWidth = priceWidth * scaleFactor;
  final adjustedExpiryWidth = expiryWidth * scaleFactor;
  final adjustedImageWidth = imageWidth * scaleFactor;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: isTablet
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTableHeader(
                  viewModel,
                  adjustedCommodityWidth,
                  adjustedBrandWidth,
                  adjustedUnitWidth,
                  adjustedPriceWidth,
                  adjustedExpiryWidth,
                  adjustedImageWidth,
                  isTablet),
              ...buildCommodityRows(
                  viewModel,
                  adjustedCommodityWidth,
                  adjustedBrandWidth,
                  adjustedUnitWidth,
                  adjustedPriceWidth,
                  adjustedExpiryWidth,
                  adjustedImageWidth,
                  isTablet,
                  context),
            ],
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: ScrollController(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: isLandscape ? screenWidth : screenWidth * 1.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTableHeader(viewModel, commodityWidth, brandWidth,
                      unitWidth, priceWidth, expiryWidth, imageWidth, isTablet),
                  ...buildCommodityRows(
                      viewModel,
                      commodityWidth,
                      brandWidth,
                      unitWidth,
                      priceWidth,
                      expiryWidth,
                      imageWidth,
                      isTablet,
                      context),
                ],
              ),
            ),
          ),
  );
}

Widget buildTableHeader(
    ProductSurveyDetailViewModel viewModel,
    double commodityWidth,
    double brandWidth,
    double unitWidth,
    double priceWidth,
    double expiryWidth,
    double imageWidth,
    bool isTablet) {
  bool isAnySubmitted =
      viewModel.isSubmitted.values.any((isSubmitted) => isSubmitted == true);
  bool isAnySaved = viewModel.isSaved.values.any((isSaved) => isSaved == true);

  Color headerColor;
  Color borderColor;
  if (isAnySubmitted) {
    headerColor = Colors.green.shade100;
    borderColor = Colors.white;
  } else if (isAnySaved) {
    headerColor = Colors.orange.shade100;
    borderColor = Colors.white;
  } else {
    headerColor = Colors.grey.shade100;
    borderColor = Colors.red.shade300;
  }

  return Container(
    padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 10, horizontal: 8),
    decoration: BoxDecoration(
      color: headerColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      border: Border(bottom: BorderSide(color: borderColor, width: 2)),
    ),
    child: Row(
      children: [
        _buildHeaderCell(
          "Commodity",
          commodityWidth,
          isTablet,
          align: TextAlign.left,
        ),
        _buildHeaderCell(
          "Brand",
          brandWidth,
          isTablet,
          align: TextAlign.left,
        ),
        _buildHeaderCell(
          "Unit",
          unitWidth,
          isTablet,
        ),
        _buildHeaderCell(
          "Price(\$)",
          priceWidth,
          isTablet,
        ),
        _buildHeaderCell(
          "Expiry Date",
          expiryWidth,
          isTablet,
        ),
        _buildHeaderCell(
          "Image",
          imageWidth,
          isTablet,
        ),
      ],
    ),
  );
}

Widget _buildHeaderCell(String text, double width, bool isTablet,
    {TextAlign align = TextAlign.center}) {
  return SizedBox(
    width: width,
    child: Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: isTablet ? 14 : 12,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

List<Widget> buildCommodityRows(
    ProductSurveyDetailViewModel viewModel,
    double commodityWidth,
    double brandWidth,
    double unitWidth,
    double priceWidth,
    double expiryWidth,
    double imageWidth,
    bool isTablet,
    BuildContext context) {
  if (viewModel.selectedCategory == null) {
    return [];
  }

  final displayedCommodities = viewModel.isValidationSuccess
      ? viewModel.validatedCommodities.where((commodity) {
          return viewModel.selectedCategory?.commodities
                  .any((c) => c.id == commodity.commodity?.id) ??
              false;
        }).toList()
      : viewModel.availableCommodities;

  return displayedCommodities.asMap().entries.map((entry) {
    final index = entry.key;
    final commodity = entry.value;
    final validatedCommodity =
        commodity is ValidatedCommodity ? commodity : null;
    final availableCommodity = commodity is Commodity ? commodity : null;
    int commodityId = validatedCommodity?.id ?? availableCommodity?.id ?? 0;

    viewModel.initializeControllers(commodityId);
    bool isEditable = viewModel.isEditable[commodityId] ?? true;

    final initialPrice =
        viewModel.priceControllers[commodityId]?.text ?? "null";
    log("Initial price for commodityId $commodityId: '$initialPrice'");

    return Container(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 6, horizontal: 4),
      decoration: BoxDecoration(
        color: viewModel.isSubmitted[commodityId] == true
            ? Colors.blue.shade50
            : viewModel.isSaved[commodityId] == true
                ? Colors.yellow.shade50
                : index % 2 == 0
                    ? Colors.white
                    : Colors.white,
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade400, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTextCell(
            validatedCommodity?.commodity?.name ??
                availableCommodity?.name ??
                "N/A",
            commodityWidth,
            isTablet,
            align: TextAlign.left,
          ),
          _buildTextCell(
            validatedCommodity?.brand?.name ??
                availableCommodity?.brand?.name ??
                "N/A",
            brandWidth,
            isTablet,
            align: TextAlign.left,
          ),
          _buildTextCell(
            validatedCommodity?.unit?.name ??
                availableCommodity?.uom?.name ??
                "N/A",
            unitWidth,
            isTablet,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: priceWidth,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    final id = validatedCommodity?.commodity?.id ??
                        availableCommodity?.id ??
                        0;
                    final controller = viewModel.priceControllers[id];
                    if (controller != null) {
                      String val = controller.text.trim();
                      double? parsed = double.tryParse(val);
                      String formatted =
                          parsed != null ? parsed.toStringAsFixed(2) : "";
                      controller.text = formatted;
                      viewModel.updatePrice(id, formatted);
                    }
                  }
                },
                child: TextField(
                  controller: viewModel.priceControllers[commodityId],
                  enabled: isEditable,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 4,
                      vertical: isTablet ? 10 : 6,
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                  textAlign: TextAlign.center,
                  onChanged: (val) {
                    final id = validatedCommodity?.commodity?.id ??
                        availableCommodity?.id ??
                        0;
                    viewModel.updatePrice(id, val);
                    viewModel.isPriceTouched[id] = true;
                  },
                  onSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: expiryWidth,
              child: TextField(
                controller: viewModel.expiryControllers[commodityId] ??
                    TextEditingController(text: ""),
                focusNode: viewModel.expiryFocusNodes[commodityId],
                readOnly: true,
                enabled: isEditable,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8 : 4,
                    vertical: isTablet ? 10 : 6,
                  ),
                  isDense: true,
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    size: isTablet ? 18 : 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                style: TextStyle(fontSize: isTablet ? 14 : 12),
                textAlign: TextAlign.center,
                onTap: isEditable
                    ? () async {
                        final result = await showModalBottomSheet<String?>(
                          context: context,
                          builder: (context) {
                            return Wrap(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.calendar_today,
                                      size: isTablet ? 24 : 20),
                                  title: Text(
                                    "Pick Date",
                                    style:
                                        TextStyle(fontSize: isTablet ? 14 : 12),
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2030),
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                      Navigator.pop(context, formattedDate);
                                    } else {
                                      Navigator.pop(context, null);
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.delete,
                                      size: isTablet ? 24 : 20,
                                      color: Colors.red),
                                  title: Text(
                                    "Remove Date",
                                    style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, "");
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        if (result != null) {
                          log("Selected expiry date for commodityId $commodityId: $result");
                          viewModel.updateExpiryDate(commodityId, result);
                        }
                      }
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: imageWidth,
              child: InkWell(
                onTap: isEditable
                    ? () async {
                        final picker = ImagePicker();
                        final XFile? pickedFile =
                            await showModalBottomSheet<XFile?>(
                          context: context,
                          builder: (context) {
                            return Wrap(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.photo,
                                      size: isTablet ? 24 : 20),
                                  title: Text(
                                    "Gallery",
                                    style:
                                        TextStyle(fontSize: isTablet ? 14 : 12),
                                  ),
                                  onTap: () async {
                                    Navigator.pop(
                                        context,
                                        await picker.pickImage(
                                            source: ImageSource.gallery));
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.camera_alt,
                                      size: isTablet ? 24 : 20),
                                  title: Text(
                                    "Camera",
                                    style:
                                        TextStyle(fontSize: isTablet ? 14 : 12),
                                  ),
                                  onTap: () async {
                                    Navigator.pop(
                                        context,
                                        await picker.pickImage(
                                            source: ImageSource.camera));
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.delete,
                                      size: isTablet ? 24 : 20,
                                      color: Colors.red),
                                  title: Text(
                                    "Remove Image",
                                    style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, null);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        if (pickedFile != null) {
                          log("Selected image for commodityId $commodityId: ${pickedFile.path}");
                          viewModel.updateImage(commodityId, pickedFile.path);
                        } else if (pickedFile == null &&
                            viewModel.selectedImages[commodityId] != null) {
                          log("Removed image for commodityId $commodityId");
                          viewModel.updateImage(commodityId, "");
                        }
                      }
                    : null,
                child: Consumer<ProductSurveyDetailViewModel>(
                  builder: (context, vm, _) {
                    final imagePath = vm.selectedImages[commodityId] ??
                        validatedCommodity?.commodityImageUrl ??
                        "";
                    log("Rendering image for commodityId $commodityId: $imagePath");
                    return Container(
                      width: imageWidth,
                      height: isTablet ? 60 : 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade50,
                      ),
                      child: buildImageWidget(imagePath, commodityId, isTablet),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }).toList();
}

Widget _buildTextCell(String text, double width, bool isTablet,
    {TextAlign align = TextAlign.center}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
          color: Colors.black87,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

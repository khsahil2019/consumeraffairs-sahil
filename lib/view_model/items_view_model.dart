import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cunsumer_affairs_app/views/dashBoard/dasboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/survey_list_screen.dart';

class ProductSurveyViewModel extends ChangeNotifier {
  String? selectedMarket;
  String? selectedCategory;
  String? selectedCommodity;
  String availabilityLevel = 'Moderate';
  File? selectedImage;

  Map<String, List<String>> categoryCommodities = {
    'Chicken Frozen': [
      'Leg Quarters',
      'Wings',
      'Drumsticks',
      'Backs',
      'Thighs',
      'Neck'
    ],
    'Meat': ['Beef', 'Pork'],
  };

  Map<String, String> commodityUnits = {
    'Leg Quarters': '0.5',
    'Wings': '1.0',
    'Drumsticks': '1.5',
    'Backs': '2.0',
    'Thighs': '0.8',
    'Neck': '0.3',
    'Beef': '0.2',
    'Pork': '7.3',
  };

  List<String> commodities = [];
  final brandController = TextEditingController(text: 'No brand');
  final unitController = TextEditingController();
  final priceController = TextEditingController();
  void updateCommodities(List<String> newCommodities) {
    commodities = newCommodities;
    notifyListeners();
  }

  void initializeCommodities() {
    if (selectedCategory != null) {
      commodities = categoryCommodities[selectedCategory!] ?? [];
    } else {
      commodities = [];
    }
    notifyListeners();
  }

  void updateCategory(String? category) {
    selectedCategory = category;
    commodities = categoryCommodities[category] ?? [];
    selectedCommodity = null;
    unitController.clear();
    notifyListeners();
  }

  void updateCommodity(String? value) {
    selectedCommodity = value;
    unitController.text = commodityUnits[value] ?? '';
    notifyListeners();
  }

  void updateAvailability(String? value) {
    availabilityLevel = value!;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<bool> checkInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> submitSurvey() async {
    print('Survey submitted!');
  }

  Future<void> saveSurveyOffline(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final newSurvey = {
      'market': selectedMarket,
      'category': selectedCategory,
      'commodity': selectedCommodity,
      'brand': brandController.text,
      'unit': unitController.text,
      'price': priceController.text,
      'availability': availabilityLevel,
    };

    final savedSurveyList = prefs.getStringList('offline_surveys') ?? [];

    savedSurveyList.insert(0, jsonEncode(newSurvey));

    await prefs.setStringList('offline_surveys', savedSurveyList);

    print('Survey saved offline!');

    Fluttertoast.showToast(
      msg: "Survey saved successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

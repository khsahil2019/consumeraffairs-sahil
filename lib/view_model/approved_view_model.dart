import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../data/models/approved_commodity_model.dart';
import '../data/models/approved_list_model.dart';
import '../data/repositories/auth_repositories.dart';
import '../data/services/api_services.dart';

class ApprovedViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository(apiService: ApiService());

  ApprovedDetailModel? approvedSurveyDetail;
  List<AssignedCommodityModel> assignedCommodities = [];
  String errorMessage = '';
  bool isLoading = false;
  bool isCommodityLoading = false;
  int? fetchedSurveyId;
  int? fetchedZoneId;
  String zoneName = '';
  String status = " ";
  bool get isSurveyApprovable =>status=="1" ;


  ApprovedMarket? selectedMarket;
  ApprovedCategory? selectedCategory;
  List<ApprovedMarket> markets = [];
  List<ApprovedCategory> categories = [];
  Map<int, TextEditingController> priceControllers = {};
  Map<int, TextEditingController> expiryControllers = {};
  Map<int, FocusNode> expiryFocusNodes = {};
  Map<int, String?> selectedImages = {};
  Map<int, String?> priceErrors = {};



  // void setSelectedMarket(ApprovedMarket? market) {
  //   selectedMarket = market;
  //   notifyListeners();
  // }
  //
  // void setSelectedCategory(ApprovedCategory? category) async {
  //   selectedCategory = category;
  //   notifyListeners();
  //
  //   if (category != null && selectedMarket != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userId = prefs.getInt('user_id') ?? 0;
  //     await fetchAssignedCommodities(
  //
  //       userId: userId!,
  //       surveyId: fetchedSurveyId!,
  //       marketId: selectedMarket!.id,
  //       categoryId: category.id,
  //     );
  //   }
  // }

  void setSelectedMarket(ApprovedMarket? market) {
    selectedMarket = market;
    selectedCategory = null;
    assignedCommodities = []; // Reset commodity list
    notifyListeners();
  }

  // Future<void> setSelectedCategory(ApprovedCategory? category) async {
  //   selectedCategory = category;
  //   if (category != null && selectedMarket != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userId = prefs.getInt('user_id') ?? 0;
  //     fetchAssignedCommodities(
  //       userId: userId,
  //       surveyId: fetchedSurveyId!,
  //       marketId: selectedMarket!.id,
  //       categoryId: selectedCategory!.id,
  //     );
  //   }
  //   notifyListeners();
  // }
  void setSelectedCategory(ApprovedCategory? category) async {
    selectedCategory = category;
    assignedCommodities = [];
    isCommodityLoading = true; // <-- add this as a bool in ViewModel
    notifyListeners();

    if (category != null && selectedMarket != null) {
      final prefs = await SharedPreferences.getInstance();
           final userId = prefs.getInt('user_id') ?? 0;
      await fetchAssignedCommodities(
        userId: userId,
        surveyId: fetchedSurveyId!,
        marketId: selectedMarket!.id,
        categoryId: selectedCategory!.id,
      );
    }


    isCommodityLoading = false;
    notifyListeners();

  }


  void initControllers() {
    for (var item in assignedCommodities) {
      final id = item.commodity.id;

      // Only initialize if null
      priceControllers[id] ??= TextEditingController(text: item.amount ?? '');
      expiryControllers[id] ??= TextEditingController(text: item.commodityExpiryDate ?? '');
      expiryFocusNodes[id] ??= FocusNode();
      selectedImages[id] ??= item.commodityImage ?? '';
    }
  }




  Future<void> fetchAssignedSurveyDetail(int surveyId) async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final detail = await _authRepository.getAssignedSurveyDetail(
        bearerToken: token,
        id: surveyId,
      );

      fetchedSurveyId = detail.id;
      fetchedZoneId = detail.zoneId;
      zoneName = detail.zone.name;

      markets = detail.markets;
      categories = detail.categories;

      selectedMarket = null;
      selectedCategory = null;
      assignedCommodities.clear();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
  Future<void> fetchAssignedCommodities({
    required int userId,
    required int surveyId,
    required int marketId,
    required int categoryId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print("userId$userId");
      print("surveyId$surveyId");
      print("market$marketId");
      print("category$categoryId");

      assignedCommodities = await _authRepository.getAssignedSurveyCommodities(
        bearerToken: token,
        userId: userId,
        surveyId: surveyId,
        marketId: marketId,
        categoryId: categoryId,
      );
      status = assignedCommodities.isNotEmpty ? assignedCommodities.first.status : "0";



      // ✅ Initialize controllers for each commodity
      for (var item in assignedCommodities) {
        priceControllers[item.commodity.id] = TextEditingController(text: item.amount ?? '');
        expiryControllers[item.commodity.id] = TextEditingController(text: item.commodityExpiryDate ?? '');
        expiryFocusNodes[item.commodity.id] = FocusNode();
      }

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching assigned commodities: $e");
    }
  }


  // void initControllers(int marketId, int categoryId) {
  //   priceControllers.clear();
  //   expiryControllers.clear();
  //   expiryFocusNodes.clear();
  //   selectedImages.clear();
  //
  //   for (var item in assignedCommodities) {
  //     if (item.marketId == marketId && item.categoryId == categoryId) {
  //       int id = item.commodity.id;
  //       priceControllers[id] = TextEditingController(text: item.amount ?? '');
  //       expiryControllers[id] = TextEditingController(text: item.commodityExpiryDate ?? '');
  //       expiryFocusNodes[id] = FocusNode();
  //       selectedImages[id] = item.commodityImage ?? '';
  //     }
  //   }
  // }



  void updatePrice(int id, String value) {
    if (priceControllers[id]?.text != value) {
      priceControllers[id]?.text = value;
      notifyListeners();
    }
  }


  void updateExpiryDate({
    required int id,
    required String date,
    bool isFromController = true,
  }) {
    expiryControllers[id]?.text = date;
    notifyListeners(); // ✅ reflects even if cleared or updated
  }

  Future<void> pickExpiryDate(BuildContext context, int id) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      // ✅ Update the controller + internal state
      updateExpiryDate(id: id, date: formattedDate, isFromController: true);
    }
  }

  void updateImage(int id, String path) {
    selectedImages[id] = path;
    notifyListeners(); // ✅ re-render image widget
  }


  Future<void> pickImage(BuildContext context, int commodityId) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      updateImage(commodityId, pickedFile.path);
    }
  }
  Future<void> approveSurvey(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getInt('user_id') ?? 0;

      isLoading = true;
      notifyListeners();

      final List<int> commodityIds = [];
      final List<int> unitIds = [];
      final List<int> brandIds = [];
      final List<String> amounts = [];
      final List<String> availabilities = [];
      final List<String> expiryDates = [];
      final List<int> submittedSurveyIds = [];

      for (var commodity in assignedCommodities) {
        final id = commodity.commodityId;

        commodityIds.add(id);
        unitIds.add(commodity.unitId ?? 0);
        brandIds.add(commodity.brandId ?? 0);
        amounts.add(priceControllers[id]?.text.trim() ?? "0");
        availabilities.add("moderate"); // or any logic to handle this
        expiryDates.add(expiryControllers[id]?.text ?? "");
        submittedSurveyIds.add(commodity.id); // 👍 This is the submitted survey ID
      }
      print("userId$userId");
      print("zoneId$fetchedZoneId");
      print("surveyId$fetchedSurveyId");
      print("selectedMarket${selectedMarket!.id}");
      print("submittedBy${userId}");
      print("commodityIds${commodityIds}");
      print("unitIds${unitIds}");
      print("brandIds${brandIds}");
      print("amounts${amounts}");
      print("expiryDates${expiryDates}");
      print("submittedSurveyIds${submittedSurveyIds}");

      final message = await _authRepository.approveSurvey(
        bearerToken: token,
        userId: userId,
        zoneId: fetchedZoneId!,
        surveyId: fetchedSurveyId!,
        marketId: selectedMarket!.id,
        categoryId: selectedCategory!.id,
        submittedBy: userId,
        commodityIds: commodityIds,
        unitIds: unitIds,
        brandIds: brandIds,
        amounts: amounts,

        expiryDates: expiryDates,
        submittedSurveyIds: submittedSurveyIds,
      );

      Fluttertoast.showToast(msg: message, backgroundColor: Colors.green);

    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
      print("message${e.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  void clear() {
    priceControllers.clear();
    expiryControllers.clear();
    expiryFocusNodes.clear();
    selectedImages.clear();
    selectedMarket = null;
    selectedCategory = null;
    assignedCommodities = [];
    zoneName = '';
    fetchedSurveyId = null;
    fetchedZoneId = null;
    notifyListeners();
  }

}

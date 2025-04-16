import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _selectedTab = 0;
  final TextEditingController searchController = TextEditingController();

  final List<String> tab1Data = ["Super Market", "City Bazar", "Bazar"];
  final List<String> tab2Data = ["Market 1", "Market 2", "Market 3"];

  List<String> _filteredData = [];
  List<String> get filteredData => _filteredData;

  String? _selectedItem;
  String? get selectedItem => _selectedItem;

  HomeViewModel() {
    _filteredData = tab1Data;
  }

  int get selectedTab => _selectedTab;

  void selectTab(int tabIndex) {
    _selectedTab = tabIndex;
    _filteredData = _selectedTab == 0 ? tab1Data : tab2Data;
    filterData(searchController.text); // Reapply the filter
    notifyListeners();
  }

  void filterData(String searchTerm) {
    List<String> data = _selectedTab == 0 ? tab1Data : tab2Data;
    _filteredData = data
        .where((item) => item.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void setSelectedItem(String item) {
    _selectedItem = item;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

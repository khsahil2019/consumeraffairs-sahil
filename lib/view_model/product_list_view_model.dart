// import 'package:flutter/material.dart';

// class Product {
//   final String name;
//   final String category;
//   final String price;
//   final String addedDate;
//   final String location;
//   final String imageUrl;

//   Product({
//     required this.name,
//     required this.category,
//     required this.price,
//     required this.addedDate,
//     required this.location,
//     required this.imageUrl,
//   });
// }

// class ProductListViewModel extends ChangeNotifier {
//   List<Product> _products = [];
//   List<Product> _filteredProducts = [];
//   final TextEditingController searchController = TextEditingController();

//   String? selectedFilter;
//   String? selectedSort;

//   final List<String> filters = ['All', 'Category A', 'Category B'];
//   final List<String> sortOptions = ['Price Low to High', 'Price High to Low'];

//   ProductListViewModel() {
//     _loadProducts();
//   }

//   List<Product> get filteredProducts => _filteredProducts;

//   void _loadProducts() {
//     _products = [
//       Product(
//         name: 'Leg Quarters',
//         category: 'Meat',
//         price: '\$20',
//         addedDate: '12 Oct 2024',
//         location: 'ABC',
//         imageUrl: 'https://via.placeholder.com/50',
//       ),
//       Product(
//         name: 'Cheddar Cheese',
//         category: 'Processed Cheese',
//         price: '\$20',
//         addedDate: '12 Oct 2024',
//         location: 'ABC',
//         imageUrl: 'https://via.placeholder.com/50',
//       ),
//       Product(
//         name: 'Medicated Soap',
//         category: 'Soap',
//         price: '\$20',
//         addedDate: '12 Oct 2024',
//         location: 'ABC',
//         imageUrl: 'https://via.placeholder.com/50',
//       ),
//     ];
//     _filteredProducts = _products;
//     notifyListeners();
//   }

//   void searchProducts(String query) {
//     if (query.isEmpty) {
//       _filteredProducts = _products;
//     } else {
//       _filteredProducts = _products
//           .where((product) =>
//               product.name.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     }
//     notifyListeners();
//   }

//   void filterProducts(String filter) {
//     selectedFilter = filter;
//     if (filter == 'All') {
//       _filteredProducts = _products;
//     } else {
//       _filteredProducts =
//           _products.where((product) => product.category == filter).toList();
//     }
//     notifyListeners();
//   }

//   void sortProducts(String sortOption) {
//     selectedSort = sortOption;
//     if (sortOption == 'Price Low to High') {
//       _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
//     } else if (sortOption == 'Price High to Low') {
//       _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
//     }
//     notifyListeners();
//   }
// }

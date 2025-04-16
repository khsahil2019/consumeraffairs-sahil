// import 'package:cunsumer_affairs_app/views/home_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../view_model/product_list_view_model.dart';
// import '../widgets/custom_app_bar.dart';
// import '../widgets/custom_drawer.dart';

// class ProductListScreen extends StatelessWidget {
//   final String? surveyName;

//   ProductListScreen({this.surveyName});
//   final FocusNode focusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.watch<ProductListViewModel>();

//     return Scaffold(
//       appBar: CustomAppBar(
//         focusNode: focusNode,
//         title: 'Submitted Commodity ',
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Search Field
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         labelText: 'Search',
//                         prefixIcon: Icon(Icons.search),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Filter Dropdown
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: DropdownButton<String>(
//                     hint: Text('Filter'),
//                     items: ['Option 1', 'Option 2', 'Option 3']
//                         .map((filter) => DropdownMenuItem<String>(
//                               value: filter,
//                               child: Text(filter),
//                             ))
//                         .toList(),
//                     onChanged: (value) {},
//                     icon: Icon(Icons.filter_list),
//                   ),
//                 ),

//                 // Sort Dropdown
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: DropdownButton<String>(
//                     hint: Text('Sort'),
//                     items: ['Ascending', 'Descending']
//                         .map((sort) => DropdownMenuItem<String>(
//                               value: sort,
//                               child: Text(sort),
//                             ))
//                         .toList(),
//                     onChanged: (value) {},
//                     icon: Icon(Icons.sort),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: viewModel.filteredProducts.length,
//                 itemBuilder: (context, index) {
//                   final product = viewModel.filteredProducts[index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey), // Grey border
//                         borderRadius: BorderRadius.circular(
//                             12), // Match Card's border radius
//                       ),
//                       child: ListTile(
//                         leading: Image.asset(
//                           "assets/images/city_bazar_logo.png",
//                           width: 50,
//                           height: 50,
//                           fit: BoxFit.cover,
//                         ),
//                         title: Text(
//                           product.name,
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(product.category,
//                                 style: TextStyle(color: Colors.red)),
//                             Text('Price: ${product.price}'),
//                             Text('Location: ${product.location}'),
//                             Text('Added on ${product.addedDate}'),
//                           ],
//                         ),
//                         onTap: () {
//                           // Navigate to ProductSurveyDetailsScreen and pass the product details
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) => ProductSurveyDetailsScreen(
//                           //       product: product,
//                           //     ),
//                           //   ),
//                           // );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomePage(),
//             ),
//           );
//           // Implement action to add a new product
//         },
//         child: Icon(Icons.add),
//         backgroundColor: Colors.green,
//       ),
//       endDrawer: CustomEndDrawer(),
//     );
//   }
// }

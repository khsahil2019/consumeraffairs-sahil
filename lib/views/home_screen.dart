// import 'package:cunsumer_affairs_app/views/category_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';

// import '../view_model/home_view_model.dart';
// import '../widgets/custom_app_bar.dart';
// import '../widgets/custom_drawer.dart';

// class HomePage extends StatelessWidget {

//   final FocusNode focusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(focusNode: focusNode, title: 'Markets',), // Pass the FocusNode here
//       body: Consumer<HomeViewModel>(
//         builder: (context, viewModel, child) {
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Select Market",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),


//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey, width: 1),
//                       ),
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: "Search here",
//                           hintStyle: TextStyle(color: Colors.grey),
//                           prefixIcon: Icon(Icons.search, color: Colors.grey),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         ),
//                         onChanged: (value) {

//                           print("Search value: $value");
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),


//               SizedBox(height: 10),




//               Expanded(
//                 child: ListView.builder(
//                   itemCount: viewModel.filteredData.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                       child: GestureDetector(
//                         onTap: () {
//                           viewModel.setSelectedItem(viewModel.filteredData[index]);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CategoryPage(
//                                 itemName: viewModel.filteredData[index],
//                               ),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               children: [
//                                 Image.asset(
//                                  "assets/images/super_market_logo.png"
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     viewModel.filteredData[index],
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                                 Spacer(),
//                                 SvgPicture.asset(
//                                   'assets/svgs/arrow-up-right.svg',
//                                   color: Colors.green,
//                                   width: 18,
//                                   height: 18,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                       ),
//                     );
//                   },
//                 ),
//               ),



//             ],
//           );
//         },
//       ),
//       endDrawer: CustomEndDrawer(),
//     );
//   }
//   Widget _buildTab(String title, int tabIndex, BuildContext context, int count, IconData icon) {
//     final viewModel = Provider.of<HomeViewModel>(context, listen: false);
//     return GestureDetector(
//       onTap: () {
//         viewModel.selectTab(tabIndex);
//       },
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(
//                 icon,
//                 color: viewModel.selectedTab == tabIndex ? Colors.blue : Colors.black,
//               ),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w400,
//                   color: viewModel.selectedTab == tabIndex ? Colors.blue : Colors.black,
//                 ),
//               ),
//               SizedBox(width: 8),
//               Text(
//                 '$count',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w400,
//                   color: viewModel.selectedTab == tabIndex ? Colors.blue : Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }





// }

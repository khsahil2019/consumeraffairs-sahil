// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';

// import '../view_model/category_view_model.dart';
// import '../widgets/custom_app_bar.dart';
// import '../widgets/custom_drawer.dart';
// import 'items_screen.dart';

// class CategoryPage extends StatelessWidget {
//   final String? itemName;

//   CategoryPage({this.itemName});
//   final FocusNode focusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(focusNode: focusNode, title: ' Categories',),
//       body: Consumer<CategoryViewModel>(
//         builder: (context, viewModel, child) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   itemName!,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: viewModel.categoryList.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SubmitProductSurveyScreen(
//                               itemName: itemName,
//                               categoryName: viewModel.categoryList[index],
//                             ),
//                           ),
//                         );

//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
//                                     "assets/images/city_bazar_logo.png"
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     viewModel.categoryList[index],
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                                 Spacer(), // Pushes arrow icon to the right
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
// }

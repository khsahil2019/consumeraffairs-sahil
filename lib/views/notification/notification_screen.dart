// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../view_model/notification_view_model.dart';
// import '../../widgets/custom_app_bar.dart';
// import '../../widgets/custom_drawer.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class NotificationScreen extends StatelessWidget {
//   final FocusNode focusNode = FocusNode();

//   Future<bool> _isInternetAvailable() async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     return connectivityResult != ConnectivityResult.none;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => NotificationViewModel(),
//       child: Scaffold(
//         appBar: CustomAppBar(title: "Notifications", focusNode: focusNode),
//         body: FutureBuilder<bool>(
//           future: _isInternetAvailable(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             final isOnline = snapshot.data!;
//             final viewModel = Provider.of<NotificationViewModel>(context, listen: false);

//             // Fetch notifications based on connectivity
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (isOnline) {
//                 viewModel.fetchNotifications();
//               } else {
//                 viewModel.loadCachedNotifications();
//               }
//             });

//             return Consumer<NotificationViewModel>(
//               builder: (context, viewModel, _) {
//                 if (viewModel.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!isOnline && viewModel.notifications.isEmpty) {
//                   return const Center(
//                     child: Text('Offline. No cached notifications available.'),
//                   );
//                 }

//                 if (isOnline && viewModel.errorMessage.isNotEmpty) {
//                   return Center(child: Text(viewModel.errorMessage));
//                 }

//                 return viewModel.notifications.isEmpty
//                     ? const Center(child: Text('No notifications found.'))
//                     : Column(
//                         children: [
//                           if (!isOnline)
//                             Container(
//                               color: Colors.orange[100],
//                               padding: const EdgeInsets.all(8.0),
//                               width: double.infinity,
//                               child: const Text(
//                                 'Offline. Showing cached notifications.',
//                                 style: TextStyle(color: Colors.orange),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           Expanded(
//                             child: ListView.builder(
//                               padding: const EdgeInsets.all(16.0),
//                               itemCount: viewModel.notifications.length,
//                               itemBuilder: (context, index) {
//                                 final notification = viewModel.notifications[index];

//                                 return Card(
//                                   elevation: 2,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: ListTile(
//                                     title: Text(
//                                       notification['title'] ?? 'No Title',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     subtitle: Text(notification['message'] ?? 'No Message'),
//                                     trailing: notification['is_read'] == false
//                                         ? const Icon(Icons.notifications_active,
//                                             color: Colors.red)
//                                         : const Icon(Icons.notifications_none,
//                                             color: Colors.grey),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//               },
//             );
//           },
//         ),
//         endDrawer: CustomEndDrawer(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/notification_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NotificationScreen extends StatelessWidget {
  final FocusNode focusNode = FocusNode();

  Future<bool> _isInternetAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(title: "Notifications", focusNode: focusNode),
        body: FutureBuilder<bool>(
          future: _isInternetAvailable(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final isOnline = snapshot.data!;
            final viewModel =
                Provider.of<NotificationViewModel>(context, listen: false);

            // Fetch or load cached notifications
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isOnline) {
                viewModel.fetchNotifications();
              } else {
                viewModel.loadCachedNotifications();
              }
            });

            return Consumer<NotificationViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!isOnline && viewModel.notifications.isEmpty) {
                  return const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Offline No cached notifications available.'),
                      ],
                    ),
                  );
                }

                // Only show error message if online and an error occurred
                if (isOnline && viewModel.errorMessage.isNotEmpty) {
                  return Center(child: Text(viewModel.errorMessage));
                }

                return viewModel.notifications.isEmpty
                    ? const Center(child: Text('No notifications found.'))
                    : Column(
                        children: [
                          if (!isOnline)
                            Container(
                              color: Colors.orange[100],
                              padding: const EdgeInsets.all(8.0),
                              width: double.infinity,
                              child: const Text(
                                'Offline. Showing cached notifications.',
                                style: TextStyle(color: Colors.orange),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: viewModel.notifications.length,
                              itemBuilder: (context, index) {
                                final notification =
                                    viewModel.notifications[index];

                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      notification['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(notification['message'] ??
                                        'No Message'),
                                    trailing: notification['is_read'] == false
                                        ? const Icon(Icons.notifications_active,
                                            color: Colors.red)
                                        : const Icon(Icons.notifications_none,
                                            color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
              },
            );
          },
        ),
        endDrawer: CustomEndDrawer(),
      ),
    );
  }
}

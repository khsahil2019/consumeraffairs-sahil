import 'dart:async'; // For StreamSubscription
import 'dart:developer';

import 'package:cunsumer_affairs_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For network checking

import '../../view_model/dashboard_view_model.dart';
import '../../view_model/profile_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/task_card.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FocusNode focusNode = FocusNode();
  bool isOfflineData = false;
  bool isOnline = true; // Track network status

  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      _checkAndUpdateConnectivity(); // Ensure initial check
    });

    // Set up real-time connectivity listener
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);

    // Initial connectivity check
    _checkInitialConnectivity();
  }

  // Method to update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      isOnline = result != ConnectivityResult.none;
    });
  }

  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  // Additional method to manually check and update connectivity
  Future<void> _checkAndUpdateConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  @override
  void dispose() {
    focusNode.dispose();
    connectivitySubscription.cancel(); // Clean up the subscription
    super.dispose();
  }

  Future<void> _fetchData() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);

    await profileVM.fetchProfile();
    await dashboardVM.loadOfflineSurveys();

    if (dashboardVM.tasks.isNotEmpty) {
      setState(() => isOfflineData = true);
    }

    if (isOnline) {
      await dashboardVM.fetchSurveyList();
      setState(() => isOfflineData = false);
    } else {
      setState(
          () => isOfflineData = true); // Force offline mode if no connection
    }
  }

  // Handle back button press with confirmation dialog
  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: AppColors.primaryColor,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'Exit App',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Stay in app
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit app
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false; // Return false if dialog is dismissed (e.g., tapping outside)
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final dashboardVM = Provider.of<DashboardViewModel>(context);

    return WillPopScope(
      onWillPop: _onWillPop, // Intercept back button press
      child: Scaffold(
        appBar: CustomAppBar(
          focusNode: focusNode,
          title: 'Welcome, ${profileVM.name}!',
          profileImagePath:
              profileVM.image != null && profileVM.image!.isNotEmpty
                  ? profileVM.image
                  : 'assets/images/profile_pic.png',
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _checkAndUpdateConnectivity(); // Check connectivity before refresh
            await _fetchData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics Section
                Row(
                  children: [
                    MetricCard(
                      title: "Total Surveys",
                      value: profileVM.totalSubmissions.toString(),
                      icon: Icons.insert_drive_file,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    MetricCard(
                      title: "Pending Data",
                      value: profileVM.pendingData.toString(),
                      icon: Icons.pending_outlined,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    MetricCard(
                      title: "Overdue Data",
                      value: profileVM.overdueData.toString(),
                      icon: Icons.cloud_off,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    MetricCard(
                      title: "Completed Data",
                      value: profileVM.completedData.toString(),
                      icon: Icons.check_circle,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Assigned Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: dashboardVM.tasks.isEmpty
                      ? const Center(
                          child: Text(
                            "No task assigned.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : Column(
                          children: [
                            if (dashboardVM.isOfflineData || !isOnline)
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.wifi_off, color: Colors.black),
                                    SizedBox(width: 5),
                                    Text(
                                      "Showing offline data",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: dashboardVM.tasks.length,
                                itemBuilder: (context, index) {
                                  final survey = dashboardVM.tasks[index];
                                  return GestureDetector(
                                    onTap: () {
                                      log('''
📋 Task Tapped:
────────────────────────────
🆔 ID           : ${survey.id}
🧾 Survey Code  : ${survey.surveyId}
📌 Name         : ${survey.name}
📍 Zone         : ${survey.zone?.name ?? 'N/A'}
📅 Start        : ${survey.startDate}
📅 End          : ${survey.endDate}
✅ Status       : ${survey.status}
🕒 Created At   : ${survey.createdAt}

────────────────────────────
''');
                                    },
                                    child: TaskCard(survey: survey),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        endDrawer: CustomEndDrawer(),
      ),
    );
  }
}

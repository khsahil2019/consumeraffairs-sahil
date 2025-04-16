import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/dashBoard/dasboard_screen.dart';
import '../views/faq/help_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/saved_survey_list.dart';
import '../views/survey_list_screen.dart';
import '../views/notification/notification_screen.dart';

class CustomEndDrawer extends StatefulWidget {
  @override
  State<CustomEndDrawer> createState() => _CustomEndDrawerState();
}

class _CustomEndDrawerState extends State<CustomEndDrawer> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getSelectedIndex();
  }

  Future<void> _getSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt('selected_index') ?? 0;
    });
  }

  Future<void> _setSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_index', index);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
          _buildDrawerItem(context, 'Dashboard', "assets/svgs/dashboard.svg",
              DashboardScreen(), 0),
          _buildDrawerItem(context, 'Submitted Surveys',
              "assets/svgs/survey.svg", const SurveyListScreen(), 1),
          _buildDrawerItem(context, 'In-Progress Surveys',
              "assets/svgs/survey.svg", const SurveySavedListScreen(), 2),
          _buildDrawerItem(context, 'Notification', "assets/svgs/bell.svg",
              NotificationScreen(), 3),
          _buildDrawerItem(context, 'Help', "assets/svgs/alert-circle.svg",
              const HelpScreen(), 4),
          _buildDrawerItem(context, 'My Profile', "assets/svgs/user.svg",
              ProfileScreen(), 5),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String iconPath,
      Widget page, int index) {
    bool isSelected = selectedIndex == index;

    return ListTile(
      leading: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isSelected ? const Color(0xFF006738) : Colors.black,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF006738) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor:
          isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () async {
        if (selectedIndex == index) {
          Navigator.pop(context);
          return;
        }

        setState(() {
          selectedIndex = index;
        });
        await _setSelectedIndex(index);

        Navigator.pop(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page, // ✅ Navigate to the correct page
              ),
            );
          }
        });
      },
    );
  }

  ListTile _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        "assets/svgs/loginout.svg",
        width: 24,
        height: 24,
        color: Colors.black,
      ),
      title: const Text('Logout'),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.green,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);

                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      await prefs.remove('user_id');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Logged out successfully')),
                      );
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login_screen', (route) => false);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child:
                      const Text('Yes', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

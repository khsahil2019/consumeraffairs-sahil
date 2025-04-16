import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final FocusNode? focusNode;
  final String title;
  final String? profileImagePath;
  final bool showBackButton;
  final bool showMenu;

  CustomAppBar({
    this.focusNode,
    required this.title,
    this.profileImagePath,
    this.showBackButton = false,
    this.showMenu = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth > 600 ? 24.0 : 16.0;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: padding),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF01E77E),
              Color(0xFF006738),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: CustomAppBarContent(
          focusNode: focusNode,
          title: title,
          profileImagePath: profileImagePath,
          screenWidth: screenWidth,
          showBackButton: showBackButton,
          showMenu: showMenu,
        ),
      ),
    );
  }
}

class CustomAppBarContent extends StatelessWidget {
  final FocusNode? focusNode;
  final String title;
  final String? profileImagePath;
  final double screenWidth;
  final bool? showBackButton;
  final bool? showMenu;

  CustomAppBarContent({
    this.focusNode,
    required this.title,
    this.profileImagePath,
    required this.screenWidth,
    this.showBackButton = false,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: 12, right: 0, top: screenWidth > 600 ? 40 : 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton!)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          if (profileImagePath != null)
            Container(
              padding: const EdgeInsets.all(2), // Padding to show white border
              decoration: const BoxDecoration(
                color: Colors.white, // White background
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CustomImageView(
                  imageUrl: profileImagePath!,
                  size: screenWidth > 600 ? 50 : 38,
                ),
              ),
            ),
          if (profileImagePath != null) const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                fontSize: screenWidth > 600 ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          if (showMenu!)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
        ],
      ),
    );
  }
}

class CustomImageView extends StatelessWidget {
  final String? imageUrl;
  final double size;

  CustomImageView({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl ?? '', // Use an empty string if null
      height: size,
      width: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/profile_pic.png', // Fallback image
          height: size,
          width: size,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

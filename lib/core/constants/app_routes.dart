import 'package:cunsumer_affairs_app/views/category_screen.dart';
import 'package:cunsumer_affairs_app/views/dashBoard/dasboard_screen.dart';
import 'package:cunsumer_affairs_app/views/home_screen.dart';
import 'package:cunsumer_affairs_app/views/items_screen.dart';
import 'package:cunsumer_affairs_app/views/auth/login_screen.dart';
import 'package:cunsumer_affairs_app/views/product_list_screen.dart';
import 'package:cunsumer_affairs_app/views/survey/product_survey_screen.dart';
import 'package:cunsumer_affairs_app/views/auth/password/set_password_screen.dart';
import 'package:cunsumer_affairs_app/views/survey_list_screen.dart';
import '../../views/approved_screen.dart';
import '../../views/auth/password/change_password_screen.dart';
import '../../views/commodity_details_screen.dart';
import '../../views/auth/password/forget_pass_screen.dart';
import '../../views/auth/otp_verify_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/saved_survey_list.dart';
import '../../views/splash_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash';
  static const String loginScreen = '/login_screen';
  static const String homeScreen = '/home_screen';
  static const String forgetPassScreen = '/forget_pass_screen';
  static const String otpScreen = '/otp_screen';
  static const String changePassScreen = '/change_pass_screen';
  static const String setPasswordScreen = '/set_pass_screen';
  static const String categoryScreen = '/category_screen';
  static const String itemsScreen = '/items_screen';
  static const String dashboardScreen = '/dashboard_screen';
  static const String surveyListScreen = '/survey_list_screen';
  static const String surveySavedListScreen = '/survey_saved_list_screen';
  static const String productListScreen = '/product_list_screen';
  static const String profileScreen = '/profile_screen';
  static const String productSurveyScreen = '/product_survey_screen';
  static const String surveyDetailsScreen = '/survey_details_screen';
  static const String approvedScreen = '/approved_screen';

  static final pages = {
    splashScreen: (context) => SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    //homeScreen: (context) => HomePage(),
    forgetPassScreen: (context) => const ForgotPasswordScreen(),
    otpScreen: (context) => const VerifyOtpScreen(),
    changePassScreen: (context) => const ChangePasswordScreen(),
    setPasswordScreen: (context) => const SetNewPasswordScreen(),
    //  categoryScreen: (context) => CategoryPage(),
    itemsScreen: (context) => SubmitProductSurveyScreen(),
    dashboardScreen: (context) => DashboardScreen(),
    surveyListScreen: (context) => const SurveyListScreen(),
    surveySavedListScreen: (context) => const SurveySavedListScreen(),
    // productListScreen: (context) => ProductListScreen(),
    profileScreen: (context) => ProfileScreen(),
    productSurveyScreen: (context) => const ProductSurveyDetailsScreen(),
    surveyDetailsScreen: (context) => const SurveyDetailsScreen(),
    approvedScreen: (context) => const ApprovedScreen(),
    // Add more routes here
  };
}

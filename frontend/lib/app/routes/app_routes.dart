import 'package:bid_hub/app/components/seller_profile.dart';
import 'package:bid_hub/app/components/user_profile.dart';
import 'package:flutter/material.dart';
import '../ui/views/login.dart';
import '../ui/views/home/home.dart';
import '../ui/views/forgot_password.dart';
import '../ui/views/registration.dart';
import '../ui/views/welcome.dart';
import '../ui/views/search.dart';
import '../ui/views/account/buyer/orders.dart';
import '../ui/views/account/buyer/my_bids.dart';
import '../ui/views/account/seller/choose_auction_type.dart';
import '../ui/views/account/seller/fixed_time_auction.dart';
import '../ui/views/account/seller/english_auction.dart';
import '../ui/views/account/seller/reverse_auction.dart';
import '../ui/views/account/seller/silent_auction.dart';
import '../ui/views/account/seller/in_progess.dart';
import '../ui/views/account/seller/sold.dart';
import '../ui/views/account/seller/unsold.dart';
import '../ui/views/account/settings/addresses.dart';
import '../ui/views/account/settings/payment.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String forgotPassword = '/forgot_password';
  static const String registration = '/registration';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String myBids = '/my_bids';
  static const String inProgess = '/in_progess';
  static const String sold = '/sold';
  static const String unsold = '/unsold';
  static const String userProfile = '/account';
  static const String sellerProfile = '/seller';
  static const String chooseAuctionType = '/choose_auction_type';
  static const String fixedTimeAuction = '/fixed_time_auction';
  static const String englishAuction = '/english_auction';
  static const String reverseAuction = '/reverse_auction';
  static const String silentAuction = '/silent_auction';
  static const String addresses = '/addresses';
  static const String payments = '/payments';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const Home());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
      case registration:
        return MaterialPageRoute(builder: (_) => RegistrationPage());
      case search:
        return MaterialPageRoute(builder: (_) => SearchPage());
      case orders:
        return MaterialPageRoute(builder: (_) => OrdersPage());
      case myBids:
        return MaterialPageRoute(builder: (_) => const MyBidsPage());
      case chooseAuctionType:
        return MaterialPageRoute(builder: (_) => const ChooseAuctionTypePage());
      case fixedTimeAuction:
        return MaterialPageRoute(builder: (_) => const FixedTimeAuctionPage());
      case englishAuction:
        return MaterialPageRoute(builder: (_) => const EnglishAuctionPage());
      case reverseAuction:
        return MaterialPageRoute(builder: (_) => const ReverseAuctionPage());
      case silentAuction:
        return MaterialPageRoute(builder: (_) => const SilentAuctionPage());
      case inProgess:
          return MaterialPageRoute(builder: (_) => InProgressPage());
      case sold:
          return MaterialPageRoute(builder: (_) => SoldPage());
      case unsold:
          return MaterialPageRoute(builder: (_) => UnsoldPage());
      case userProfile:
          return MaterialPageRoute(builder: (_) => const UserProfilePage());
      case sellerProfile:
          return MaterialPageRoute(builder: (_) => const SellerProfilePage());
      case addresses:
          return MaterialPageRoute(builder: (_) => AddressesPage());
      case payments:
          return MaterialPageRoute(builder: (_) => PaymentsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Pagina non trovata'),
            ),
          ),
        );
    }
  }
}

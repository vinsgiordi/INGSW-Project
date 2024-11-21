import 'package:bid_hub/app/components/seller_profile.dart';
import 'package:bid_hub/app/components/user_profile.dart';
import 'package:flutter/material.dart';
import '../ui/views/auth/login.dart';
import '../ui/views/home/home.dart';
import '../ui/views/auth/forgot_password.dart';
import '../ui/views/auth/registration.dart';
import '../ui/views/welcome.dart';
import '../ui/views/others/search.dart';
import '../ui/views/account/buyer/orders.dart';
import '../ui/views/account/buyer/my_bids.dart';
import '../ui/views/account/seller/auctions/choose_auction_type.dart';
import '../ui/views/account/seller/auctions/fixed_time_auction.dart';
import '../ui/views/account/seller/auctions/english_auction.dart';
import '../ui/views/account/seller/auctions/reverse_auction.dart';
import '../ui/views/account/seller/auctions/silent_auction.dart';
import '../ui/views/account/seller/sold.dart';
import '../ui/views/account/seller/unsold.dart';
import '../ui/views/account/seller/user_active_auctions.dart';
import '../ui/views/account/settings/addresses.dart';
import '../ui/views/account/settings/payment.dart';
import '../ui/views/account/inbox/notifications.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String forgotPassword = '/forgot_password';
  static const String registration = '/registration';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String myBids = '/my_bids';
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
  static const String notifications = '/notifications';
  static const String userAuctions = '/user_auctions';

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
        return MaterialPageRoute(builder: (_) => MyBidsPage());
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
      case sold:
          return MaterialPageRoute(builder: (_) => SoldPage());
      case unsold:
          return MaterialPageRoute(builder: (_) => UnsoldPage());
      case userProfile:
          return MaterialPageRoute(builder: (_) => const UserProfilePage());
      case sellerProfile:
        final venditoreId = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => SellerProfilePage(venditoreId: venditoreId,));
      case addresses:
          return MaterialPageRoute(builder: (_) => AddressesPage());
      case payments:
          return MaterialPageRoute(builder: (_) => PaymentsPage());
      case notifications:
          return MaterialPageRoute(builder: (_) => NotificationsPage());
      case userAuctions:
          return MaterialPageRoute(builder: (_) => const UserActiveAuctionsPage());
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

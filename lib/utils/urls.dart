import 'package:sevenemirates/utils/const.dart';

class Urls {
  // static var iP = "http://192.168.203.1/";
  // static var address = iP + "FlutterProjects/7emiratesProjects/Site/API/mobile_api/";
  // static var imageLocation = iP + "FlutterProjects/7emiratesProjects/Site/mec/";
  static String apiKey = 'wFM5m60DFJYderhYiFDqrp56wzR1rriB';
  static var iP = "https://www.7emiratesapp.ae/";
  static var address = iP + "API/mobile_api/";
  static var imageLocation = iP + "mec/";

  static var DummyLogo = "assets/images/logo.png";
  static var DummyImageBanner = "assets/images/banner.jpg";
  static var CurrencyAPI =
      "https://api.apilayer.com/fixer/latest?base=AED&symbols=AED,INR,KWD,EGP,OMR,QAR,SAR,BHD";
  static var ShareURL = "https://7emirates.ae/share.php?";

  //OTP and Registration
  static var validation = address + "validation.php";
  static var GetUser = address + "otp-getuser.php";
  static var deleteUser = address + "delete_user.php";
  static var GetUserEmail = address + "otp-getemailuser.php";
  static var sendEmail = address + "otp_email.php";
  static var UpdateUser = address + "otp-updateuser.php";

  //UserProfile
  static var UpdateProfile = address + "update-profile.php";
  static var UpdateImage = address + "update-user-image.php";

  //Bookings
  static var AddBooking = address + "booking.php";
  static var UserBooking = address + "user-booking.php";
  static var UserBookingView = address + "user-booking-view.php";
  static var StoreBooking = address + "store-booking.php";
  static var StoreBookingView = address + "store-booking-view.php";
  static var UpdateOrder = address + "update-order.php";

  //search
  static var searchList = address + "search-list.php";

  //Seller View
  static var sellerView = address + "seller-view.php";

  //User Product Options
  static var Dashboard = address + "dashboard.php";
  static var ProductList = address + "product-list.php";
  static var ProductView = address + "product-view.php";
  static var AddReport = address + "add-report.php";
  static String AddReview = address + "add-review.php";
  static var AddLike = address + "add-like.php";
  static var FavouriteList = address + "favorite-list.php";
  static var UserProductList = address + "user-product-list.php";

  //Vendor Product Management
  static var UserPost = address + "user-post.php";
  static var UserCommunity = address + "user-community.php";
  static var ChangeProductStatus = address + "change-product-status.php";
  static var StoreProductView = address + "store-product-view.php";
  static var ProfileCounts = address + "profile-count.php";

  //Vendor Product Add
  static var AddProduct = address + "add-product.php";
  static var deleteProduct = address + "delete-product.php";
  static var deleteProductImage = address + "delete-image.php";
  static var addImage = address + "add-image.php";
  static var UpdateProduct = address + "update-product.php";
  static var GetDataForProduct = address + "get-product-add.php";
  static var GedProductUpdate = address + "get-product-update.php";
  static var AddNewSize = address + "add-size.php";
  static var updateSize = address + "update-size.php";
  static var deleteProductVar = address + "delete-variant.php";
  static var AddVarColor = address + "add-color.php";

  //chat
  static var ChatHistory = address + "chat-history.php";
  static String Chat = address + "chat.php";
  static String BlockChat = address + "block-chat.php";
  static String AddChatMessage = address + "add-chat.php";
}

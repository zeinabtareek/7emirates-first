import 'package:flutter/services.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sevenemirates/components/snakebar.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlOpenUtils {
  static whatsapp(GlobalKey<ScaffoldMessengerState> scaffoldKey) async {
    var whatsappUrl = "https://wa.me/" + Const.WHATSAPPNUMBER;
    await canLaunchUrl(Uri.parse(whatsappUrl))
        ? launchUrl(
            Uri.parse(whatsappUrl),
            mode: LaunchMode.externalApplication,
          )
        : SnakeBarUtils.Error(scaffoldKey, "Whatsapp not installed");
  }

  static whatsapptoAdmin(
      GlobalKey<ScaffoldMessengerState> scaffoldKey, String msg) async {
    var whatsappUrl =
        "whatsapp://send?phone=" + Const.WHATSAPPNUMBER + "&text=" + msg;
    await canLaunchUrl(Uri.parse(whatsappUrl))
        ? launchUrl(Uri.parse(whatsappUrl))
        : SnakeBarUtils.Error(scaffoldKey, "Whatsapp not installed");
  }

  static whatsappShop(
      GlobalKey<ScaffoldMessengerState> scaffoldKey, String Phone) async {
    var whatsappUrl = "https://wa.me/" + Phone;
    await canLaunchUrl(Uri.parse(whatsappUrl))
        ? launchUrl(Uri.parse(whatsappUrl))
        : SnakeBarUtils.Error(scaffoldKey, "Whatsapp not installed");
  }

  static email(GlobalKey<ScaffoldMessengerState> scaffoldKey) async {
    var url = 'mailto:' + Const.SHAREEMAIL + '?subject=Hello&body=MyMail';
    await canLaunchUrl(Uri.parse(url))
        ? launchUrl(Uri.parse(url))
        : SnakeBarUtils.Error(scaffoldKey, "Email cannot send");
  }

  static openurl(
      GlobalKey<ScaffoldMessengerState> scaffoldKey, String geturl) async {
    var url = '' + geturl;
    await canLaunchUrl(Uri.parse(url))
        ? launchUrl(Uri.parse(url))
        : SnakeBarUtils.Error(scaffoldKey, "Invalid Url");
  }

  static share(
      GlobalKey<ScaffoldMessengerState> scaffoldKey, String getText) async {
    var url = '' + getText;
    try {
      Share.share(getText);
    } on PlatformException catch (error) {
      SnakeBarUtils.Error(scaffoldKey, error.message ?? '');
    } on FormatException catch (error) {
      SnakeBarUtils.Error(scaffoldKey, error.message);
    }
  }

  static call(
      GlobalKey<ScaffoldMessengerState> scaffoldKey, String phone) async {
    String getNumber = "tel:$phone";

    await canLaunchUrl(Uri.parse(getNumber))
        ? launchUrl(Uri.parse(getNumber))
        : debugPrint("err$getNumber");
  }
}

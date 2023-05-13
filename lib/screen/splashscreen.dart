import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/router/none_open_screen.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/screen/registration/phone_number.dart';
import 'package:sevenemirates/screen/splash_screen_second.dart';
import 'package:sevenemirates/screen/user/product_view_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user/dashboard.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  bool showProgress = false;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  var phone, name, userID, getLang, darkMode, skipSignup = '0', isVendor = '0';
  List userDate = [], settingData = [];

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phone = prefs.getString(Const.PHONE) ?? '';
      name = prefs.getString(Const.NAME) ?? '';
      userID = prefs.getString(Const.UID) ?? '';
      darkMode = prefs.getString(Const.DARKMODE) ?? '0';
      skipSignup = prefs.getString(Const.SKIP_SIGNUP_VALUE) ?? '0';
      var selecedAppLanguage = prefs.getString(Const.SETAPPLANGUAGE) ?? '0';
      Const.AppLanguage = int.parse(selecedAppLanguage);
      getLang = prefs.getString(Const.DB_LANG) ?? '';
      Const.CURRENCY_LAB = prefs.getString(Const.SELECTED_CURRENCY) ??
          Const.DEFAULT_CURRENCY_LAB;
      if (getLang == "_arab") {
        cur_Lang = getLang;
        cur_Lang_code = 'ar';
      } else {
        cur_Lang = getLang;
        cur_Lang_code = 'en';
      }

      if (darkMode == "1") {
        Provider.of<AppSetting>(context, listen: false)
            .changeTheme(ThemeMode.dark);
      } else {
        Provider.of<AppSetting>(context, listen: false)
            .changeTheme(ThemeMode.dark);
      }
    });

    _getCurrencyValue();
    // Const.CURRENCY_LAB = Const.DEFAULT_CURRENCY_LAB;
    //Const.CURRENCY_VALUE = 1;
    //  _validateUser();
    // }
  }

  _getCurrencyValue() async {
    print(phone.toString() + "Phonevvv");
    final response = await http.get(Uri.parse(Urls.CurrencyAPI), headers: {
      // HttpHeaders.acceptHeader: Const.POSTHEADER,
      'apiKey': Urls.apiKey,
    });
    Map data = {};

    try {
      data = json.decode(response.body);
      log('data $data');
    } catch (_) {}

    setState(() {
      if (data["success"] == true) {
        Const.CUR_AED = double.parse(data['rates']['AED'].toString());
        Const.CUR_BHD = double.parse(data['rates']['BHD'].toString());
        Const.CUR_KWD = double.parse(data['rates']['KWD'].toString());
        Const.CUR_EGP = double.parse(data['rates']['EGP'].toString());
        Const.CUR_OMR = double.parse(data['rates']['OMR'].toString());
        Const.CUR_QAR = double.parse(data['rates']['QAR'].toString());
        Const.CUR_SAR = double.parse(data['rates']['SAR'].toString());
        Const.CUR_INR = double.parse(data['rates']['INR'].toString());
        _validateUser();
        validatePermissions();
      } else {
        Pop.errorTop(
            context,
            Lang(
                'Due to technical issue, only ${Const.DEFAULT_CURRENCY_LAB} currency only available',
                "نظرا لمشكلة فنية، تتوفر فقط عملة ${Const.DEFAULT_CURRENCY_LAB} فقط"),
            Icons.account_balance_wallet_rounded);
        Const.CURRENCY_LAB = Const.DEFAULT_CURRENCY_LAB;
        Const.CURRENCY_VALUE = 1;
        if (kDebugMode) {
          _validateUser();
        }
      }
    });
  }

  _validateUser() async {
    log('phone $phone');
    // if (kDebugMode) {
    //   showPhoneNumberScreen();
    //   return;
    // }
    try {
      apiTest(phone.toString());
      var body = {
        "key": Const.APPKEY,
        "phone": phone,
        "vendor": isVendor,
      };
      late Map data;

      final response = await http.post(Uri.parse(Urls.validation),
          headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);
      apiTest(response.request.toString());
      apiTest(body.toString());
      data = json.decode(response.body);
      setState(() {
        userDate = data["user"];
        settingData = data["appsetting"];
        Const.packageList = data["package"];
        Const.APPVERSION = settingData[0]["app_version"];
        Const.OTP = settingData[0]["otp"];
      });

      if (data["success"] == true) {
        if (skipSignup == '0') {
          if (userDate.length != 0) {
            if (isVendor == '0') {
              SharedStoreUtils.setValue(Const.UID, userDate[0]["u_id"]);
              SharedStoreUtils.setValue(Const.NAME, userDate[0]["name"] ?? '');
              Provider.of<AppSetting>(context, listen: false).uid =
                  userDate[0]["u_id"] ?? '0';

              Provider.of<AppSetting>(context, listen: false).name =
                  userDate[0]["name"] ?? '';
              log('${userDate[0]["u_id"]}', name: 'user_id');
            } else {
              SharedStoreUtils.setValue(Const.UID, userDate[0]["u_id"]);
              SharedStoreUtils.setValue(Const.NAME, userDate[0]["name"] ?? '');
              Provider.of<AppSetting>(context, listen: false).uid =
                  userDate[0]["u_id"] ?? '0';
              log('${userDate[0]["u_id"]}', name: 'user_id');

              Provider.of<AppSetting>(context, listen: false).name =
                  userDate[0]["name"] ?? '';
            }

            if (userDate[0]["name"].toString() != "null" &&
                userDate[0]["name"].toString() != "") {
              openDashboard();
            } else {
              showPhoneNumberScreen();
            }
          } else {
            showPhoneNumberScreen();
          }
        } else {
          openDashboard();
        }
      } else {
        showPhoneNumberScreen();
      }
    } catch (e) {
      print(e);
      updatePopup();
    }
  }

  openDashboard() {
    //UserPreff
    Navigator.push(context, NoneOpenScreen(widget: Dashboard()));
    //
    // if (splashScreen == 0) {
    //   Navigator.push(
    //     context,
    //     NoneOpenScreen(widget: SplashScreenSecond()),
    //   );
    //   print('navigate to  SplashScreenSecond()');
    // }
  }

  updatePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Lang("Attention", "انتباه"),
          textAlign: TextAlign.left,
          style: ts_Regular(15, fc_1),
        ),
        content: Text(
          Lang(
              "May be something went wrong. Check for new update available to fix this issue or check your internet connection",
              "قد يكون هناك خطأ ما. تحقق من وجود تحديث جديد متاح لإصلاح هذه المشكلة أو تحقق من اتصالك بالإنترنت"),
          textAlign: TextAlign.left,
          style: ts_Regular(12, fc_1),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: Container(
              child: Text(
                Lang("Exit", "خروج"),
                style: ts_Regular(12, fc_1),
              ),
              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (Platform.isAndroid) {
                UrlOpenUtils.openurl(_scaffoldKey, Const.APP_IOS_URL);
              } else if (Platform.isIOS) {
                UrlOpenUtils.openurl(_scaffoldKey, Const.APP_IOS_URL);
              }
            },
            child: Container(
              child: Text(
                Lang("Update", "تحديث"),
                style: ts_Regular(12, fc_1),
              ),
              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: Provider.of<AppSetting>(context).appTheam,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection:
              Const.AppLanguage == 0 ? TextDirection.ltr : TextDirection.rtl,
          child: child!,
        );
      },
      home: ScaffoldMessenger(
        key: _scaffoldKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF0F0F0),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width * 0.3,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showPhoneNumberScreen() {
    Navigator.pushReplacement(
        context, OpenScreen(widget: PhoneNumberScreen(starting: "1")));
  }
}

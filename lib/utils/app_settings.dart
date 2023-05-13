import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/style_sheet.dart';

String Lang(String? Eng, String? Arab) {
  if (Const.AppLanguage == 1) {
    return Arab!;
  } else {
    return Eng!;
  }
}

String cur_Lang = "";
String cur_Lang_code = "";
String contry_code = "971";
String home_country = "971";
int splashScreen = 0;

apiTest(String data) {
  debugPrint('API RESULT');
  debugPrint(data);
}

class AppSetting with ChangeNotifier {
  ThemeMode appTheam = ThemeMode.light;
  String uid = '0';
  String name = '';
  String lname = '';
  String phone = '';
  String email = '';
  String emailVerify = '0';
  String profile = '';
  String country = '';
  String countryId = '';
  String city = '';
  String cityId = '';
  String member = '0';
  String bio = '';

  String address = '';
  String map = '';
  String skipSignup = '0';

  //map start
  String mapAddress = '';
  String maplat = '';
  String maplon = '';
  String mapCity = '';

  String bankAC = '';
  String bankName = '';
  String bankCode = '';

  //map end

  bool darkSelected = false;

  void changeTheme(ThemeMode getappTheam) {
    if (getappTheam == ThemeMode.light) {
      appTheam = getappTheam;
      darkSelected = true;
      //colors light
      isDark = false;
      fc_bg = Color(0xFF1A1A1A);
      fc_bg2 = Color(0xFF1E1E1E);
      fc_bg_mild = Colors.grey.shade50;
      fc_textfield_bg = Colors.grey.shade800;
      fc_1 = Colors.white;
      fc_2 = Colors.grey.shade100;
      fc_3 = Colors.grey.shade200;
      fc_4 = Colors.grey.shade400;
      fc_5 = Colors.grey.shade500;
      fc_6 = Colors.grey.shade600;

      fc_icnav_on = Color(0xFF27949C);
      fc_icnav_off = Color(0xFF8F8F8F);
    } else {
      appTheam = getappTheam;
      isDark = true;
      darkSelected = false;
      fc_bg = Colors.white;
      fc_bg2 = Color(0xFFEFEFEF);
      fc_bg_mild = Colors.grey.shade50;
      fc_textfield_bg = Colors.grey.shade100;
      fc_1 = Colors.grey.shade700;
      fc_2 = Colors.grey.shade700;
      fc_3 = Colors.grey.shade700;
      fc_4 = Colors.grey.shade600;
      fc_5 = Colors.grey.shade500;
      fc_6 = Colors.grey.shade200;
      fc_icnav_on = Color(0xFF305B6F);
      fc_icnav_off = Color(0xFF8F8F8F);
    }
    notifyListeners();
  }

  notifyListeners();
}

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(),
    textTheme:(cur_Lang=='')?GoogleFonts.ubuntuTextTheme():GoogleFonts.almaraiTextTheme(),
    cardColor: Colors.grey.shade900,
    dividerColor: Colors.grey.shade200,
    backgroundColor: Colors.grey.shade900,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      primary: TheamPrimary,
    )),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(),
    textTheme:(cur_Lang=='')?GoogleFonts.ubuntuTextTheme():GoogleFonts.almaraiTextTheme(),
    cardColor: Colors.white,
    dividerColor: Colors.white,
    backgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      primary: TheamPrimary,
    )),
  );
}

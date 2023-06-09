import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_instagram_storyboard/flutter_instagram_storyboard.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/country.dart';
import 'package:sevenemirates/screen/splashscreen.dart';
import 'package:sevenemirates/screen/user/dashboard/model/products_model.dart';
import 'package:sevenemirates/screen/view_stories_screen/model/model.dart';
import 'package:sevenemirates/screen/view_stories_screen/view_Stories_screen.dart';
import 'package:sevenemirates/test.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:story_time/story_time.dart';

import 'utils/app_settings.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  HttpOverrides.global = MyHttpOverrides();
  // TapPaymentHelper.instance.initPayment();

  var country = World();
  country.initCountryJson();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSetting(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MaterialApp(
          theme: TheamFont,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },
          title: '7 Emirate',
          debugShowCheckedModeBanner: false,
          // home: StoryScreen(stories: stories,)),
          // home: StoryPage()),
          // home: StoryExamplePage()),
          home: SplashScreen()),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}




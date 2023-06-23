import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/screen/registration/phone_number.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/screen/splashscreen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/components/image_viewer.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/router/left_open_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/screen/user/category_screen.dart';
import 'package:sevenemirates/screen/user/chat_history.dart';
import 'package:sevenemirates/screen/user/user_profile.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import '../router/open_screen.dart';
import '../screen/choose_ads_type/choose_ads_type.dart';
import '../screen/user/add_product_screen/add_product_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  BuildContext mcontext;
  bool ishome;
  int order;
  BottomNavigationWidget(
      {Key? key,
      required this.ishome,
      required this.mcontext,
      required this.order})
      : super(key: key);

  @override
  _BottomNavigationWidgetState createState() {
    return _BottomNavigationWidgetState();
  }
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String UserId = '';
  bool showProgress = false;
  late BuildContext mcontext;
  bool ishome = false;
  int order = 0;

  String skipSignup = '';

  @override
  void initState() {
    mcontext = widget.mcontext;
    ishome = widget.ishome;
    order = widget.order;
    super.initState();
    getSharedStore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      UserId = prefs.getString(Const.UID) ?? '';
      UserId = Provider.of<AppSetting>(context, listen: false).uid;

      skipSignup = Provider.of<AppSetting>(context, listen: false).skipSignup;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    initRelativeScaler(context);
    UserId = Provider.of<AppSetting>(context, listen: false).uid;
    skipSignup = Provider.of<AppSetting>(context, listen: false).skipSignup;
    apiTest('Userid-bottom' + UserId);
    apiTest(UserId);
    return Container(
      decoration: BoxDecoration(
        color: fc_bg,
        // boxShadow: [
        //   BoxShadow(
        //     blurRadius: 10,
        //     color: Colors.black.withOpacity(.05),
        //     blurStyle: BlurStyle.normal,
        //     offset: Offset(0.0, -10),
        //   )
        // ],
      ),
      child: SafeArea(
          child: IntrinsicHeight(
        child: Column(
          children: [
            Container(
              width: Width(context),
              height: sy(0.5),
              color: Colors.black.withOpacity(0.1),
              margin: EdgeInsets.fromLTRB(0, sy(0), 0, sy(3)),
            ),
            Row(
              //children inside bottom appbar
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      if (ishome == true) {
                         //
                         // Navigator.pushReplacement(mcontext, OpenScreen(widget: UserProfile()));
                      } else {
                        Navigator.of(mcontext).pop();
                      }
                    },
                    child: bottomMenuItem(
                        Lang('Home', 'الرئيسية'),
                        FontAwesomeIcons.home,
                        order == 1 ? TheamPrimary : fc_3!)),
                GestureDetector(
                    onTap: () {
                      if (ishome == true) {
                        Navigator.push(
                            mcontext, OpenScreen(widget: CategoryScreen()));
                      } else {
                        if (order != 2)
                          Navigator.pushReplacement(
                              mcontext, OpenScreen(widget: CategoryScreen()));
                      }
                    },
                    child: bottomMenuItem(
                        Lang('Listing', 'قائمة'),
                        FontAwesomeIcons.boxOpen,
                        order == 2 ? TheamPrimary : fc_3!)),
                GestureDetector(
                  onTap: () {
                    if (skipSignup == '1' || UserId == '0') {
                      Navigator.push(
                          context, OpenScreen(widget: PhoneNumberScreen()));
                    } else {
                      if (ishome == true) {
                        Navigator.push(
                            mcontext, OpenScreen(widget: ChooseType()));
                            // mcontext, OpenScreen(widget: AddProduct()));
                      } else {
                        Navigator.pushReplacement(

                            mcontext, OpenScreen(widget: ChooseType()));
                            // mcontext, OpenScreen(widget: AddProduct()));
                      }
                    }
                  },
                  child: Container(
                    height: sy(28),
                    width: Width(mcontext) * 0.2,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, sy(4)),
                    child: Image.asset(
                      'assets/images/logoonly.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // GestureDetector(
                //     onTap: () {
                //       apiTest(skipSignup + '-skip');
                //       apiTest(UserId + '-UserId');
                //       if (skipSignup == '1' || UserId == '0') {
                //         Navigator.push(
                //             context, OpenScreen(widget: PhoneNumberScreen()));
                //       } else {
                //         if (ishome == true) {
                //           Navigator.push(
                //               mcontext, OpenScreen(widget: ChatHistory()));
                //         } else {
                //           if (order != 3)
                //             Navigator.pushReplacement(
                //                 mcontext, OpenScreen(widget: ChatHistory()));
                //         }
                //       }
                //     },
                //     child: bottomMenuItem(
                //         Lang('Chat', 'المحادثات'),
                //         FontAwesomeIcons.solidComment,
                //         order == 3 ? TheamPrimary : fc_3!)),
                GestureDetector(
                    onTap: () {
                      if (skipSignup == '1' || UserId == '0') {
                        Navigator.push(
                            context, OpenScreen(widget: PhoneNumberScreen()));
                      } else {
                        if (ishome == true) {
                          Navigator.push(
                              mcontext, OpenScreen(widget: UserProfile()));
                        } else {
                          if (order != 4)
                            Navigator.pushReplacement(
                                mcontext, OpenScreen(widget: UserProfile()));
                        }
                      }
                    },
                    child: bottomMenuItem(
                        Lang('You', 'أنت'),
                        FontAwesomeIcons.solidUserCircle,
                        order == 4 ? TheamPrimary : fc_3!)),
              ],
            ),
          ],
        ),
      )),
    );
  }

  bottomMenuItem(String lable, IconData icon, Color color) {
    return Container(
      //height: sy(28),
      width: Width(mcontext) * 0.2,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: sy(12),
            color: color,
          ),
          SizedBox(
            height: sy(3),
          ),
          Text(
            lable,
            style: ts_Regular(sy(s - 1), color),
          ),
          SizedBox(
            height: sy(3),
          ),
        ],
      ),
    );
  }
}

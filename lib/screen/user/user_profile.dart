import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/image_viewer.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/components/widget_help.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/screen/splashscreen.dart';
import 'package:sevenemirates/screen/user/about_screen.dart';
import 'package:sevenemirates/screen/user/fav_screen.dart';
import 'package:sevenemirates/screen/user/my_community_screen.dart';
import 'package:sevenemirates/screen/user/search_screen.dart';
import 'package:sevenemirates/screen/user/store_booking_screen.dart';
import 'package:sevenemirates/screen/user/user_booking_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:sevenemirates/utils/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile.dart';
import 'my_post_screen.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() {
    return _UserProfileState();
  }
}

class _UserProfileState extends State<UserProfile> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String UserId = '',
      phone = '',
      email = '',
      profile = '',
      name = '',
      patientId = '';
  bool showProgress = false;
  Map data = Map();
  List userDetail = [];
  File? _image;
  var imagepath;
  String languageSelected = '';
  String currencySelected = '';
  TextDirection selectedTextDirection = TextDirection.ltr;

  String mapAddress = '';
  String mapLat = '';
  String mapLng = '';
  String mapCity = '';
  String postCount = "0";
  String communityCount = "0";
  String favCount = "0";
  Color bgColor = Color(0xFFF3F3F3);
  late GoogleMapController _Mapcontroller;

  @override
  void initState() {
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
      // UserId = prefs.getString(Const.UID) ?? '0';
      UserId = Provider.of<AppSetting>(context, listen: false).uid;
      phone = Provider.of<AppSetting>(context, listen: false).phone;
      email = Provider.of<AppSetting>(context, listen: false).email;
      profile = Provider.of<AppSetting>(context, listen: false).profile;
      name = Provider.of<AppSetting>(context, listen: false).name;

      mapAddress = Provider.of<AppSetting>(context, listen: false).mapAddress;
      mapLat = Provider.of<AppSetting>(context, listen: false).maplat;
      mapLng = Provider.of<AppSetting>(context, listen: false).maplon;
      mapCity = Provider.of<AppSetting>(context, listen: false).mapCity;

      languageSelected = prefs.getString(Const.SELECTEDLANGUGAE) ?? 'English';
      currencySelected = prefs.getString(Const.SELECTED_CURRENCY) ??
          Const.DEFAULT_CURRENCY_LAB;

      _getServer();
    });
  }

  _getServer() async {
    setState(() {
      showProgress = true;
    });
    apiTest(UserId.toString());
    final response = await http.post(Uri.parse(Urls.ProfileCounts), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": UserId.toString(),
    });

    data = json.decode(response.body);
    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        favCount = data['favourite'].toString();
        communityCount = data['community'].toString();
        postCount = data['posts'].toString();
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    initRelativeScaler(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: bgColor,
    ));
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
      home: Container(
          // color: Colors.red,
          color: bgColor,
          // color: fc_bg,
          child: SafeArea(
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
                // bottomNavigationBar: bottomNavigation(),
                backgroundColor: fc_bg,
                //resizeToAvoidBottomPadding: false,
                bottomNavigationBar: BottomNavigationWidget(
                  mcontext: context,
                  ishome: false,
                  order: 4,
                ),
                body: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                  ),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _screenBody(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  _screenBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: Width(context),
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(sy(10), sy(15), sy(10), sy(5)),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logoonly.png',
                    width: sy(25),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    width: sy(5),
                  ),
                  Text(
                    '7 Emirate',
                    style: ts_Bold(sy(l + 1), fc_3),
                  ),
                ],
              ),
            ),
            //mapHeader
            Container(
              width: Width(context),
              height: Width(context) * 0.75,
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: Width(context),
                        height: Width(context),
                        child: Image.asset(
                          'assets/images/mapbg.JPG',
                          width: Width(context),
                          height: Width(context),
                          fit: BoxFit.cover,
                        ),
                      )),
                  //Map
                  Positioned(
                      top: sy(80),
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          width: Width(context),
                          height: Width(context),
                          child: GoogleMap(
                            mapType: MapType.normal,
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            scrollGesturesEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(double.parse(mapLat.toString()),
                                  double.parse(mapLng.toString())),
                              zoom: 15.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              changeMapMode();

                              _Mapcontroller = controller;
                            },
                          ))),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: sy(100),
                      child: Container(
                        width: Width(context),
                        child: Image.asset('assets/images/whitepad.png',
                            width: Width(context),
                            height: sy(100),
                            fit: BoxFit.fitWidth),
                      )),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: sy(100),
                      child: Container(
                          width: Width(context),
                          child: RotatedBox(
                            quarterTurns: 2,
                            child: Image.asset('assets/images/whitepad.png',
                                width: Width(context),
                                height: sy(100),
                                fit: BoxFit.fitWidth),
                          ))),
                  //Name and city
                  Positioned(
                      child: Container(
                    padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(5)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Lang(" Hello ", "مرحبًا  ") + ' ' + name,
                          style: ts_Bold(sy(n), fc_3),
                        ),
                        SizedBox(
                          height: sy(5),
                        ),
                        GestureDetector(
                          child: Row(
                            children: [
                              Text(
                                mapCity,
                                style: ts_Regular(sy(s), fc_3),
                              ),
                              SizedBox(
                                width: sy(3),
                              ),
                              Icon(
                                Icons.arrow_right,
                                size: sy(l),
                                color: fc_4,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: sy(10),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.push(
                                context, OpenScreen(widget: SearchScreen()));
                          },
                          child: Material(
                            color: Colors.white,
                            elevation: 1,
                            borderRadius: BorderRadius.circular(sy(5)),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  sy(15), sy(8), sy(5), sy(8)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: sy(xl),
                                    color: fc_5,
                                  ),
                                  SizedBox(
                                    width: sy(8),
                                  ),
                                  Text(
                                    Lang(" What are you looking for ? ",
                                        "عما تبحث ؟  "),
                                    style: ts_Regular(sy(n), fc_5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding:
                            EdgeInsets.fromLTRB(sy(10), sy(80), sy(10), sy(5)),
                        child: WidgetHelp.profilePic(
                            profile, name, sy(40), sy(40), sy(40)),
                      )),
                  //Your Activity
                  // Positioned(
                  //   bottom: 0,
                  //     left: 0,
                  //     right: 0,
                  //     child: yourActivity())
                ],
              ),
            ),
            //
            Container(
              width: Width(context),
              padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  titleCard('All Category'),
                  // SizedBox(height: sy(5),),
                  //  SingleChildScrollView(
                  //    scrollDirection: Axis.horizontal,
                  //    child: Row(
                  //      children: [
                  //
                  //        for(int i=0;i<Const.categoryList.length;i++)
                  //        GestureDetector(
                  //          onTap: (){
                  //            Navigator.push(context, OpenScreen(widget: ProductListScreen(cid: Const.categoryList[i]['c_id'],)));
                  //          },
                  //          child:  cardCategoryItem(Const.categoryList[i]['c_name'].toString(),Const.categoryList[i]['c_image'].toString() ),
                  //        ),
                  //
                  //
                  //
                  //      ],
                  //    ),
                  //  ),
                  //SizedBox(height: sy(20),),
                  //   titleCard('App Options'),
                  //   SizedBox(height: sy(8),),
                  menuListWidget(),
                  SizedBox(
                    height: sy(20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  titleCard(String lable) {
    return Container(
      child: Text(
        lable,
        style: ts_Bold(sy(n), fc_3),
      ),
    );
  }

  yourActivity() {
    return Container(
        width: Width(context),
        padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleCard(Lang(" Your Activity ", " نشاطك ")),
            SizedBox(
              height: sy(5),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, OpenScreen(widget: MyPostScreen()));
                    },
                    child: cardActivityItem(
                        Lang('Post & Ads', 'منشور وإعلانات'),
                        postCount,
                        Icons.chair),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, OpenScreen(widget: MyCommunityScreen()));
                    },
                    child: cardActivityItem(Lang('Community', 'مجتمع'),
                        communityCount, Icons.engineering),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, OpenScreen(widget: FavScreen()));
                    },
                    child: cardActivityItem(
                        Lang('Favourite', 'المفضلة'), favCount, Icons.favorite),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  cardActivityItem(String title, String count, IconData icon) {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(0), sy(0), sy(10), sy(0)),
      child: Material(
        elevation: 1,
        shadowColor: Colors.black,
        color: fc_bg,
        borderRadius: BorderRadius.circular(sy(5)),
        child: Container(
            width: Width(context) * 0.55,
            padding: EdgeInsets.fromLTRB(sy(8), sy(8), sy(10), sy(8)),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ts_Bold(sy(l), fc_3),
                    ),
                    SizedBox(
                      height: sy(10),
                    ),
                    Text(
                      (showProgress == true)
                          ? Lang(" LOADING ", " جار التحميل ")
                          : count,
                      style: ts_Bold(sy(s), fc_3),
                    ),
                    SizedBox(
                      height: sy(3),
                    ),
                    Text(
                      Lang(" Post ", "منشور  "),
                      style: ts_Bold(sy(s), fc_5),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      icon,
                      size: sy(33),
                      color: TheamPrimary,
                    ),
                    SizedBox(
                      height: sy(10),
                    ),
                    Text(
                      Lang("View >>  ", "عرض >>  "),
                      style: ts_Regular(sy(s), fc_3),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  cardCategoryItem(String title, String image) {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(0), sy(0), sy(10), sy(0)),
      child: Material(
        elevation: 1,
        shadowColor: Colors.black,
        color: fc_bg,
        borderRadius: BorderRadius.circular(sy(5)),
        child: Container(
          width: Width(context) * 0.32,
          padding: EdgeInsets.fromLTRB(sy(8), sy(5), sy(5), sy(5)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomeImageView(
                image: Urls.imageLocation + image,
                width: Width(context) * 0.12,
                height: Width(context) * 0.12,
                radius: sy(50),
              ),
              SizedBox(
                height: sy(6),
              ),
              Text(
                title,
                style: ts_Regular(sy(n), fc_3),
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  changeMapMode() async {
    getJsonFile("assets/images/plainmap.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _Mapcontroller.setMapStyle(mapStyle);
  }

  menuListWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(10)),
      decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (UserId != "0")
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    OpenScreen(
                        widget: EditProfile(
                      screen: 'basic',
                    )));
              },
              child: menuItem(Icons.perm_contact_cal_rounded, TheamButton,
                  Lang('Manage Profile', "إدارة الملف الشخصي")),
            ),
          if (UserId != "0")
            GestureDetector(
              onTap: () {
                Navigator.push(context, OpenScreen(widget: MyPostScreen()));
              },
              child: menuItem(Icons.chair, TheamButton,
                  Lang(" Your Post & Ads ", " منشورك وإعلاناتك ")),
            ),
          if (UserId != "0")
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, OpenScreen(widget: MyCommunityScreen()));
              },
              child: menuItem(Icons.engineering, TheamButton,
                  Lang("Community  ", " تواصل اجتماعي ")),
            ),
          if (UserId != "0")
            GestureDetector(
              onTap: () {
                Navigator.push(context, OpenScreen(widget: FavScreen()));
              },
              child: menuItem(Icons.favorite, TheamButton,
                  Lang("Favourite  ", "المفضلة  ")),
            ),
          if (UserId != "0")
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    OpenScreen(
                        widget: EditProfile(
                      screen: 'bank',
                    )));
              },
              child: menuItem(Icons.account_balance, TheamButton,
                  Lang("Bank Details  ", "التفاصيل المصرفية  ")),
            ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, OpenScreen(widget: UserBookingScreen()));
            },
            child: menuItem(Icons.shopping_basket, TheamButton,
                Lang("Ordered by You  ", "طلبات من قبلك  ")),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, OpenScreen(widget: StoreBookingScreen()));
            },
            child: menuItem(Icons.shopping_cart, TheamButton,
                Lang(" Orders for You ", "طلبات لك")),
          ),
          GestureDetector(
            onTap: () {
              pop_Langugaes();
            },
            child: menuItem(
                Icons.language, TheamButton, Lang(" Language ", "لغة  "),
                right: languageSelected),
          ),
          GestureDetector(
            onTap: () {
              pop_Currency(context);
            },
            child: menuItem(Icons.attach_money_outlined, TheamButton,
                Lang("Currency  ", " عملة "),
                right: currencySelected),
          ),
          if (UserId != "0")
            GestureDetector(
              onTap: () {
                popLogout();
              },
              child: menuItem(Icons.logout_outlined, TheamButton,
                  Lang(" Logout ", "تسجيل خروج  ")),
            ),
          GestureDetector(
            onTap: () {
              popDeleteAccount();
            },
            child: menuItem(Icons.delete, TheamButton,
                Lang(" Delete Account ", "حذف الحساب  ")),
          ),
          GestureDetector(
            onTap: () {
              UrlOpenUtils.whatsapp(_scaffoldKey);
            },
            child: menuItem(FontAwesomeIcons.whatsapp, TheamButton,
                Lang("Contact us  ", "اتصل بنا  ")),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, OpenScreen(widget: AboutScreen()));
            },
            child: menuItem(Icons.info_outline, TheamButton,
                Lang("About us  ", " من نحن ")),
          ),
        ],
      ),
    );
  }

  menuItem(IconData icon, Color color, String lable, {String right = ''}) {
    return Container(
      color: fc_bg,
      margin: EdgeInsets.fromLTRB(0, 0, 0, sy(1)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(7)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
            decoration: decoration_round(
                Colors.grey.shade200, sy(30), sy(30), sy(30), sy(30)),
            child: Icon(
              icon,
              color: fc_2,
              size: sy(n),
            ),
          ),
          SizedBox(
            width: sy(10),
          ),
          Expanded(
              child: Text(
            lable,
            style: ts_Regular(sy(n), fc_1),
          )),
          if (right != '')
            Text(
              right,
              style: ts_Regular(sy(s), fc_2),
            )
        ],
      ),
    );
  }

  popLogout() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: fc_bg,
              title: Text(
                Lang("Logout  ", " تسجيل خروج "),
                style: ts_Regular(sy(l), fc_1),
                textAlign: TextAlign.left,
              ),
              content: Text(
                Lang(" Are you sure want to logout from this profile? ",
                    " هل أنت متأكد من أنك تريد تسجيل الخروج من هذا الملف الشخصي؟ "),
                style: ts_Regular(sy(n), fc_2),
                textAlign: TextAlign.left,
              ),
              actions: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    child: Text(
                      Lang("Later", "لاحقا"),
                      style: ts_Regular(sy(n), fc_1),
                    ),
                    padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                    _clearSharedpreference();
                  },
                  child: Container(
                    child: Text(Lang("Logout  ", "تسجيل خروج  "),
                        style: ts_Regular(sy(n), fc_1)),
                    padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                  ),
                ),
              ],
            ));
  }

  popDeleteAccount() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: fc_bg,
              title: Text(
                Lang("Delete Account  ", " حذف الحساب "),
                style: ts_Regular(sy(l), fc_1),
                textAlign: TextAlign.left,
              ),
              content: Text(
                Lang(" The account will be permanently deleted, are you sure? ",
                    " سيتم حذف الحساب بشكل نهائي, هل أنت متأكد؟ "),
                style: ts_Regular(sy(n), fc_2),
                textAlign: TextAlign.left,
              ),
              actions: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    child: Text(
                      Lang("Cancel", "إلغاء"),
                      style: ts_Regular(sy(n), fc_1),
                    ),
                    padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    var body = {"key": "228070", "u_id": UserId};
                    log('Body =>$body');
                    final response = await http.post(Uri.parse(Urls.deleteUser),
                        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER},
                        body: body);
                    Navigator.of(context).pop(false);

                    var data = jsonDecode(response.body);
                    log('$data', name: 'data_response');
                    if (data['success'] == true) {
                      _clearSharedpreference();
                    }
                  },
                  child: Container(
                    child: Text(Lang("Confirm  ", "تأكيد  "),
                        style: ts_Regular(sy(n), fc_1)),
                    padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                  ),
                ),
              ],
            ));
  }

  pop_Langugaes() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(
                    Lang("Available Languages", 'اللغات المتوفرة'),
                    style: ts_Regular(sy(l), fc_2),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey[500],
                ),
                ListTile(
                    trailing: (languageSelected == 'English')
                        ? Icon(
                            Icons.check,
                            size: sy(15),
                            color: fc_2,
                          )
                        : null,
                    title: Text(
                      Lang(" English ", "English"),
                      style: ts_Regular(sy(n), fc_2),
                    ),
                    onTap: () => {
                          _setLanguage(0, 'English', ''),
                        }),
                ListTile(
                    trailing: (languageSelected == 'عربى')
                        ? Icon(
                            Icons.check,
                            size: sy(15),
                            color: fc_2,
                          )
                        : null,
                    title: Text(
                      'عربى',
                      style: ts_Regular(sy(n), fc_2),
                    ),
                    onTap: () => {
                          _setLanguage(1, 'عربى', '_arab'),
                        }),
              ],
            ),
          ));
        });
  }

  pop_Currency(BuildContext mcontext) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0),
                bottomLeft: Radius.circular(0))),
        context: mcontext,
        builder: (mcontext) {
          return StatefulBuilder(
            builder: (mcontext, setState) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: sy(35),
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(
                        Lang('Available Currency', 'العملة المتاحة'),
                        textAlign: TextAlign.left,
                        style: ts_Bold(sy(l), Colors.black),
                      ),
                      subtitle: Container(
                        height: 0.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Positioned(
                    top: sy(35.5),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(mcontext).size.width,
                        color: Colors.grey[50],
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                                trailing: (currencySelected == 'AED')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'AED',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('United Arab Emirates Dirham',
                                      "درهم الإمارات العربية المتحدة"),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('AED'),
                                    }),
                            ListTile(
                                trailing: (currencySelected == 'KWD')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'KWD',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('Kuwaiti Dinar', 'دينار كويتي'),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('KWD'),
                                    }),
                            ListTile(
                                trailing: (currencySelected == 'OMR')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'OMR',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('Omani Rial', 'ريال عماني'),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('OMR'),
                                    }),
                            ListTile(
                                trailing: (currencySelected == 'QAR')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'QAR',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('Qatari Riyal', 'ريال قطري'),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('QAR'),
                                    }),
                            ListTile(
                                trailing: (currencySelected == 'SAR')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'SAR',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('Saudi Arabian Riyal', "ريال سعودي"),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('SAR'),
                                    }),
                            ListTile(
                                trailing: (currencySelected == 'BHD')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'BHD',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('Bahraini Dinar', 'دينار بحريني'),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('BHD'),
                                    }),
                            ListTile(
                                trailing: (currencySelected == 'EGP')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'EGP',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('Egyptian Pound', 'الجنيه المصري'),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('EGP'),
                                    }),
                            ListTile(
                                trailing: (currencySelected == 'INR')
                                    ? Icon(
                                        Icons.check,
                                        size: sy(15),
                                        color: fc_2,
                                      )
                                    : null,
                                title: Text(
                                  'INR',
                                  style: ts_Bold(sy(n), fc_2),
                                ),
                                subtitle: Text(
                                  Lang('Indian Rupee', 'روبية هندية'),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                onTap: () => {
                                      _setCurrency('INR'),
                                    }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  _setLanguage(int id, String lable, String langString) {
    setState(() {
      Const.AppLanguage = id;
      debugPrint("selected lan$id");
      languageSelected = lable;
      SharedStoreUtils.setValue(Const.SETAPPLANGUAGE, id.toString());
      SharedStoreUtils.setValue(Const.SELECTEDLANGUGAE, lable.toString());
      SharedStoreUtils.setValue(Const.DB_LANG, langString);
      cur_Lang = langString;
      if (id == 0) {
        selectedTextDirection = TextDirection.ltr;
      } else {
        selectedTextDirection = TextDirection.rtl;
      }
      Navigator.pushAndRemoveUntil(context, OpenScreen(widget: SplashScreen()),
          ModalRoute.withName("/"));
    });
  }

  _setCurrency(String lable) {
    setState(() {
      currencySelected = lable;
      SharedStoreUtils.setValue(Const.SELECTED_CURRENCY, lable.toString());
      Navigator.pushAndRemoveUntil(context, OpenScreen(widget: SplashScreen()),
          ModalRoute.withName("/"));
    });
  }

  _clearSharedpreference() async {
    Provider.of<AppSetting>(context, listen: false).uid = "0";
    Provider.of<AppSetting>(context, listen: false).name = "";
    Provider.of<AppSetting>(context, listen: false).phone = "";
    Provider.of<AppSetting>(context, listen: false).email = "";
    Provider.of<AppSetting>(context, listen: false).emailVerify = "0";
    Provider.of<AppSetting>(context, listen: false).profile = "";
    Provider.of<AppSetting>(context, listen: false).country = "";
    Provider.of<AppSetting>(context, listen: false).countryId = "";
    Provider.of<AppSetting>(context, listen: false).city = "";
    Provider.of<AppSetting>(context, listen: false).skipSignup = "0";
    SharedStoreUtils.clearValue();
    Navigator.pushAndRemoveUntil(
        context, OpenScreen(widget: SplashScreen()), ModalRoute.withName("/"));
  }
}

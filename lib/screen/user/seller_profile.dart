import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/custom_date.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/components/widget_help.dart';
import 'package:sevenemirates/layout/product_card_community.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/screen/user/product_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/flashbar.dart';
import '../../components/loading_placement.dart';
import '../../layout/product_card.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';
import 'chat_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  String seller;
  SellerProfileScreen({Key? key, required this.seller}) : super(key: key);

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String UserId = '';
  String UserName = '';

  bool showProgress = false;
  Map data = Map();

  List productList = [];
  List userDetail = [];
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
      UserId = prefs.getString(Const.UID) ?? '';
      UserId = Provider.of<AppSetting>(context, listen: false).uid;
      UserName = Provider.of<AppSetting>(context, listen: false).name;
      _getServer();
    });
  }

  _getServer() async {
    showProgress = true;
    var body = {"key": Const.APPKEY, "uid": widget.seller};
    final response = await http.post(Uri.parse(Urls.sellerView),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);
    debugPrint("Request--" + response.request.toString());
    data = json.decode(response.body);

    debugPrint("body--" + body.toString());

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        userDetail = data["userDetail"];
        productList = data["productlist"];
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initRelativeScaler(context);
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
          color: fc_bg,
          child: SafeArea(
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
                body: Container(
                  color: fc_bg,
                  height: Height(context),
                  width: Width(context),
                  child: Stack(
                    children: <Widget>[
                      if (userDetail.length != 0)
                        Positioned(
                          top: sy(0),
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _screenBody(),
                        ),
                      Positioned(
                        top: sy(5),
                        left: 0,
                        right: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: sy(40),
                          padding:
                              EdgeInsets.fromLTRB(sy(10), sy(5), sy(5), sy(5)),
                          child: Row(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                  // Navigator.of(context, rootNavigator: true).pop(context);
                                },
                                child: Material(
                                  color: Colors.black12,
                                  elevation: 1,
                                  borderRadius: BorderRadius.circular(sy(30)),
                                  child: Container(
                                    width: sy(25),
                                    height: sy(25),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(
                                        sy(5), sy(0), sy(5), sy(0)),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: fc_bg,
                                      size: sy(l),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: sy(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (showProgress)
                        LoadingPlacement(
                            width: Width(context), height: Height(context))
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
    ;
  }

  _screenBody() {
    return Container(
      width: Width(context),
      decoration: decoration_round(fc_bg, sy(0), sy(0), sy(0), sy(0)),
      child: SingleChildScrollView(
          //    physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topBanner(),
              profileWidget(),
              statusWidget(),
              relatedPost(),
            ],
          )),
    );
  }

  topBanner() {
    return Container(
      width: Width(context),
      height: Height(context) * 0.40,
      decoration:
          decoration_border(fc_bg, fc_bg, 0.0, sy(0), sy(0), sy(0), sy(0)),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: sy(25),
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned(
            //  top: sy(155),
            left: sy(10),
            right: sy(10),
            bottom: 0,
            child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(sy(100)),
                        child: WidgetHelp.profilePic(
                            userDetail[0]['profile_pic'].toString(),
                            userDetail[0]['name'].toString(),
                            sy(50),
                            sy(50),
                            sy(50))),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  profileWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(15), sy(3), sy(15), sy(3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              userDetail[0]['name'],
              style: ts_Bold(sy(l), fc_2),
            ),
          ),
          SizedBox(
            height: sy(3),
          ),
          Center(
            child: Text(
              '7EU0' + userDetail[0]['u_id'],
              style: ts_Regular(sy(s), fc_3),
            ),
          ),
          SizedBox(
            height: sy(20),
          ),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: iconWidget(Icons.phone_android, 'Call'),
                onTap: () {
                  UrlOpenUtils.call(_scaffoldKey, userDetail[0]['phone']);
                },
              ),
              GestureDetector(
                child: iconWidget(FontAwesomeIcons.whatsapp, 'Whatsapp'),
                onTap: () {
                  UrlOpenUtils.whatsappShop(_scaffoldKey,
                      userDetail[0]['country_id'] + userDetail[0]['phone']);
                },
              ),
              GestureDetector(
                child: iconWidget(Icons.chat_bubble_outline, 'Chat'),
                onTap: () {
                  Navigator.push(
                      context,
                      OpenScreen(
                          widget: ChatScreen(
                        opImage: userDetail[0]['profile_pic'].toString(),
                        opName: userDetail[0]['name'].toString(),
                        opId: userDetail[0]['u_id'],
                      )));
                },
              ),
              GestureDetector(
                child: iconWidget(Icons.place_outlined, 'Location'),
                onTap: () {
                  UrlOpenUtils.openurl(_scaffoldKey,
                      "https://www.google.com/maps/place/${userDetail[0]['map']}/@${userDetail[0]['map']},12z");
                },
              ),
            ],
          )),
          SizedBox(
            height: sy(20),
          ),
          Text(
            userDetail[0]['about'].toString(),
            textAlign: TextAlign.justify,
            style: ts_Regular(sy(n), fc_2),
          ),
          SizedBox(
            height: sy(15),
          ),
          Text(
            userDetail[0]['address'],
            style: ts_Regular(sy(s), fc_3),
          ),
          Text(
            userDetail[0]['city'],
            style: ts_Regular(sy(s), fc_3),
          ),
          SizedBox(
            height: sy(5),
          ),
          Text(
            userDetail[0]['email'],
            style: ts_Regular(sy(s), fc_3),
          ),
          SizedBox(
            height: sy(3),
          ),
          Text(
            userDetail[0]['country_id'] + userDetail[0]['phone'],
            style: ts_Regular(sy(s), fc_3),
          ),
          SizedBox(
            height: sy(10),
          ),
        ],
      ),
    );
  }

  statusWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 2,
            width: Width(context),
            color: fc_textfield_bg,
          ),
          SizedBox(
            height: sy(10),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(sy(15), sy(3), sy(15), sy(3)),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                statusCard(
                    CustomeDate.datedaymonth(userDetail[0]['u_dated']), 'Date'),
                SizedBox(
                  width: sy(20),
                ),
                statusCard(productList.length.toString(), 'Ad Post'),
                SizedBox(
                  width: sy(12),
                ),
                Expanded(
                    child: SizedBox(
                  width: sy(2),
                )),
                statusCard('7EU0' + userDetail[0]['u_id'], 'User ID'),
              ],
            ),
          ),
          SizedBox(
            height: sy(10),
          ),
          Container(
            height: 2,
            width: Width(context),
            color: fc_textfield_bg,
          ),
        ],
      ),
    );
  }

  relatedPost() {
    return Container(
      color: fc_bg_mild,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
            width: Width(context),
            height: sy(20),
            child: Text(
              Lang(" Other Post ", " منشور آخر "),
              style: ts_Regular(sy(n), fc_3),
            ),
          ),
          for (int i = 0; i < productList.length; i++)
            Container(
              margin: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(4)),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      OpenScreen(
                          widget: ProductViewScreen(
                        pid: productList[i]["p_id"],
                        pname: productList[i]["p_title"],
                        pimage: productList[i]["p_image"],
                      )));
                },
                style: elevatedButtonTrans(),
                child: (productList[i]['c_id'] != Const.COMMUNITY_ID &&
                        productList[i]['c_id'] != Const.JOBS_ID)
                    ? ProductCard(i: i, getProducts: productList)
                    : ProductCardCommunityMain(
                        getProducts: productList,
                        mcontext: context,
                        i: i,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  iconWidget(IconData icon, String name) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            size: sy(xxl),
            color: fc_3,
          ),
          SizedBox(
            height: sy(5),
          ),
          Text(
            name,
            style: ts_Regular(sy(s), fc_3),
          )
        ],
      ),
    );
  }

  statusCard(String point, String name) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            point,
            style: ts_Regular(sy(n), fc_1),
          ),
          SizedBox(
            height: sy(5),
          ),
          Text(
            name,
            style: ts_Regular(sy(s), fc_3),
          )
        ],
      ),
    );
  }
}

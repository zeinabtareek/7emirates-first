import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/screen/user/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/flashbar.dart';
import '../../components/image_viewer.dart';
import '../../components/progress_layout.dart';
import '../../layout/product_card.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';
import 'add_product_screen.dart';

class UserPostingScreen extends StatefulWidget {
  UserPostingScreen({Key? key}) : super(key: key);

  @override
  _UserPostingScreenState createState() => _UserPostingScreenState();
}

class _UserPostingScreenState extends State<UserPostingScreen> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String UserId = '';
  String UserName = '';

  bool showProgress = false;
  int servicetab = 0;
  Map data = Map();
  int pageCount = 1;
  ScrollController _scrollController = ScrollController();
  List fieldsList = [];
  List productList = [];
  List favouriteList = [];
  @override
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
      getFavouriteList(pageCount);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            pageCount = pageCount + 1;
          });
          getFavouriteList(pageCount);
        }
      });
    });
  }

  _getServer() async {
    setState(() {
      showProgress = true;
    });
    apiTest('server');
    var body = {
      "key": Const.APPKEY,
      "uid": UserId.toString(),
    };
    final response = await http.post(Uri.parse(Urls.UserProductList),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);

    data = json.decode(response.body);

    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        productList = data["productlist"];
        fieldsList = data["fields"];
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  getFavouriteList(int pagenumber) async {
    setState(() {
      showProgress = true;
    });
    final response = await http.post(Uri.parse(Urls.FavouriteList), headers: {
      HttpHeaders.acceptHeader: Const.POSTHEADER
    }, body: {
      "key": Const.APPKEY,
      "uid": UserId,
      "page": pagenumber.toString(),
    });

    data = json.decode(response.body);

    setState(() {
      showProgress = false;
    });
    setState(() {
      if (data["success"] == true) {
        favouriteList = data["favouritelist"];

        print(favouriteList);
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
        child:  SafeArea(
          // top: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: TheamPrimary,
              //Floating action button on Scaffold
              onPressed: () {
                Navigator.push(context, OpenScreen(widget: AddProduct()));
              },
              child: Icon(
                Icons.send,
                color: fc_bg,
              ), //icon inside button
            ),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: bottomNavigation(),
            body: Container(
              color: fc_bg_mild,
              height: Height(context),
              width: Width(context),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: toptitle(),
                  ),
                  Positioned(
                    top: sy(65),
                    left: sy(20),
                    right: sy(20),
                    child: categorywidget(),
                  ),
                  Positioned(
                    top: sy(130),
                    left: sy(20),
                    right: sy(20),
                    child: tabWidget(),
                  ),
                  Positioned(
                    top: sy(170),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: screenBody(),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  screenBody() {
    return Container(
      width: Width(context),
      color: fc_bg_mild,
      child: SingleChildScrollView(
        // physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyProgressLayout(showProgress),
              //   if (showProgress == false) emptyCart(),

              if (servicetab == 0) productWidget(),
              if (servicetab == 1) favouriteWidget(),
              if (servicetab == 2) soldProductWidget(),
            ]),
      ),
    );
  }

  toptitle() {
    double width = ((Width(context) - sy(43)) * 0.2);
    return Container(
      width: Width(context),
      height: sy(80),
      padding: EdgeInsets.all(sy(8)),
      decoration: decoration_border(
          TheamPrimary, TheamPrimary, 1, sy(0), sy(0), sy(20), sy(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  decoration: decoration_round(
                      TheamPrimary, sy(50), sy(50), sy(50), sy(50)),
                  padding: EdgeInsets.all(sy(1)),
                  height: width * 0.9,
                  width: width * 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(sy(50)),
                    child: CustomeImageView(
                      image:
                          "https://i.pinimg.com/236x/10/ec/40/10ec40040e57b1600faaf623e9780933.jpg",
                      // Urls.imageLocation +
                      //    Const.categoryList[i]["cat_image"].toString(),
                      placeholder: Urls.DummyImageBanner,
                      fit: BoxFit.cover,
                      height: width,
                      width: width,
                    ),
                  )),
              SizedBox(
                width: sy(8),
              ),
              Column(
                children: [
                  Text(
                   Lang("  name", " اسم ") ,
                    style: ts_Bold(sy(l), fc_bg),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_sharp, size: sy(n), color: fc_bg),
                      SizedBox(
                        width: sy(3),
                      ),
                      Text(
                       Lang(" city ", "مدينة  ") ,
                        style: ts_Regular(sy(n), fc_bg),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                  child: SizedBox(
                height: sy(2),
              )),
              IconButton(
                  onPressed: () {},
                  icon:
                      Icon(Icons.arrow_forward_ios, size: sy(l), color: fc_bg))
            ],
          ),
        ],
      ),
    );
  }

  productWidget() {
    return Container(
      color: fc_bg_mild,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
      child: AnimationLimiter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width * 0.8,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              SizedBox(
                height: sy(10),
              ),
              SizedBox(
                height: sy(10),
              ),
              for (int i = 0; i < productList.length; i++) productCard(i),
            ],
          ),
        ),
      ),
    );
  }

  productCard(int i) {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(10)),
      child: ElevatedButton(
        onPressed: () {
          // Navigator.push(context, OpenScreen(widget: UserProductView()));
        },
        style: ElevatedButton.styleFrom(
          // primary: fc_bg,
          primary: Colors.white,
          elevation: 1,
          padding: EdgeInsets.fromLTRB(sy(8), sy(8), sy(6), sy(8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sy(1)),
          ),
        ),
        child: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: sy(5),
                  ),
                  Container(
                      decoration: decoration_round(
                          TheamPrimary, sy(5), sy(5), sy(5), sy(5)),
                      padding: EdgeInsets.all(sy(1)),
                      height: Width(context) * 0.3,
                      width: Width(context) * 0.3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sy(5)),
                        child: CustomeImageView(
                          // image:
                          //   "https://i.pinimg.com/236x/09/43/87/0943876ce0688d47952efb7d2992d312.jpg",
                          image: Urls.imageLocation +
                              productList[i]["p_image"].toString(),
                          placeholder: Urls.DummyImageBanner,
                          fit: BoxFit.cover,
                          height: Width(context) * 0.25,
                          width: Width(context) * 0.2,
                        ),
                      )),
                  SizedBox(
                    width: sy(15),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          productList[i]["p_title"].toString(),
                          style: ts_Bold(sy(n), fc_2),
                          maxLines: 2,
                        ),
                        Text(
                          productList[i]["p_sell"].toString(),
                          style: ts_Bold(sy(n), fc_2),
                          maxLines: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: Width(context) * 0.3,
                              height: sy(20),
                              alignment: Alignment.center,
                              padding: EdgeInsets.fromLTRB(
                                  sy(10), sy(2), sy(10), sy(1)),
                              decoration: decoration_border(
                                  Colors.grey.shade400,
                                  Colors.grey.shade400,
                                  1,
                                  sy(5),
                                  sy(5),
                                  sy(5),
                                  sy(5)),
                              child: Text(
                                 Lang("Sold  ", " مُباع "),
                                style: ts_Regular(sy(n), fc_2),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showpop();
                              },
                              child: Container(
                                width: Width(context) * 0.2,
                                height: sy(20),
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(
                                    sy(5), sy(2), sy(5), sy(1)),
                                decoration: decoration_border(
                                    Colors.grey.shade400,
                                    Colors.grey.shade400,
                                    1,
                                    sy(5),
                                    sy(5),
                                    sy(5),
                                    sy(5)),
                                child: Text(
                                 Lang(" Edit ", "تعديل  "),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  /* Expanded(
                    child: Row(
                      children: [
                        Text(
                         Lang(" May 03 ", " 03 مايو "),
                          style: ts_Regular(sy((n)), fc_3),
                        )
                      ],
                    ),
                  )*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  categorywidget() {
    return Container(
      width: Width(context),
      height: sy(50),
      //  margin: EdgeInsets.all(sy(10)),
      alignment: Alignment.center,
      decoration:
          decoration_border(fc_bg, fc_bg, 1, sy(10), sy(10), sy(10), sy(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*  Container(
            width: sy(35),
            height: sy(35),
            decoration: decoration_border(
                fc_bg, fc_3, 1, sy(50), sy(50), sy(50), sy(50)),
            //decoration: decoration_round(fc_3, sy(20), sy(20), sy(20), sy(20)),
            alignment: Alignment.center,
            child: Container(
              width: sy(25),
              height: sy(25),
              decoration: decoration_round(
                  Colors.grey.shade200, sy(20), sy(20), sy(20), sy(20)),
              alignment: Alignment.center,
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.camera, size: sy(l), color: fc_2)),
            ),
          ),*/
          Container(
            width: sy(25),
            height: sy(25),
            decoration: decoration_round(
                Colors.grey.shade200, sy(20), sy(20), sy(20), sy(20)),
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {},
                icon: Icon(FontAwesomeIcons.file, size: sy(l), color: fc_3)),
          ),
          Container(
            width: sy(25),
            height: sy(25),
            decoration: decoration_round(
                Colors.grey.shade200, sy(20), sy(20), sy(20), sy(20)),
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {},
                icon: Icon(FontAwesomeIcons.camera, size: sy(l), color: fc_3)),
          ),
          Container(
            width: sy(25),
            height: sy(25),
            decoration: decoration_round(
                Colors.grey.shade200, sy(20), sy(20), sy(20), sy(20)),
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {},
                icon: Icon(FontAwesomeIcons.photoVideo,
                    size: sy(l), color: fc_3)),
          ),
          Container(
            width: sy(25),
            height: sy(25),
            decoration: decoration_round(
                Colors.grey.shade200, sy(20), sy(20), sy(20), sy(20)),
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.mail, size: sy(l), color: fc_3)),
          ),
          Container(
            width: sy(25),
            height: sy(25),
            decoration: decoration_round(
                Colors.grey.shade200, sy(20), sy(20), sy(20), sy(20)),
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {},
                icon:
                    Icon(FontAwesomeIcons.userEdit, size: sy(l), color: fc_3)),
          ),
          Container(
            width: sy(25),
            height: sy(25),
            decoration: decoration_round(
                Colors.grey.shade200, sy(20), sy(20), sy(20), sy(20)),
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {},
                icon: Icon(FontAwesomeIcons.checkSquare,
                    size: sy(l), color: fc_3)),
          ),
        ],
      ),
    );
  }

  tabWidget() {
    return Container(
      width: Width(context),
      height: sy(40),
      padding: EdgeInsets.all(sy(8)),
      decoration: decoration_border(Colors.grey.shade200, Colors.grey.shade200,
          1, sy(10), sy(10), sy(10), sy(10)),
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  servicetab = 0;
                });
              },
              child: Container(
                width: Width(context) * 0.25,
                height: sy(25),
                alignment: Alignment.center,
                decoration: decoration_border(
                    (servicetab == 0) ? fc_bg : Colors.grey.shade200,
                    Colors.grey.shade200,
                    1,
                    sy(10),
                    sy(10),
                    sy(10),
                    sy(10)),
                child: Text(
                   Lang(" My Ads ", " إعلاناتي "),
                  style: ts_Regular(sy(n), (servicetab == 0) ? fc_2 : fc_3),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  servicetab = 1;
                });
              },
              child: Container(
                width: Width(context) * 0.25,
                height: sy(25),
                alignment: Alignment.center,
                decoration: decoration_border(
                    (servicetab == 1) ? fc_bg : Colors.grey.shade200,
                    Colors.grey.shade200,
                    1,
                    sy(10),
                    sy(10),
                    sy(10),
                    sy(10)),
                child: Text(
                   Lang(" favourite ", " المفضلة "),
                  style: ts_Regular(sy(n), (servicetab == 1) ? fc_2 : fc_3),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  servicetab = 2;
                });
              },
              child: Container(
                width: Width(context) * 0.25,
                height: sy(25),
                alignment: Alignment.center,
                decoration: decoration_border(
                    (servicetab == 2) ? fc_bg : Colors.grey.shade200,
                    Colors.grey.shade200,
                    1,
                    sy(10),
                    sy(10),
                    sy(10),
                    sy(10)),
                child: Text(
                  Lang("Sold  ", "مُباع  "),
                  style: ts_Regular(sy(n), (servicetab == 2) ? fc_2 : fc_3),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  emptyCart() {
    return Container(
      color: fc_bg_mild,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: sy(50),
          ),
          Image.asset(
            'assets/images/emptyy.png',
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
          ),
          SizedBox(
            height: sy(10),
          ),
          Text(
            Lang('No Ads found', 'لم يتم العثور على العناصر'),
            style: ts_Regular(sy(n), fc_1),
          ),
          SizedBox(
            height: sy(5),
          ),
          Text(
            Lang('you do not have posted any Ads yet',
                'لم تنشر أي إعلانات حتى الآن'),
            style: ts_Regular(sy(n), fc_1),
          ),
        ],
      ),
    );
  }

  favouriteWidget() {
    return Container(
      color: fc_bg_mild,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
      child: AnimationLimiter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width * 0.8,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              SizedBox(
                height: sy(10),
              ),
              SizedBox(
                height: sy(10),
              ),
              for (int i = 0; i < favouriteList.length; i++)
                ProductCard(
                  i: i,
                  getProducts: favouriteList,
                ),
            ],
          ),
        ),
      ),
    );
  }

  soldProductWidget() {
    return Container(
      color: fc_bg_mild,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.fromLTRB(sy(5), sy(0), sy(5), sy(0)),
      child: AnimationLimiter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: MediaQuery.of(context).size.width * 0.8,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              SizedBox(
                height: sy(10),
              ),
              SizedBox(
                height: sy(10),
              ),
              for (int i = 0; i < 2; i++) soldProductCard(i),
            ],
          ),
        ),
      ),
    );
  }

  soldProductCard(int i) {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(10)),
      child: ElevatedButton(
        onPressed: () {
          /* Navigator.push(
              context,
              OpenScreen(
                  widget: ProductViewScreen(
                    pid: productList[i]['p_id'],
                    pname: productList[i]["p_title"],
                    image: productList[i]["p_image"],
                  )));*/
        },
        style: ElevatedButton.styleFrom(
          // primary: fc_bg,
          primary: Colors.white,
          elevation: 1,
          padding: EdgeInsets.fromLTRB(sy(4), sy(20), sy(6), sy(20)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sy(1)),
          ),
        ),
        child: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: sy(5),
                  ),
                  Container(
                      decoration: decoration_round(
                          TheamPrimary, sy(5), sy(5), sy(5), sy(5)),
                      padding: EdgeInsets.all(sy(1)),
                      height: Width(context) * 0.3,
                      width: Width(context) * 0.3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(sy(5)),
                        child: CustomeImageView(
                          image:
                              "https://i.pinimg.com/236x/09/43/87/0943876ce0688d47952efb7d2992d312.jpg",
                          //  image: Urls.imageLocation +
                          //  productList[i]["p_image"].toString(),
                          placeholder: Urls.DummyImageBanner,
                          fit: BoxFit.cover,
                          height: Width(context) * 0.25,
                          width: Width(context) * 0.2,
                        ),
                      )),
                  SizedBox(
                    width: sy(15),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              FontAwesomeIcons.tachometerAlt,
                              size: sy(n),
                              color: fc_3,
                            ),
                            SizedBox(
                              width: sy(7),
                            ),
                            Text(
                              '50000 km',
                              // productList[i]["p_title"],
                              style: ts_Bold(sy(n), fc_2),
                              maxLines: 2,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: sy(8),
                        ),
                        Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              FontAwesomeIcons.chair,
                              size: sy(n),
                              color: fc_3,
                            ),
                            SizedBox(
                              width: sy(7),
                            ),
                            Text(
                              '5' + Lang(" seat ", " مقعد ") ,
                              // productList[i]["p_title"],
                              style: ts_Bold(sy(n), fc_2),
                              maxLines: 2,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: sy(8),
                        ),
                        Container(
                          width: Width(context) * 0.3,
                          height: sy(20),
                          alignment: Alignment.center,
                          padding:
                              EdgeInsets.fromLTRB(sy(10), sy(2), sy(10), sy(1)),
                          decoration: decoration_border(
                              Colors.grey.shade400,
                              Colors.grey.shade400,
                              1,
                              sy(5),
                              sy(5),
                              sy(5),
                              sy(5)),
                          child: Text(
                           Lang(" Sold ", " مُباع ") ,
                            style: ts_Regular(sy(n), fc_bg),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              FontAwesomeIcons.car,
                              size: sy(n),
                              color: fc_3,
                            ),
                            SizedBox(
                              width: sy(4),
                            ),
                            Text(
                              '4',
                              // productList[i]["p_title"],
                              style: ts_Bold(sy(n), fc_2),
                              maxLines: 2,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: sy(8),
                        ),
                        Row(
                          //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.settings,
                              size: sy(n),
                              color: fc_3,
                            ),
                            SizedBox(
                              width: sy(4),
                            ),
                            Text(
                                Lang("Auto  ", " تلقائي ") ,
                              // productList[i]["p_title"],
                              style: ts_Bold(sy(n), fc_2),
                              maxLines: 2,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: sy(8),
                        ),
                        Container(
                          width: Width(context) * 0.2,
                          height: sy(20),
                          alignment: Alignment.center,
                          padding:
                              EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(1)),
                          decoration: decoration_border(
                              Colors.grey.shade400,
                              Colors.grey.shade400,
                              1,
                              sy(5),
                              sy(5),
                              sy(5),
                              sy(5)),
                          child: Text(
                              Lang(" Edit ", "تعديل  "),
                            style: ts_Regular(sy(n), fc_bg),
                          ),
                        ),
                        SizedBox(
                          height: sy(15),
                        ),
                        Text(
                           Lang(" May 03 ", "03 مايو  "),
                          style: ts_Regular(sy((n)), fc_3),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bottomNavigation() {
    return BottomAppBar(
      color: fc_bg,
      shape: CircularNotchedRectangle(), //shape of notch
      notchMargin: 5, //notche margin between floating button and bottom appbar
      child: Row(
        //children inside bottom appbar
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.home,
              color: fc_2,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: fc_2,
            ),
            onPressed: () {},
          ),
          IconButton(
              icon: Icon(
                Icons.shopping_bag_outlined,
                color: TheamPrimary,
                size: sy(xl),
              ),
              onPressed: () {
                /* Navigator.pushReplacement(
                        context,
                        OpenScreen(
                            widget: CartScreen(
                          stage: 1,
                        )));*/
              }),
          IconButton(
            icon: Icon(
              Icons.people,
              color: fc_2,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context, OpenScreen(widget: UserProfile()));
            },
          ),
        ],
      ),
    );
  }

  buttoncard(String image, String name) {
    return Container(
        child: Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < 6; i++)
          Container(
            color: Colors.white,
            //  decoration: decoration_border(fc_bg, fc_bg, 0.0, sy(0), sy(0), sy(0), sy(0)),
            alignment: Alignment.center,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(sy(0)),
                child: CustomeImageView(
                  image: Urls.imageLocation + image.toString(),
                  placeholder: Urls.DummyImageBanner,
                  fit: BoxFit.cover,
                  height: Width(context) * 0.12,
                  width: Width(context) * 0.12,
                )),
          ),
        SizedBox(
          width: sy(8),
        ),
        Text(
          name,
          style: ts_Regular(sy(n), fc_2),
        ),
      ],
    ));
  }

  _showpop() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                Container(
                  height: 0.5,
                  color: Colors.grey[500],
                ),
                ListTile(
                    title: Text(
                      Lang(" Edit ", " تعديل ") ,
                      style: ts_Regular(sy(n), fc_3),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(false);
                      setState(() {
                        //  ETduration.text = selectedDuration;
                        //    ETprice.text = selectedServicePrice;
                        //    screen = 'edit';
                      });
                    }),
                ListTile(
                    title: Text(
                    Lang(" Delete ", "حذف  "),
                      style: ts_Regular(sy(n), fc_3),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(false);
                      //  _deletedoctor(selectedDoctorServiceID.toString(),
                      //     selectedServiceArray);
                    }),
                //if (selectedServiceStatus == "0")
              ],
            ),
          );
        });
  }
}

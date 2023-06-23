import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/bottom_navigation.dart';
import 'package:sevenemirates/maps/map_screen.dart';
import 'package:sevenemirates/screen/user/category_screen.dart';
import 'package:sevenemirates/screen/user/product_list.dart';
import 'package:sevenemirates/screen/user/product_view_screen.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sevenemirates/components/flashbar.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/router/open_screen.dart';
import 'package:sevenemirates/utils/app_settings.dart';
import 'package:sevenemirates/utils/const.dart';
import 'package:sevenemirates/utils/shared_preferences.dart';
import 'package:sevenemirates/utils/style_sheet.dart';
import 'package:http/http.dart' as http;
import 'package:sevenemirates/utils/urls.dart';
import 'package:flutter_blurhash/src/blurhash_widget.dart';
import '../../../components/image_viewer.dart';
import '../../../components/url_open.dart';
import '../../../layout/product_card.dart';
import '../../../main.dart';
import '../../product_details_screen/product_details_screen.dart';
import '../../sub_cat_screen/sub_cat_screen.dart';
import '../../view_stories_screen/model/model.dart';
import '../../view_stories_screen/view_Stories_screen.dart';
import '../about_screen.dart';
import '../add_product_screen/add_product_screen.dart';
import 'package:location/location.dart' as loc;
import 'package:octo_image/octo_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../add_product_screen/model/CategoryModel.dart';
import 'model/products_model.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  String UserId = '';
  String UserName = '';

  bool showProgress = false;
  Map data = Map();

  List appSettings = [];
  List productList = [];
  List bannerList = [];
  List userDetail = [];

  LatLng _kMapCenter = LatLng(19.018255973653343, 72.84793849278007);
  bool _serviceEnabled = false;
  loc.Location location = loc.Location();
  loc.PermissionStatus _permissionGranted = loc.PermissionStatus.denied;
  late loc.LocationData _locationData;
  String mapAddress = '';
  String mapLat = '';
  String mapLng = '';
  String mapCity = '';
  String skipSignup = '';
  final photos = [
    'https://drivexotic.com/wp-content/uploads/2022/08/AMG-2-scaled.jpg',
    'https://drivexotic.com/wp-content/uploads/2022/08/AMG-2-scaled.jpg',
    'https://drivexotic.com/wp-content/uploads/2022/08/AMG-2-scaled.jpg',
    'https://drivexotic.com/wp-content/uploads/2022/08/AMG-2-scaled.jpg',
    'https://drivexotic.com/wp-content/uploads/2022/08/AMG-2-scaled.jpg'
  ];
  int currentImageIndex = 0;
  late Future<List<Product>> _productsListFuture;

  @override
  void initState() {
    super.initState();
    _productsListFuture = getNewProductsByType(
        restEndPoint: 'products_by_type.php', adType: 'vip');
    print('_productsListFuture${_productsListFuture}');
    getSharedStore();
    getStories();
   }

  @override
  void dispose() {
    super.dispose();
  }

  getSharedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      UserId = prefs.getString(Const.UID) ?? '';
      skipSignup = prefs.getString(Const.SKIP_SIGNUP_VALUE) ?? '';
      UserId = Provider.of<AppSetting>(context, listen: false).uid;
      UserName = Provider.of<AppSetting>(context, listen: false).name;
      mapAddress = prefs.getString(Const.MAPADDRESS) ?? '';
      mapLat = prefs.getString(Const.MAPLAT) ?? '';
      mapLng = prefs.getString(Const.MAPLNG) ?? '';
      mapCity = prefs.getString(Const.MAPCITY) ?? '';
      Provider.of<AppSetting>(context, listen: false).mapAddress = mapAddress;
      Provider.of<AppSetting>(context, listen: false).maplat = mapLat;
      Provider.of<AppSetting>(context, listen: false).maplon = mapLng;
      Provider.of<AppSetting>(context, listen: false).mapCity = mapCity;
      Provider.of<AppSetting>(context, listen: false).skipSignup = skipSignup;
      getLocation();
      if (mapAddress == '') {
        // Navigator.of(context).pop();
        _openMap();
      }
      _getServer();
    });
  }

  _getServer() async {
    try {
      setState(() {
        showProgress = true;
      });
      apiTest('server');
      print('UserId.toString()'+UserId.toString());
      var body = {
        // "key":'2520',
        "key": Const.APPKEY,
        "uid": UserId.toString(),
      };
      final response = await http.post(Uri.parse(Urls.Dashboard),
          headers: {HttpHeaders.acceptHeader: Const.POSTHEADER}, body: body);
      if(response.statusCode==200){
        print(response.body);
      log('url is =>>>>>${Urls.Dashboard}');
      print('140');
      data = json.decode(response.body);
      log('bodyData ::$data');

      setState(() {
        showProgress = false;
      });
      setState(() {
        if (data["success"] == true) {
          Const.categoryList = data["categorylist"];
          Const.subcategoryList = data["subcategorylist"];
          Const.fieldsList = data["fields"];
          Const.lableList = data["lables"];
          appSettings = data["settings"];
          productList = data["productlist"];
          bannerList = data["banner"];
          userDetail = data["user"];
          print(bannerList.toString());
          print('Const.categoryList${Const.categoryList}');
          print('Const.subcategoryList${Const.subcategoryList}');
          saveUserData();
        } else {
          Pop.errorTop(
              context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
        }
      });

      }
      else{
        print(response.statusCode);
      }
    }catch(e){
      print('--------${e}----');
    }
  }

  saveUserData() {
    if (userDetail.length != 0) {
      SharedStoreUtils.setValue(Const.UID, userDetail[0]["u_id"]);
      SharedStoreUtils.setValue(Const.NAME, userDetail[0]["name"] ?? '');
      SharedStoreUtils.setValue(Const.PHONE, userDetail[0]["phone"]);
      SharedStoreUtils.setValue(
          Const.PROFILE, userDetail[0]["profile_pic"] ?? '');
      SharedStoreUtils.setValue(
          Const.COUNTRY_CODE, userDetail[0]["country_id"] ?? '');
      SharedStoreUtils.setValue(
          Const.COUNTRY_NAME, userDetail[0]["country"] ?? '');
      SharedStoreUtils.setValue(
          Const.COUNTRY_NAME_ARAB, userDetail[0]["country_arab"] ?? '');
      SharedStoreUtils.setValue(Const.CITY_NAME, userDetail[0]["city"] ?? '');
      SharedStoreUtils.setValue(
          Const.CITY_NAME_ARAB, userDetail[0]["city_arab"] ?? '');
      SharedStoreUtils.setValue(Const.CITY_ID, userDetail[0]["city_id"] ?? '');
      SharedStoreUtils.setValue(Const.EMAIL, userDetail[0]["email"] ?? '');
      SharedStoreUtils.setValue(
          Const.EMAIL_VERIFY, userDetail[0]["email_verify"] ?? '0');
      SharedStoreUtils.setValue(
          Const.MEMBER, userDetail[0]["membership"] ?? '0');
      SharedStoreUtils.setValue(Const.BIO, userDetail[0]["about"] ?? '');
      Provider.of<AppSetting>(context, listen: false).uid =
          userDetail[0]["u_id"] ?? '0';
      Provider.of<AppSetting>(context, listen: false).name =
          userDetail[0]["name"] ?? '';
      Provider.of<AppSetting>(context, listen: false).profile =
          userDetail[0]["profile_pic"] ?? '';
      Provider.of<AppSetting>(context, listen: false).email =
          userDetail[0]["email"] ?? '';
      Provider.of<AppSetting>(context, listen: false).emailVerify =
          userDetail[0]["email_verify"] ?? '0';
      Provider.of<AppSetting>(context, listen: false).phone =
          userDetail[0]["phone"] ?? '';
      Provider.of<AppSetting>(context, listen: false).city =
          userDetail[0]["city"] ?? '';
      Provider.of<AppSetting>(context, listen: false).cityId =
          userDetail[0]["city_id"] ?? '';
      Provider.of<AppSetting>(context, listen: false).country =
          userDetail[0]["country"] ?? '';
      Provider.of<AppSetting>(context, listen: false).countryId =
          userDetail[0]["country_id"] ?? '';
      Provider.of<AppSetting>(context, listen: false).member =
          userDetail[0]["membership"] ?? '';
      Provider.of<AppSetting>(context, listen: false).bio =
          userDetail[0]["about"] ?? '';
      if (mapAddress == '') {
        Provider.of<AppSetting>(context, listen: false).mapAddress =
            userDetail[0]["address"] ?? '';
        Provider.of<AppSetting>(context, listen: false).mapCity =
            userDetail[0]["map_city"] ?? '';
        Provider.of<AppSetting>(context, listen: false).maplat =
            userDetail[0]["lat"] ?? '';
        Provider.of<AppSetting>(context, listen: false).maplon =
            userDetail[0]["lng"] ?? '';
        Provider.of<AppSetting>(context, listen: false).map =
            userDetail[0]["lng"] ?? '' + ',' + userDetail[0]["lng"] ?? '';
        SharedStoreUtils.setValue(
            Const.MAPADDRESS, userDetail[0]["address"] ?? '');
        SharedStoreUtils.setValue(
            Const.MAPCITY, userDetail[0]["map_city"] ?? '');
        SharedStoreUtils.setValue(Const.MAPLAT, userDetail[0]["lat"] ?? '');
        SharedStoreUtils.setValue(Const.MAPLNG, userDetail[0]["lng"] ?? '');
        SharedStoreUtils.setValue(Const.MAP,
            userDetail[0]["lng"] ?? '' + ',' + userDetail[0]["lng"] ?? '');
      }
    }
  }

  late GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();

  Future<List<Product>> getNewProductsByType(
      {required String restEndPoint, required String adType}) async {
    final url =
        Uri.parse('https://www.7emiratesapp.ae/API/mobile_api/$restEndPoint');
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final data = <String, String>{
      'type': adType,
      'key': '2520',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: data,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final productList = ProductList.fromJson(jsonResponse);
      return productList.productlist;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // List<Category> storiesProduct=[];
  // List  ListOfCategories=[];
   // ProductList productsByStoryCat=ProductList(success: true, productlist: []);
// List  allStoriesForEachCat=[];
  // getStories( )async{
   // // var resultsOfStories=await getNewProductsByType(
   // //      restEndPoint: 'products_by_type.php', adType: 'stories');
   // //
   // //  var result2=await getNewCategory(restEndPoint: 'cats_by_type.php',adType:'stories');
   // // print('result2${resultsOfStories.length}');
   // // for (Product item in results) {
   // // for (final item2 in result2) {
   // //   if (item.cId== item2.id) {
   // //
   // //     print('item2.name${item2.name}');
   // //     storiesProduct.add(item2);
   // //     // productsByStoryCat.productlist.add(item);
   // //     count++;
   // //     print('count,, $count');
   // //
   // //
   // //   }
   // //   }
   // //
   // //
   // // }
   // // return item2.name;
   // //  resultsOfStories.forEach((element) {
   // //    print('results ${element.name}');
   // //    print('results ${element.cId}');
   // //
   // //    print('ListOfCategories'+ '${ListOfCategories.length}');
   // //  });
   //     var resultsOfStories = await getNewProductsByType(
   //        restEndPoint: 'products_by_type.php', adType: 'stories');
   //    var result2 = await getNewCategory(
   //        restEndPoint: 'cats_by_type.php', adType: 'stories');
   //    var addedCIds = <String>{};
   //    ListOfCategories = [];
   //    for (var element in resultsOfStories) {
   //      if (addedCIds.contains(element.cId)) {
   //        continue;
   //      }
   //      ListOfCategories.add(element);
   //      addedCIds.add(element.cId);
   //    }
   //    print('ListOfCategories: ${ListOfCategories.length}');
   //  }



  var storyLists2 = <String, List<Product>>{};
  var storyList2 = <Product>[];
  var categoryStorySet = <Category>{};

  getStories() async {
    var resultsOfStories = await getNewProductsByType(
        restEndPoint: 'products_by_type.php', adType: 'stories');
    var resultOfCategory = await getNewCategory(
        restEndPoint: 'cats_by_type.php', adType: 'stories');
    for (var category in resultOfCategory) {
      var storyList = <Product>[];
      for (var story in resultsOfStories) {
        if (story.cId== category.id) {
          storyList.add(story);
          categoryStorySet.add(category);
        }
      }
      storyLists2[category.id] = storyList;
      print( 'Category: name = ${category.name} c_id = ${category.id} , Story count: ${storyList.length}');
    }
 storyLists2.forEach((key, value) {
   setState(() {
   storyList2.addAll(value);

   });
 });

  //   var storyLists2 = <List>{};
  // getStories() async {
  //   var resultsOfStories = await getNewProductsByType(
  //       restEndPoint: 'products_by_type.php', adType: 'stories');
  //   var resultOfCategory = await getNewCategory(
  //       restEndPoint: 'cats_by_type.php', adType: 'stories');
  //   // var storyLists = <List>{};
  //   for (var category in resultOfCategory) {
  //     var storyList = <dynamic>[];
  //       // print('category.id :${category.id}');
  //     for (var story in resultsOfStories) {
  //       if (story.cId == category.id) {
  //         storyList.add(story);
  //       }
  //     }
  //     storyLists2.add(storyList);
  //      print('Category: name =${category.name} c_id =${category.id}  , Story count: ${storyList.length}');
  //      print(storyLists2);
  //   }
  //

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    initRelativeScaler(context);
    UserId = Provider.of<AppSetting>(context, listen: false).uid;
    skipSignup = Provider.of<AppSetting>(context, listen: false).skipSignup;

    return WillPopScope(
      child: MaterialApp(
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
              child: Scaffold(
                drawer: Drawer(
                  backgroundColor: fc_bg,
                  // decoration: BoxDecoration(
                  //   color: Colors.blueGrey, // Set the background color of the Drawer
                  // ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/logoonly.png',
                              height: sy(50),
                              fit: BoxFit.fill,
                            ),
                            Text('7 Emirates '),
                          ],
                        ),
                        decoration: BoxDecoration(
                            // color: Colors,
                            ),
                      ),
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.login,
                      //     color: fc_5,
                      //   ),
                      //   title: Text('Sign In'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle sign in action
                      //   },
                      // ),
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.star,
                      //     color: fc_5,
                      //   ),
                      //   title: Text('Just for You'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle just for you action
                      //   },
                      // ),
                    ...List.generate(Const.categoryList.length, (i) =>  ListTile(
                        leading:  Icon(
                          Icons.category_outlined,
                          color: fc_5,
                          // size: ,
                        ),
                        title: Text(Const.categoryList[i]["c_name$cur_Lang"]
                            .toString(),
                            style: ts_Regular(12, Colors.grey),

                        ),
                        subtitle:  Text(
                          Const.categoryList[i]["countproducts"]
                              .toString() +
                              ' ' +
                              Lang('items', 'عناصر'),
                          style: ts_Regular(sy(s - 1), Colors.black),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                        onTap: () {
                          Navigator.push(
                          context,
                          OpenScreen(
                              widget: ProductListScreen(
                            cid: Const.categoryList[i]["c_id"],
                          )));  }, ),
                      ),
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.directions_car,
                      //     color: fc_5,
                      //   ),
                      //   title: Text('Cars'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle cars action
                      //   },
                      // ),
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.directions_boat,
                      //     color: fc_5,
                      //   ),
                      //   title: Text('Yachts'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle yachts action
                      //   },
                      // ),
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.watch,
                      //     color: fc_5,
                      //   ),
                      //   title: Text('Watches'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle watches action
                      //   },
                      // ),
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.flight,
                      //     color: fc_5,
                      //   ),
                      //   title: Text('Jets'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle jets action
                      //   },
                      // ),
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.motorcycle,
                      //     color: fc_5,
                      //   ),
                      //   title: Text('Motorcycles'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle motorcycles action
                      //   },
                      // ),
                      Divider(),
                      ListTile(
                        title: Text( Lang("About us  ", " من نحن ")),
                        leading: Icon(Icons.info_outline, color: fc_5,size: 20,),
                        onTap: () {
                          // GestureDetector(
                          //   onTap: () {
                          // Navigator.pop(context);
                              Navigator.push(context, OpenScreen(widget: AboutScreen()));

                            // child: menuItem(Icons.info_outline, TheamButton,


                          // Handle about us action
                        },
                      ),
                      // ListTile(
                      //   title: Text('Help'),
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     // Handle help action
                      //   },
                      // ),
                      ListTile(
                        leading: Icon(FontAwesomeIcons.whatsapp, color: fc_5,size: 20,),

                        title: Text( Lang("Contact us  ", "اتصل بنا  ")),

                        onTap: () {

                              UrlOpenUtils.whatsapp(_scaffoldKey);
                            },
                            // child: menuItem(FontAwesomeIcons.whatsapp, TheamButton,


                          // Handle contact us action

                      ),

                    ],
                  ),
                ),
                // appBar: AppBar(
                //   backgroundColor: Colors.transparent,
                // ),
                // bottomNavigationBar:bottomNavigation(),
                bottomNavigationBar: BottomNavigationWidget(
                  mcontext: context,
                  ishome: true,
                  order: 1,
                ),
                backgroundColor: Colors.white,
                key: _scaffoldKey1,
                body: Container(
                  color: fc_bg,
                  height: Height(context),
                  width: Width(context),
                  child: Stack(
                    children: <Widget>[
                      // Positioned(
                      //   top: sy(0),
                      //   left: 0,
                      //   right: 0,
                      //   child: titilebar(),
                      // ),
                      Positioned(
                        top: sy(0),
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _screenBody(),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
      onWillPop: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: fc_bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sy(5)),
          ),
          title: Text(
            Lang('Exit', "خروج"),
            style: ts_Regular(sy(l), fc_1),
            textAlign: TextAlign.left,
          ),
          content: Text(
            Lang("Are you sure want to close App?",
                "هل أنت متأكد من أنك تريد إغلاق التطبيق؟"),
            style: ts_Regular(sy(n), fc_1),
            textAlign: TextAlign.left,
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Container(
                child: Text(
                  Lang("No", "لا"),
                  style: ts_Regular(sy(n), fc_1),
                ),
                padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: Container(
                child: Text(
                  Lang("Yes", "نعم"),
                  style: ts_Regular(sy(n), fc_1),
                ),
                padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
              ),
            ),
          ],
        ),
      ).then((value) => value ?? false),
    );
  }
  ///carousel
  categoryWidget() {
    return FutureBuilder<List<Product>>(
      future: _productsListFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('snapshot.hasData ${snapshot.hasData}');
          print('snapshot.data ${snapshot.data!.length}');
          final products = snapshot.data;

          return Stack(children: [
      Positioned(
        // child: InkWell(
        //   child: CarouselSlider(
        //     options: CarouselOptions(
        //         autoPlay: true,
        //         height: MediaQuery.of(context).size.height / 1.5,
        //         viewportFraction: 1,
        //         onPageChanged: (index1, reason) {
        //           setState(() {
        //             currentImageIndex = index1;
        //           });
        //         }),
        //     // items:
        //
        //     items: photos
        //         .map(
        //           (item) => Container(
        //             clipBehavior: Clip.antiAlias,
        //             width: MediaQuery.of(context).size.width,
        //             margin: null,
        //             padding: EdgeInsets.only(left: 5, right: 5),
        //             decoration: BoxDecoration(
        //               border: Border.all(color: Colors.transparent, width: 0),
        //               borderRadius: BorderRadius.circular(0),
        //             ),
        //             child: OctoImage(
        //               image: CachedNetworkImageProvider(
        //                 item,
        //               ),
        //               placeholderBuilder: OctoPlaceholder.blurHash(
        //                   'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
        //                   fit: BoxFit.cover),
        //               errorBuilder: (context, url, error) {
        //                 return const BlurHash(
        //                     hash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj');
        //               },
        //               fit: BoxFit.cover,
        //             ),
        //           ),
        //         )
        //         .toList(),
        //   ),
        //   onTap: () {
        //     // showImageViewer(
        //     //     context,
        //     //     Image
        //     //         .network(index
        //     //         .photos![controller.currentImageIndex.value])
        //     //         .image,
        //     //     // Image.network(index.photos!.first).image,
        //     //     swipeDismissible: true,
        //     //     doubleTapZoomable: true);
        //     // Get.toNamed(AppRoute.detailsScreen);
        //   },
        // ),
        child :  CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  height: MediaQuery.of(context).size.height / 1.5,
                  viewportFraction: 1,
                  onPageChanged: (index1, reason) {
                    setState(() {
                      currentImageIndex = index1;
                    });
                  },
                ),
                items: products!
                    .map((product) => Container(
                  height: MediaQuery.of(context).size.height,
                    clipBehavior: Clip.antiAlias,
                    width: MediaQuery.of(context).size.width,
                    margin: null,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          top: 0,
                          right: 0,
                          left: 0,
                          child: OctoImage(
                            image: CachedNetworkImageProvider(
                              Urls.imageLocation + product.pImage??'',
                            ),
                            placeholderBuilder: OctoPlaceholder.blurHash(
                                'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                                fit: BoxFit.fill),
                            errorBuilder: (context, url, error) {
                              return const BlurHash(
                                  hash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj');
                            },
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          bottom: sy(15),
                          left: 10,
                          right: 10,
                          child:  GestureDetector(
                          child:  Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product.pTitle}$cur_Lang'.capitalize()
                                // '${product.pTitle}'
                                ,style:ts_Regular(sy(xl - 1), Colors.white),),
                            Text('${product.pDetail}$cur_Lang'??''.capitalize(),
                                    // product.pAddress,
                                    style:ts_Regular(sy(s - 1), Colors.white),),




                              // Text('${product.pAddress}',style:ts_Regular(sy(s - 1), Colors.white),),
                            ],
                          ),
                            onTap: (){
                              Navigator.push(
                                  context,
                                  OpenScreen(
                                      widget:ProductDetails(product:product)
                                  ));
                            },
                        ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              )
      ),
      // Obx(  () =>
      Positioned(
        top: sy(2),
        left: 0,
        right: 0,
        child: titilebar(),
      ),
      Positioned(
          bottom: Width(context) / 30,
          right: 0,
          left: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSmoothIndicator(
                activeIndex: currentImageIndex,
                count: products.length < 7 ? products.length : 7,
                effect: ExpandingDotsEffect(
                  spacing: 8.0,
                  radius: 1.0,
                  dotWidth: 10,
                  dotHeight: 4.0,
                  // paintStyle: PaintingStyle.stroke,
                  strokeWidth: 1.5,
                  dotColor: Colors.grey.shade700,
                  activeDotColor:Colors.grey.shade300
                ),
              ),
            ],
          )),
      Positioned(
        top: sy(35),
        right: 0,
        left: 0,
        child: Container(
          color: Colors.transparent,
          width: Width(context),
          // margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
          padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(10)),
          //alignment: Alignment.center,
          child: Column(
            children: [
              Divider(
                color: Colors.white24,
                thickness: .5,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0;
                      i < Const.categoryList.length && i < 7;
                      i++)
                        GestureDetector(
                            child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.fromLTRB(
                                  sy(0), sy(0), sy(0), sy(0)),
                              margin: EdgeInsets.fromLTRB(
                                  sy(0), sy(0), sy(10), sy(0)),
                              child: Column(
                                children: [
                                  // Image.network(
                                  //        Urls.imageLocation +
                                  //            Const.categoryList[i]["c_image"].toString(),
                                  //        width: Width(context)/9,
                                  //        height: Width(context)/9,
                                  //        fit: BoxFit.fill,
                                  //       ),

                                  SizedBox(
                                    height: sy(4),
                                  ),
                                  Text(
                                    Const.categoryList[i]["c_name$cur_Lang"]
                                        .toString(),
                                    style: ts_Bold(sy(s), fc_6),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    height: sy(2),
                                  ),
                                  Text(
                                    Const.categoryList[i]["countproducts"]
                                        .toString() +
                                        ' ' +
                                        Lang('items', 'عناصر'),
                                    style: ts_Regular(sy(s - 1), Colors.black),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                              context,
                              OpenScreen(
                                  widget: ProductListScreen(
                                cid: Const.categoryList[i]["c_id"],
                              )));
print('productList //${ Const.subcategoryList[i] }');
 // print('productList //${ Const.categoryList[i] }');
 // print('productList //${ productList[i]['products'] }');
 //                              Navigator.push(
 //                                  context,
 //                                  OpenScreen(
 //                                      widget: PlacesScreen(
 //                                        getProducts: Const.subcategoryList ,
 //                                        // productList1:productList[i]['products'],
 //                                        cid: Const.categoryList[i]["c_id"],
 //
 //
 //                           )));

        }),
                      GestureDetector(
                          child: Container(
                            padding:
                            EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(0)),
                            margin:
                            EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(0)),
                            alignment: Alignment.center,
                            child: Container(
                              margin: EdgeInsets.all(sy(0)),
                              height: Width(context) * 0.12,
                              width: Width(context) * 0.12,
                              alignment: Alignment.center,
                              decoration: decoration_round(
                                  TheamPrimary, sy(50), sy(50), sy(50), sy(50)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(sy(50)),
                                child: Text(
                                  Lang(" View all", "مشاهدة الكل "),
                                  style: ts_Regular(sy(xs), fc_bg),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context, OpenScreen(widget: CategoryScreen()));
                          }),
                    ],
                  ),
                ),
              ),
              Divider(
                color: Colors.white24,
                thickness: .5,
              ),
            ],
          ),
        ),
      ),
    ]);}
          else if (snapshot.hasError) {
      return Text('${snapshot.error}');
    } else {
    return Center(
    child: CircularProgressIndicator(),
    );
    }
  }

    );}
//main layout
  _screenBody() {
    return Container(
      color: fc_bg,
      width: Width(context),
      //  decoration: decoration_round(fc_bg, sy(7), sy(7), sy(0), sy(0)),
      child: SingleChildScrollView(
          //    physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nameBar(),

              if (showProgress == true)
                LoadingPlacement(
                    width: Width(context), height: Height(context)),
              if (Const.categoryList.length != 0) categoryWidget(),
              if ( storyLists2 != 0)    storyWidget(),
              if (bannerList.length != 0) bannerWidget(),
              if (productList.length != 0) productBlockWidget(),
            ],
          )),
    );
  }

  storyWidget() {
    String selectedCategoryId;
    List <Category>list=categoryStorySet.toList();

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: sy(4),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Lang(
                "Stories ",
                " الحالات",
              ),
              style: ts_Bold(sy(n), fc_1),
            ),
          ),
    ///%%%%%%%
            ...List.generate(
              list.length,
              // storyList2.length,
                   (index) {
                     // void printCategoryId() {
                     //   if (index < list.length) {
                     //     Category category = list[index];
                     //     print("Category ID: ${category.id}");
                     //     index++;
                     //   }
                     // }
                     Category category = list[index];
                return Card(
                  child: GestureDetector(
                    onTap: () {
                      selectedCategoryId = category.id;


                      ///the bottom works
                      Navigator.push(
                          context,
                          OpenScreen(
                              widget: StoryPage(
                                category: category,
                                stories: storyLists2[selectedCategoryId]!,
                                 storiesLength: list.sublist(index),
                                selectedCategoryId: list[index].id,
                              )));
                      },
                    child: Stack(
                      children: [
                        Container(
                          color:Colors.white,
                          child: CustomeImageView(
                             image:   Urls.imageLocation +list[index].image.toString(),
                          placeholder: Urls.DummyImageBanner,
                            fit: BoxFit.contain,
                            blurBackground: false,
                            height: Width(context) * 0.31,
                            width: Width(context),
                            radius: sy(55),
                          ),
                        ),
                        Positioned(
                          top: 30,
                          left:10,
                          child: Text( '${list[index].name}$cur_Lang'.capitalize(),
                            style: ts_Bold(sy(n), fc_1),
                          ),
                        ),

                        SizedBox(
                          height: sy(4),
                        ),
                      ],
                    ),
                  ),
                );

              },

            )
        ]);
  }



  productBlockWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(0), sy(10), sy(0), sy(0)),
      width: Width(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < productList.length; i++) productWidget(i),
        ],
      ),
    );
  }

  productWidget(int i) {
    List productItems = [];
    productItems = productList[i]['products'];
    if (productItems.length != 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Lang("Latest ", " أحدث") +
                          ' ' +
                          productList[i]['c_name$cur_Lang'].toString(),
                      style: ts_Bold(sy(n), fc_1),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                         Navigator.push(
                            context,
                            OpenScreen(
                                widget: ProductListScreen(
                              cid: productList[i]['c_id'].toString(),
                            )));




                      },
                      child: Text(
                        Lang(" View all", "مشاهدة الكل "),
                        style: ts_Regular(sy(s), Colors.blue.shade700),
                      ))
                ],
              ),
            ),

            for (int j = 0; j < productItems.length; j++)
              Container(
                margin: EdgeInsets.fromLTRB(sy(5), sy(2), sy(5), sy(4)),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        OpenScreen(
                            widget: ProductViewScreen(
                          pid: productItems[j]["p_id"].toString(),
                          pname: productItems[j]["p_title"].toString(),
                          pimage: productItems[j]["p_image"].toString(),
                        )));
                  },
                  style: elevatedButtonTrans(),
                  child: ProductCard(i: j, getProducts: productItems),
                ),
              ),

            SizedBox(
              height: sy(5),
              width: Width(context),
            ),
            CustomeImageView(
              image: Urls.imageLocation + productList[i]['c_banner'].toString(),
              width: Width(context),
              height: Width(context) * 0.35,
              fit: BoxFit.cover,
              blurBackground: true,
              radius: sy(0),
            ),
            //SizedBox(height: sy(5),width: Width(context),),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: Width(context),
        height: sy(0),
      );
    }
  }

  titilebar() {
    return Container(
        padding: EdgeInsets.fromLTRB(sy(15), sy(8), sy(10), sy(8)),
        width: Width(context),
        height: sy(44),
        decoration: BoxDecoration(color: Colors.transparent),
        child: GestureDetector(
          onTap: () {
            _openMap();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logoonly.png',
                height: sy(50),
                fit: BoxFit.fill,
              ),
              IconButton(
                  onPressed: () {
                    // Scaffold.of(context).openDrawer();

                    _scaffoldKey1.currentState?.openDrawer();
                  },
                  icon: Icon(Icons.menu, color: Colors.white))
              // SizedBox(
              //   width: sy(10),
              // ),
              // Text(
              //   (mapCity == '') ? Lang(" Location ", " موقع ") : mapCity,
              //   style: ts_Regular(sy(n), Colors.black),
              // ),
              // SizedBox(
              //   width: sy(5),
              // ),
              // Icon(
              //   Icons.arrow_drop_down,
              //   size: sy(xl),
              //   color: Colors.black,
              // )
            ],
          ),
        ));
  }

  ///commented
  // nameBar() {
  //   return Container(
  //     color: fc_bg,
  //     padding: EdgeInsets.fromLTRB(sy(10), sy(15), sy(10), sy(15)),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  // Text(
  //   Lang("What are you  ", "ما الذي تبحث عنه اليوم؟"),
  //   style: ts_Bold(sy(xl), fc_2),
  // ),
  // SizedBox(
  //   height: sy(5),
  // ),
  // Text(
  //   Lang(" looking for today ? ", ""),
  //   style: ts_Bold(sy(xl), fc_2),
  // ),
  // SizedBox(
  //   height: sy(15),
  // ),
  // GestureDetector(
  //   onTap: () {
  //     Navigator.push(context, OpenScreen(widget: SearchScreen()));
  //   },
  //   child: Container(
  //     height: sy(40),
  //     child: Stack(
  //       children: [
  //         Positioned(
  //           left: sy(0),
  //           right: sy(5),
  //           top: sy(4),
  //           bottom: sy(4),
  //           child: Container(
  //             height: sy(40),
  //             alignment: Alignment.centerLeft,
  //             decoration: decoration_round(
  //                 fc_bg2, sy(20), sy(20), sy(20), sy(20)),
  //             padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(5), sy(5)),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.search,
  //                   color: fc_2,
  //                   size: sy(xl),
  //                 ),
  //                 SizedBox(
  //                   width: sy(5),
  //                 ),
  //                 Text(
  //                   Lang("Search here  ", " ابحث هنا "),
  //                   style: ts_Regular(sy(n), fc_2),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   ),
  // )
  //       ],
  //     ),
  //   );
  // }

  //cards
  bannerWidget() {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(10), sy(15), sy(10), sy(0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                Lang(" Best Selling ", "أفضل مبيعات  ").toString(),
                style: ts_Bold(sy(n), fc_1),
              ),
            ],
          ),
          SizedBox(
            height: sy(10),
          ),
          if (bannerList.length != 0)
            Container(
              width: Width(context),
              height: Width(context) * 0.4,
              // color: Colors.red,
              child: CarouselSlider.builder(
                  itemCount: bannerList.length,
                  options: CarouselOptions(
                    height: 400,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.linear,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemBuilder: (BuildContext context, int i,
                          int pageViewIndex) =>
                      GestureDetector(
                        onTap: () {
                          if (bannerList[i]["b_category"] != null &&
                              bannerList[i]["b_category"] != '')
                            Navigator.push(
                                context,
                                OpenScreen(
                                    widget: ProductListScreen(
                                  cid: bannerList[i]["b_category"].toString(),
                                )));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(sy(3)),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: CustomeImageView(
                                  image: Urls.imageLocation +
                                      bannerList[i]["b_image"].toString(),
                                  width: MediaQuery.of(context).size.width,
                                  placeholder: Urls.DummyImageBanner,
                                  fit: BoxFit.contain,
                                  blurBackground: true,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: [0.1, 0.5],
                                    colors: <Color>[
                                      Colors.black45,
                                      Colors.black12,
                                    ],
                                  )),
                                ),
                              ),
                              Positioned(
                                bottom: sy(5),
                                left: sy(5),
                                right: 0,
                                child: Container(
                                  width: Width(context),
                                  margin: EdgeInsets.fromLTRB(
                                      sy(10), sy(10), sy(10), sy(4)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (bannerList[i]["c_name$cur_Lang"]
                                                  .toString() !=
                                              '' &&
                                          bannerList[i]["c_name$cur_Lang"]
                                                  .toString() !=
                                              'null')
                                        Text(bannerList[i]["c_name$cur_Lang"],
                                            style:
                                                ts_Bold(sy(n), Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
            ),
        ],
      ),
    );
  }

  getLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationServiceEnabled == true) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _kMapCenter = LatLng(position.latitude, position.longitude);

        mapLat = position.latitude.toString();
        mapLng = position.longitude.toString();
      });
    }
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    setState(() {
      _kMapCenter = LatLng(_locationData.latitude!.toDouble(),
          _locationData.longitude!.toDouble());
      mapLat = _locationData.latitude!.toDouble().toString();
      mapLng = _locationData.longitude!.toDouble().toString();
    });
  }

  Future _openMap() async {
    var location = Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      } else {
        _openMap();
      }
    } else {
      Map results = Map();
      try {
        results = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MapScreen()));
        ;
        if (results != null) {
          setState(() {
            mapAddress = results['address'].toString();
            mapLat = results['lat'].toString();
            mapLng = results['long'].toString();
            mapCity = results['city'].toString();

            SharedStoreUtils.setValue(
                Const.MAPADDRESS, results['address'].toString());
            SharedStoreUtils.setValue(Const.MAPLAT, results['lat'].toString());
            SharedStoreUtils.setValue(Const.MAPLNG, results['long'].toString());
            SharedStoreUtils.setValue(
                Const.MAPCITY, results['city'].toString());

            Provider.of<AppSetting>(context, listen: false).mapAddress =
                mapAddress;
            Provider.of<AppSetting>(context, listen: false).maplat = mapLat;
            Provider.of<AppSetting>(context, listen: false).maplon = mapLng;
            Provider.of<AppSetting>(context, listen: false).mapCity = mapCity;

            Navigator.pushReplacement(context, OpenScreen(widget: Dashboard()));
          });
        }
      } catch (e) {
        print('cancel');
      }
    }
  }
}

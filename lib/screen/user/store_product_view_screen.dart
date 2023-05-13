import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sevenemirates/components/distance_calc.dart';
import 'package:sevenemirates/components/imagefullscreen.dart';
import 'package:sevenemirates/components/loading_placement.dart';
import 'package:sevenemirates/components/relative_scale.dart';
import 'package:sevenemirates/components/url_open.dart';
import 'package:sevenemirates/components/widget_help.dart';
import 'package:sevenemirates/screen/user/seller_profile.dart';
import 'package:sevenemirates/utils/currency_convert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../components/custom_date.dart';
import '../../components/flashbar.dart';
import '../../components/image_viewer.dart';
import '../../components/progress_layout.dart';
import '../../components/rating_widget.dart';
import '../../router/open_screen.dart';
import '../../utils/app_settings.dart';
import '../../utils/const.dart';
import '../../utils/style_sheet.dart';
import '../../utils/urls.dart';
import '../registration/phone_number.dart';

class StoreProductViewScreen extends StatefulWidget {
  String pid;
  String pname;
  String pimage;
  StoreProductViewScreen(
      {Key? key, required this.pid, required this.pname, required this.pimage})
      : super(key: key);

  @override
  State<StoreProductViewScreen> createState() => _StoreProductViewScreenState();
}

class _StoreProductViewScreenState extends State<StoreProductViewScreen>
    with RelativeScale {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool showProgress = false;
  bool showLikeProgress = false;
  String uId = '', name = '', skipSignup = '';
  Map data = Map();
  List productDetail = [];
  List productImages = [];
  List productVariant = [];
  List productColor = [];
  List fieldList = [];

  List reviewList = [];
  List viewsList = [];
  List favList = [];
  List orderList = [];
  int liked = 0;

  int quantity = 1;
  String selectedVariant = '0';
  String selectedColor = '0';
  double selectedSellPrice = 0;
  double tax = 0;
  double deliveryCost = 0;
  double totalPrice = 0;

  bool buyPressed = false;

  String mapAddress = '', mapLat = '', mapLng = '', mapCity = '';
  late GoogleMapController _Mapcontroller;

  TextEditingController ETreview = TextEditingController();
  int Pstar = 0;
  bool showReview = false;
  bool showSuccess = false;
  String selectedTabView = '1';

  TextEditingController ETaddress = TextEditingController();

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
      uId = prefs.getString(Const.UID) ?? '';
      name = prefs.getString(Const.NAME) ?? '';
      //  skipSignup = prefs.getString(Const.SKIP_SIGNUP) ?? '0';

      mapAddress = Provider.of<AppSetting>(context, listen: false).mapAddress;
      mapLat = Provider.of<AppSetting>(context, listen: false).maplat;
      mapLng = Provider.of<AppSetting>(context, listen: false).maplon;
      mapCity = Provider.of<AppSetting>(context, listen: false).mapCity;
      ETaddress.text =
          Provider.of<AppSetting>(context, listen: false).mapAddress;
    });

    _getProduct();
  }

  _getProduct() async {
    debugPrint("uid--" + uId.toString());
    debugPrint("pid--" + widget.pid.toString());
    showProgress = true;
    final response = await http.post(Uri.parse(Urls.StoreProductView),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER},
        body: {"key": Const.APPKEY, "uid": uId, "pid": widget.pid});
    data = json.decode(response.body);

    debugPrint("Request--" + response.request.toString());

    setState(() {
      showProgress = false;
      if (data["success"] == true) {
        productDetail = data["products"];
        productImages = data["images"];
        productVariant = data["size"];
        productColor = data["color"];
        fieldList = data["fields"];

        reviewList = data["reviews"];
        viewsList = data["viewlist"];
        favList = data["likelist"];
        orderList = data["orderlist"];

        liked = int.parse(data["likes"].toString());
        widget.pname = productDetail[0]['p_title'];
        widget.pimage = productDetail[0]['p_image'];

        selectedSellPrice = double.parse(productDetail[0]['p_sell']);
      } else {
        Pop.errorTop(
            context, Lang("Something wrong", "حدث خطأ ما"), Icons.warning);
      }
    });
  }

  _likeRequest() async {
    setState(() {
      showLikeProgress = true;
    });

    final response = await http.post(Uri.parse(Urls.AddLike),
        headers: {HttpHeaders.acceptHeader: Const.POSTHEADER},
        body: {"key": Const.APPKEY, "uid": uId, "pid": widget.pid});
    data = json.decode(response.body);

    debugPrint("Request--" + response.request.toString());
    debugPrint("Response--" + response.body.toString());

    setState(() {
      showLikeProgress = false;
      if (data["success"] == true) {
        if (data["action"] == "deleted") {
          setState(() {
            liked = 0;
            Pop.successTop(
                context,
                Lang('Product added to favourite list',
                    "تمت إضافة المنتج إلى قائمة المفضلة"),
                Icons.favorite_border);
          });
        } else {
          setState(() {
            liked = 1;
            Pop.successTop(
                context,
                Lang('Product removed from favourite list',
                    "تمت إزالة المنتج من قائمة المفضلة"),
                Icons.favorite);
          });
        }
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
            // top: false,
            child: ScaffoldMessenger(
              key: _scaffoldKey,
              child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Container(
                      width: Width(context),
                      height: Height(context),
                      child: Stack(
                        children: [
                          Positioned(
                            child: CustomScrollView(
                              slivers: [
                                SliverPersistentHeader(
                                  delegate: TopTitleBar(
                                      productImage: widget.pimage,
                                      productName: widget.pname,
                                      expandedHeight: Width(context) * 0.8,
                                      backBtn: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          Navigator.of(context).pop(true);
                                          // Navigator.of(context, rootNavigator: true).pop(context);
                                        },
                                        child: Material(
                                          color: Colors.black12,
                                          elevation: 1,
                                          borderRadius:
                                              BorderRadius.circular(sy(30)),
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
                                      favBtn: GestureDetector(
                                        onTap: () {
                                          if (skipSignup == '1' || uId == '0') {
                                            Navigator.push(
                                                context,
                                                OpenScreen(
                                                    widget:
                                                        PhoneNumberScreen()));
                                          } else {
                                            _likeRequest();
                                          }
                                        },
                                        child: Container(
                                          child: (showLikeProgress == false)
                                              ? Icon(
                                                  (liked == 0)
                                                      ? Icons.favorite_border
                                                      : Icons.favorite,
                                                  size: sy(17),
                                                  color: (liked == 0)
                                                      ? fc_4
                                                      : Colors.red[500],
                                                )
                                              : Container(
                                                  width: sy(10),
                                                  height: sy(10),
                                                  padding:
                                                      EdgeInsets.all(sy(3)),
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: sy(1),
                                                      valueColor:
                                                          new AlwaysStoppedAnimation<
                                                                  Color>(
                                                              TheamPrimary)),
                                                ),
                                        ),
                                      ),
                                      shareBtn: GestureDetector(
                                        onTap: () {
                                          UrlOpenUtils.openurl(
                                              _scaffoldKey,
                                              Urls.ShareURL +
                                                  'id=' +
                                                  widget.pid +
                                                  "&name=" +
                                                  widget.pname);
                                        },
                                        child: Icon(
                                          Icons.share,
                                          color: fc_4,
                                          size: sy(15),
                                        ),
                                      ),
                                      productImages: productImages,
                                      productDetail: productDetail,
                                      bcontext: context),
                                  pinned: true,
                                ),
                                SliverToBoxAdapter(
                                  child: (productDetail.length != 0)
                                      ? screenBody()
                                      : LoadingPlacement(
                                          width: Width(context),
                                          height: Width(context)),
                                )
                              ],
                            ),
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                          ),
                        ],
                      ))),
            ),
          ),
        ));
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
              tabWidget(),
              SizedBox(
                height: sy(10),
              ),
              if (tab == '0') countWidget(),
              if (tab == '1') productWidget(),
              MyProgressLayout(showProgress),
            ]),
      ),
    );
  }

  productWidget() {
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
              priceWidget(),
              SizedBox(
                height: sy(10),
              ),
              if (productVariant.length != 0) variantBlockNew(),
              if (productColor.length != 0) colorBlockNew(),
              SizedBox(
                height: sy(10),
              ),
              if (productDetail[0]['c_id'] != Const.COMMUNITY_ID &&
                  fieldList.length != 0)
                titleCard('Insights'),
              if (productDetail[0]['c_id'] != Const.COMMUNITY_ID &&
                  fieldList.length != 0)
                insightWidget(),
              titleCard(Lang(" Description ", "وصف  ")),
              detailWidget(),
              SizedBox(
                height: sy(10),
              ),
              if (productImages.length != 0) imageBlock(),
              SizedBox(
                height: sy(10),
              ),
              titleCard(Lang(" More about this ", " المزيد عن هذا ")),
              moreWidget(),
              SizedBox(
                height: sy(10),
              ),
              titleCard(Lang(" Map Location ", " خريطة الموقع ")),
              mapWidget(),
              SizedBox(
                height: sy(10),
              ),
            ]),
      ),
    );
  }

  countWidget() {
    return Container(
      width: Width(context),
      color: fc_bg_mild,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        selectedTabView = '1';
                      });
                    },
                    child: Container(
                      width: Width(context) * 0.5,
                      child: Container(
                        decoration:
                            decoration_round(fc_bg, sy(8), sy(8), sy(8), sy(8)),
                        padding:
                            EdgeInsets.fromLTRB(sy(15), sy(10), sy(15), sy(10)),
                        margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  FontAwesomeIcons.solidEye,
                                  size: sy(n),
                                  color: fc_2,
                                ),
                                SizedBox(
                                  width: sy(8),
                                ),
                                Text(
                                  Lang("Views  ", "المشاهدات  "),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_right,
                                  size: sy(xl),
                                  color: fc_2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: sy(8),
                            ),
                            Text(
                              viewsList.length.toString(),
                              style: ts_Bold(sy(l), fc_2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        selectedTabView = '2';
                      });
                    },
                    child: Container(
                      width: Width(context) * 0.5,
                      child: Container(
                        decoration:
                            decoration_round(fc_bg, sy(8), sy(8), sy(8), sy(8)),
                        padding:
                            EdgeInsets.fromLTRB(sy(15), sy(10), sy(15), sy(10)),
                        margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  FontAwesomeIcons.comment,
                                  size: sy(n),
                                  color: fc_2,
                                ),
                                SizedBox(
                                  width: sy(8),
                                ),
                                Text(
                                  Lang("Reviews  ", " المراجعات "),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_right,
                                  size: sy(xl),
                                  color: fc_2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: sy(8),
                            ),
                            Text(
                              reviewList.length.toString(),
                              style: ts_Bold(sy(l), fc_2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        selectedTabView = '3';
                      });
                    },
                    child: Container(
                      width: Width(context) * 0.5,
                      child: Container(
                        decoration:
                            decoration_round(fc_bg, sy(8), sy(8), sy(8), sy(8)),
                        padding:
                            EdgeInsets.fromLTRB(sy(15), sy(10), sy(15), sy(10)),
                        margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  FontAwesomeIcons.heart,
                                  size: sy(n),
                                  color: fc_2,
                                ),
                                SizedBox(
                                  width: sy(8),
                                ),
                                Text(
                                  Lang(" Favourites ", "المفضلة  "),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_right,
                                  size: sy(xl),
                                  color: fc_2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: sy(8),
                            ),
                            Text(
                              favList.length.toString(),
                              style: ts_Bold(sy(l), fc_2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        selectedTabView = '4';
                      });
                    },
                    child: Container(
                      width: Width(context) * 0.5,
                      child: Container(
                        decoration:
                            decoration_round(fc_bg, sy(8), sy(8), sy(8), sy(8)),
                        padding:
                            EdgeInsets.fromLTRB(sy(15), sy(10), sy(15), sy(10)),
                        margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  FontAwesomeIcons.cartArrowDown,
                                  size: sy(n),
                                  color: fc_2,
                                ),
                                SizedBox(
                                  width: sy(8),
                                ),
                                Text(
                                  Lang("Orders  ", " الطلبات "),
                                  style: ts_Regular(sy(n), fc_2),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_right,
                                  size: sy(xl),
                                  color: fc_2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: sy(8),
                            ),
                            Text(
                              orderList.length.toString(),
                              style: ts_Bold(sy(l), fc_2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedTabView == '2') reviewWidget(),
              if (selectedTabView == '1')
                profileWidget(viewsList, Lang('Views', 'المشاهدات'), 'dated'),
              if (selectedTabView == '3')
                profileWidget(favList, Lang('Favourites','المفضلة'), 'dated'),
              if (selectedTabView == '4')
                profileWidget(orderList, Lang('Orders', 'طلبات'), 'o_dated'),
            ]),
      ),
    );
  }

  String tab = '0';
  tabWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    tab = '0';
                  });
                },
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(sy(0), sy(8), sy(0), sy(0)),
                    child: Column(
                      children: [
                        Text(
                          Lang(" Insights ", " أفكار "),
                          style: ts_Regular(sy(n), (tab == '0') ? fc_1 : fc_3),
                        ),
                        SizedBox(
                          height: sy(8),
                        ),
                        Container(
                          width: Width(context),
                          height: (tab == '0') ? sy(2) : sy(1),
                          color: fc_1,
                        )
                      ],
                    ))),
          ),
          Container(
            width: sy(1),
            height: sy(20),
            color: fc_6,
          ),
          Expanded(
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    tab = '1';
                  });
                },
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(sy(0), sy(8), sy(0), sy(0)),
                    child: Column(
                      children: [
                        Text(
                          Lang("Overview  ", " نظرة عامة "),
                          style: ts_Regular(sy(n), (tab == '1') ? fc_1 : fc_3),
                        ),
                        SizedBox(
                          height: sy(8),
                        ),
                        Container(
                          width: Width(context),
                          height: (tab == '1') ? sy(2) : sy(1),
                          color: fc_1,
                        )
                      ],
                    ))),
          ),
        ],
      ),
    );
  }

  imageBlock() {
    return Container(
      width: Width(context),
      // margin:EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(0), sy(0), sy(0)),
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              for (int i = 0; i < productImages.length; i++)
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          OpenScreen(
                              widget: ImageFullScreen(
                            imgurl: Urls.imageLocation +
                                productImages[i]['pi_image'].toString(),
                          )));
                    },
                    child: Container(
                      width: Width(context) * 0.25,
                      height: Width(context) * 0.22,
                      padding: EdgeInsets.fromLTRB(sy(5), sy(0), sy(3), sy(5)),
                      child: CustomeImageView(
                        image: Urls.imageLocation +
                            productImages[i]['pi_image'].toString(),
                        width: Width(context) * 0.25,
                        height: Width(context) * 0.2,
                        radius: sy(2),
                        blurBackground: false,
                        fit: BoxFit.cover,
                      ),
                    )),
            ],
          ),
        ],
      ),
    );
  }

  mapWidget() {
    return Container(
      width: Width(context),
      child: Column(
        children: [
          Container(
              width: Width(context),
              height: Width(context) * 0.6,
              decoration: decoration_round(
                  Colors.grey.shade300, sy(5), sy(5), sy(5), sy(5)),
              padding: EdgeInsets.all(sy(1)),
              margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
              child: Stack(
                children: [
                  Positioned(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(sy(5)),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        // markers:<Marker>[
                        //   Marker(
                        //       markerId: MarkerId("Point"),
                        //       position: LatLng(double.parse(productDetail[0]['p_lat'].toString()), double.parse(productDetail[0]['p_lng'].toString())),
                        //       icon: BitmapDescriptor.defaultMarker,
                        //       infoWindow: InfoWindow(title: "Point")
                        //   ),
                        // ].toSet(),
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              double.parse(
                                  productDetail[0]['p_lat'].toString()),
                              double.parse(
                                  productDetail[0]['p_lng'].toString())),
                          zoom: 15.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          changeMapMode();

                          _Mapcontroller = controller;
                        },
                      ),
                    ),
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.place,
                      size: sy(xxl + 5),
                      color: TheamPrimary,
                    ),
                  )
                ],
              )),
          Container(
            margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
            child: Text(
              productDetail[0]['p_address'],
              style: ts_Regular(sy(s), fc_3),
            ),
          ),
          SizedBox(
            height: sy(10),
          ),
        ],
      ),
    );
  }

  changeMapMode() async {
    getJsonFile("assets/images/vehiclemapstyle.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _Mapcontroller.setMapStyle(mapStyle);
  }

  priceWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.pname,
                        style: ts_Bold(sy(l), fc_2),
                      ),
                      Spacer(),
                      SizedBox(
                        width: sy(5),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: sy(5),
                  ),
                  Row(
                    children: [
                      Text(
                        productDetail[0]["c_name"].toString(),
                        style: ts_Regular(sy(s), fc_2),
                      ),
                      SizedBox(
                        width: sy(5),
                      ),
                      Icon(
                        Icons.arrow_right,
                        size: sy(n + 1),
                        color: fc_3,
                      ),
                      SizedBox(
                        width: sy(3),
                      ),
                      Text(
                        productDetail[0]["sc_title"].toString(),
                        style: ts_Regular(sy(s), fc_2),
                      ),
                    ],
                  ),
                ],
              )),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceUtils.convert(selectedSellPrice.toString()),
                    style: ts_Bold(sy(l), TheamSecondary),
                  ),
                  SizedBox(
                    height: sy(3),
                  ),
                  if (productDetail[0]['c_id'] != Const.JOBS_ID)
                    Text(
                      productDetail[0]["p_quantity"] +
                          ' ' +
                          productDetail[0]["p_unit"],
                      style: ts_Regular(sy(s), fc_4),
                    ),
                  if (productDetail[0]['c_id'] == Const.JOBS_ID)
                    Text(
                      Lang(" Monthly Package ", "الباقة الشهرية  "),
                      style: ts_Regular(sy(s), fc_4),
                    ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  insightWidget() {
    return Container(
      width: Width(context),
      margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
      decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(5)),
      alignment: Alignment.center,
      child: Column(
        children: [
          for (int i = 0; i < fieldList.length; i++)
            Container(
                alignment: Alignment.center,
                // padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                decoration: decoration_border(
                    fc_bg, fc_bg, 0.0, sy(15), sy(15), sy(15), sy(15)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(sy(0)),
                            child: CustomeImageView(
                              image: Urls.imageLocation +
                                  fieldList[i]['f_image'].toString(),
                              placeholder: Urls.DummyImageBanner,
                              fit: BoxFit.cover,
                              blurBackground: false,
                              imgColor: fc_3!,
                              height: sy(17),
                              width: sy(17),
                            )),
                        SizedBox(
                          width: sy(10),
                        ),
                        Text(
                          fieldList[i]['f_title'].toString(),
                          style: ts_Regular(sy(n - 1), fc_3),
                        ),
                        Spacer(),
                        Text(
                          fieldList[i]['f_ans'].toString(),
                          style: ts_Regular(sy(n - 1), fc_2),
                        ),
                      ],
                    ),
                    if (i != fieldList.length - 1)
                      Container(
                        color: Colors.grey.shade200,
                        width: Width(context),
                        height: sy(1),
                        margin: EdgeInsets.fromLTRB(sy(0), sy(7), sy(0), sy(0)),
                      )
                  ],
                ))
        ],
      ),
    );
  }

  moreWidget() {
    return Container(
      width: Width(context),
      margin: EdgeInsets.fromLTRB(sy(10), sy(0), sy(10), sy(10)),
      decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(5)),
      alignment: Alignment.center,
      child: Column(
        children: [
          cardMoreDetail('Post ID', '7EP0' + productDetail[0]['p_id']),
          divLine(sy(3), sy(3)),
          cardMoreDetail('Category', productDetail[0]['c_name']),
          divLine(sy(3), sy(3)),
          cardMoreDetail('Classification', productDetail[0]['sc_title']),
          divLine(sy(3), sy(3)),
          cardMoreDetail('Host Name', productDetail[0]['name']),
          divLine(sy(3), sy(3)),
          cardMoreDetail('Host ID', '7EU0' + productDetail[0]['u_id']),
          divLine(sy(3), sy(3)),
          cardMoreDetail('Phone', productDetail[0]['phone']),
          divLine(sy(3), sy(3)),
          cardMoreDetail('Email', productDetail[0]['email']),
          divLine(sy(3), sy(3)),
          cardMoreDetail('City', productDetail[0]['p_city']),
          divLine(sy(3), sy(3)),
          cardMoreDetail(
              'Distance',
              DistanceCalc.map(context,
                  productDetail[0]['p_lat'] + ',' + productDetail[0]['p_lng'])),
        ],
      ),
    );
  }

  reviewWidget() {
    return Container(
      width: Width(context),
      margin: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(10)),
      // decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(0)),
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Lang(" Reviews ", " المراجعات "),
                  style: ts_Bold(sy(n), fc_3),
                ),
              ),
            ],
          ),
          SizedBox(
            height: sy(15),
          ),
          for (int i = 0; i < reviewList.length && i < 20; i++)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(0)),
                decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
                width: Width(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WidgetHelp.profilePic(reviewList[i]['profile_pic'],
                            reviewList[i]['name'], sy(30), sy(30), sy(30)),
                        SizedBox(
                          width: sy(8),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reviewList[i]['name'],
                                style: ts_Bold(sy(n), fc_2),
                              ),
                              SizedBox(
                                height: sy(2),
                              ),
                              Text(
                                CustomeDate.dateTime(reviewList[i]['r_dated']),
                                style: ts_Regular(sy(s), fc_4),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: sy(5),
                        ),
                        RatingWidget(
                          ratings: reviewList[i]['star'].toString(),
                          color: Colors.amber,
                          size: sy(n + 1),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: sy(5),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: sy(35),
                        ),
                        Expanded(
                          child: Text(reviewList[i]['comments'],
                              style: ts_Regular(sy(n), fc_3)),
                        )
                      ],
                    ),
                    SizedBox(
                      height: sy(8),
                    ),
                    if (i != reviewList.length - 1) divLine(sy(8), 0),
                  ],
                ),
              ),
            ),
          if (reviewList.length == 0)
            emptyWidget(
                Lang("  No Reviews found", "لم يتم العثور على تعليقات  ")),
        ],
      ),
    );
  }

  profileWidget(List arrList, String title, String key) {
    apiTest(arrList.toString());
    return Container(
      width: Width(context),
      margin: EdgeInsets.fromLTRB(sy(10), sy(5), sy(10), sy(10)),
      // decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
      padding: EdgeInsets.fromLTRB(sy(0), sy(5), sy(0), sy(0)),
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: ts_Bold(sy(n), fc_3),
                ),
              ),
            ],
          ),
          SizedBox(
            height: sy(15),
          ),
          for (int i = 0; i < arrList.length; i++)
            GestureDetector(
              onTap: () {
                _showPop(arrList[i]['country_id'] + arrList[i]['phone']);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
                margin: EdgeInsets.fromLTRB(sy(0), sy(2), sy(0), sy(2)),
                decoration: decoration_round(fc_bg, sy(5), sy(5), sy(5), sy(5)),
                width: Width(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WidgetHelp.profilePic(
                            arrList[i]['profile_pic'].toString(),
                            arrList[i]['name'].toString(),
                            sy(30),
                            sy(30),
                            sy(30)),
                        SizedBox(
                          width: sy(8),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                arrList[i]['name'].toString(),
                                style: ts_Bold(sy(n), fc_2),
                              ),
                              SizedBox(
                                height: sy(5),
                              ),
                              Text(
                                CustomeDate.dateTime(arrList[i][key]),
                                style: ts_Regular(sy(s), fc_4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (arrList.length == 0)
            emptyWidget(Lang("No item found ", "لم يتم العثور على عنصر ")),
        ],
      ),
    );
  }

  emptyWidget(String lable) {
    return Container(
      width: Width(context),
      child: Column(
        children: [
          SizedBox(
            height: sy(5),
          ),
          Image.asset(
            'assets/images/emptyimg.png',
            width: Width(context) * 0.3,
          ),
          SizedBox(
            height: sy(2),
          ),
          Text(
            lable,
            style: ts_Regular(sy(s), fc_4),
          ),
          SizedBox(
            height: sy(5),
          ),
        ],
      ),
    );
  }

  titleCard(String lable) {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(10), sy(10), sy(10), sy(7)),
      child: Text(
        lable,
        style: ts_Bold(sy(n), fc_3),
      ),
    );
  }

  divLine(double top, double bottom) {
    return Container(
      color: Colors.grey.shade200,
      width: Width(context),
      height: sy(1),
      margin: EdgeInsets.fromLTRB(sy(0), top, sy(0), bottom),
    );
  }

  cardMoreDetail(String qes, String ans) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
        decoration: decoration_border(
            fc_bg, fc_bg, 0.0, sy(15), sy(15), sy(15), sy(15)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.double_arrow,
                  size: sy(l - 1),
                  color: fc_4,
                ),
                SizedBox(
                  width: sy(8),
                ),
                Text(
                  qes.toString(),
                  style: ts_Regular(sy(n - 1), fc_3),
                ),
                Spacer(),
                Text(
                  ans.toString(),
                  style: ts_Regular(sy(n - 1), fc_2),
                ),
              ],
            ),
          ],
        ));
  }

  detailWidget() {
    return Container(
      margin: EdgeInsets.fromLTRB(sy(10), sy(3), sy(10), sy(3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productDetail[0]['p_detail'],
            textAlign: TextAlign.justify,
            style: ts_Regular(sy(n), fc_2),
          ),
        ],
      ),
    );
  }

  cardDouble(String qes, String ans) {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(5), sy(3), sy(5), sy(3)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              qes,
              style: ts_Regular(sy(n), fc_2),
            ),
          ),
          Text(
            ans,
            style: ts_Regular(sy(n), fc_2),
          )
        ],
      ),
    );
  }

  tabbutton(IconData icon, String name) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(sy(10), sy(6), sy(15), sy(6)),
      margin: EdgeInsets.fromLTRB(sy(5), sy(5), sy(5), sy(5)),
      decoration: decoration_round(fc_6, sy(10), sy(10), sy(10), sy(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: sy(l),
            color: fc_2,
          ),
          SizedBox(
            width: sy(8),
          ),
          Text(
            name,
            style: ts_Regular(sy(n), fc_2),
          ),
        ],
      ),
    );
  }

  variantBlockNew() {
    return Container(
      width: Width(context),
      padding: EdgeInsets.fromLTRB(sy(10), sy(0), sy(5), sy(0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: sy(8),
            runSpacing: sy(8),
            alignment: WrapAlignment.start,
            children: [
              for (int i = 0; i < productVariant.length; i++)
                Container(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (productVariant[i]['s_qty'].toString() == '0') {
                              Pop.errorTop(
                                  context,
                                  Lang('Out of stock', "غير متوفر بالمخزن"),
                                  Icons.shopping_cart);
                            } else {
                              selectedVariant =
                                  productVariant[i]['ps_id'].toString();
                              selectedSellPrice = double.parse(
                                  productVariant[i]['sell'].toString());
                            }
                          });
                        },
                        child: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minWidth: sy(33),
                          ),
                          child: Container(
                            padding:
                                EdgeInsets.fromLTRB(sy(8), sy(5), sy(8), sy(5)),
                            decoration: decoration_border(
                                (selectedVariant ==
                                        productVariant[i]['ps_id'].toString())
                                    ? TheamPrimary
                                    : (productVariant[i]['s_qty'].toString() ==
                                            '0')
                                        ? Colors.grey[100]
                                        : Colors.transparent,
                                (productVariant[i]['s_qty'].toString() == '0')
                                    ? Colors.grey[100]
                                    : Colors.grey[400],
                                1,
                                sy(4),
                                sy(4),
                                sy(4),
                                sy(4)),
                            child: Text(
                              productVariant[i]['name'],
                              style: ts_Regular(
                                  sy(s),
                                  (selectedVariant ==
                                          productVariant[i]['ps_id'].toString())
                                      ? Colors.white
                                      : Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  colorBlockNew() {
    return Container(
      padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(5), sy(0)),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: sy(10),
          ),
          Wrap(
            spacing: sy(8),
            runSpacing: sy(8),
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < productColor.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = productColor[i]['pv_id'].toString();
                    });
                  },
                  child: Container(
                    height: sy(20),
                    width: sy(20),
                    decoration: decoration_border(
                        Color(int.parse("0xFF" + productColor[i]['color'])),
                        (selectedColor == productColor[i]['pv_id'].toString())
                            ? TheamPrimary
                            : (productColor[i]['color']
                                        .toString()
                                        .toLowerCase() ==
                                    'ffffff')
                                ? Colors.grey[600]
                                : Colors.transparent,
                        (selectedColor == productColor[i]['pv_id'].toString())
                            ? 4
                            : (productColor[i]['color']
                                        .toString()
                                        .toLowerCase() ==
                                    'ffffff')
                                ? 1
                                : 4,
                        sy(5),
                        sy(5),
                        sy(5),
                        sy(5)),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: sy(0),
          ),
        ],
      ),
    );
  }

  getTax() {
    double pTax = 0;
    pTax = (selectedSellPrice / 100) * 5;
    return pTax.toStringAsFixed(2);
  }

  getTotal() {
    double pTotal = 0;
    pTotal = double.parse(getTax()) + selectedSellPrice;
    return pTotal.toStringAsFixed(2);
  }

  _showPop(String phone) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            width: Width(context),
            color: fc_bg,
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(
                    Lang("What you like?  ", "ماذا تحب؟  "),
                    style: ts_Regular(sy(l), fc_1),
                  ),
                ),
                Container(
                  height: 0.5,
                  color: fc_2,
                ),
                ListTile(
                    leading: Icon(
                      Icons.call,
                      color: fc_1,
                      size: sy(xl),
                    ),
                    title: Text(
                      Lang(" Call ", " اتصال "),
                      style: ts_Regular(sy(n), fc_2),
                    ),
                    onTap: () => {
                          UrlOpenUtils.call(_scaffoldKey, phone),
                          Navigator.pop(context),
                        }),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.whatsapp,
                    color: fc_1,
                    size: sy(xl),
                  ),
                  title: Text(
                    Lang('Whatsapp', "واتساب"),
                    style: ts_Regular(sy(n), fc_2),
                  ),
                  onTap: () => {
                    UrlOpenUtils.whatsappShop(_scaffoldKey, phone),
                    Navigator.pop(context),
                  },
                ),
              ],
            ),
          );
        });
  }
}

class TopTitleBar extends SliverPersistentHeaderDelegate with RelativeScale {
  final String productImage;
  final String productName;

  final BuildContext bcontext;
  final double? expandedHeight;
  final double itemHeight = 200;
  final Widget shareBtn;
  final Widget backBtn;
  final Widget favBtn;
  final List productImages;
  final List productDetail;

  TopTitleBar(
      {required this.productImage,
      required this.productName,
      required this.shareBtn,
      required this.backBtn,
      required this.favBtn,
      required this.productImages,
      required this.productDetail,
      required this.bcontext,
      this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    initRelativeScaler(context);
    return Container(
      width: Width(context),
      height: expandedHeight,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        //  overflow: Overflow.visible,
        children: [
          Positioned(
            child: bannerImage(context),
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            bottom: 0,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: sy(40),
                padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(5), sy(5)),
                child: Row(
                  children: [
                    backBtn,
                    Expanded(
                      child: SizedBox(
                        width: sy(10),
                      ),
                    ),
                    if (productDetail.length != 0)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          //Navigator.of(context).pop(true);
                          // Navigator.of(context, rootNavigator: true).pop(context);
                        },
                        child: Material(
                          color: Colors.black12,
                          elevation: 1,
                          borderRadius: BorderRadius.circular(sy(30)),
                          child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.fromLTRB(
                                  sy(10), sy(0), sy(10), sy(0)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: fc_bg,
                                    size: sy(n),
                                  ),
                                  SizedBox(
                                    width: sy(5),
                                  ),
                                  Text(
                                    productDetail[0]['p_city'].toString(),
                                    style: ts_Regular(sy(s), fc_bg),
                                  )
                                ],
                              )),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (productDetail.length != 0)
            Positioned(
              left: sy(10),
              right: sy(10),
              bottom: sy(10),
              child: Container(
                width: Width(context),
                height: sy(45),
                padding: EdgeInsets.fromLTRB(sy(10), sy(5), sy(8), sy(5)),
                decoration: decoration_border(
                    fc_bg, fc_bg, 0.0, sy(10), sy(10), sy(10), sy(10)),
                //   alignment: Alignment.center,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            bcontext,
                            OpenScreen(
                                widget: SellerProfileScreen(
                                    seller: productDetail[0]['u_id'])));
                      },
                      child: WidgetHelp.profilePic(
                          productDetail[0]['profile_pic'].toString(),
                          productDetail[0]['name'].toString(),
                          sy(30),
                          sy(30),
                          sy(30)),
                    ),
                    SizedBox(
                      width: sy(10),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: sy(3),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  child: Text(
                                    productDetail[0]['name'],
                                    style: ts_Bold(sy(n), fc_1),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        bcontext,
                                        OpenScreen(
                                            widget: SellerProfileScreen(
                                          seller: productDetail[0]['u_id'],
                                        )));
                                  },
                                ),
                              ),
                              favBtn,
                              SizedBox(
                                width: sy(10),
                              ),
                              shareBtn,
                            ],
                          ),
                          SizedBox(
                            height: sy(1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Lang(" Posted on ", " نشر في ") +
                                    ' ' +
                                    CustomeDate.datedaymonth(
                                        productDetail[0]['p_dated']),
                                style: ts_Regular(sy(s), fc_3),
                              ),
                              SizedBox(
                                width: sy(8),
                              ),
                              if (productDetail[0]['is_service'] == '0' &&
                                  productDetail[0]['p_used'] == '0')
                                Container(
                                  decoration: decoration_round(
                                      Colors.green.shade50,
                                      sy(3),
                                      sy(3),
                                      sy(3),
                                      sy(3)),
                                  padding: EdgeInsets.fromLTRB(
                                      sy(5), sy(1), sy(5), sy(1)),
                                  child: Text(
                                    Lang("New  ", "جديد  "),
                                    style: ts_Regular(sy(s), Colors.green),
                                  ),
                                ),
                              if (productDetail[0]['is_service'] == '0' &&
                                  productDetail[0]['p_used'] == '1')
                                Container(
                                  decoration: decoration_round(
                                      Colors.blue.shade50,
                                      sy(3),
                                      sy(3),
                                      sy(3),
                                      sy(3)),
                                  padding: EdgeInsets.fromLTRB(
                                      sy(5), sy(1), sy(5), sy(1)),
                                  child: Text(
                                    Lang("Used  ", " مُستعمل "),
                                    style: ts_Regular(sy(s), Colors.blue),
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bannerImage(BuildContext context) {
    if (productImages.length != 0) {
      return Container(
        color: Colors.white,
        height: expandedHeight,
        child: CarouselSlider.builder(
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
            itemCount: productImages.length,
            itemBuilder: (BuildContext context, int i, int pageViewIndex) =>
                GestureDetector(
                  onTap: () {
                    showImageSlide(context, i);
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(sy(0)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomeImageView(
                            image: Urls.imageLocation +
                                productImages[i]["pi_image"].toString(),
                            width: Width(context),
                            placeholder: Urls.DummyImageBanner,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ],
                      )),
                )

            //  control: SwiperControl(),
            ),
      );
    } else {
      return Container(
        color: TheamSecondary,
        height: expandedHeight,
        child: Stack(
          children: [
            if (productImage != null)
              Positioned(
                child: CustomeImageView(
                  image: Urls.imageLocation + productImage,
                  width: MediaQuery.of(context).size.width,
                  placeholder: Urls.DummyImageBanner,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
              ),
          ],
        ),
      );
    }
  }

  showImageSlide(BuildContext context, int item) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black, // background color
      barrierDismissible:
          true, // should dialog be dismissed when tapped outside
      barrierLabel: "Dialog", // label for barrier
      transitionDuration: Duration(
          milliseconds:
              400), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SizedBox.expand(
            // makes widget fullscreen
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: PageView.builder(
                        itemCount: productImages.length,
                        physics: BouncingScrollPhysics(),
                        controller: PageController(
                            viewportFraction: 0.99, initialPage: item),
                        itemBuilder: (_, i) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Zoom(
                                width: 800,
                                height: 1800,
                                canvasColor: Colors.black,
                                backgroundColor: Colors.black,
                                //   colorScrollBars: Colors.grey[800],
                                opacityScrollBars: 0.0,
                                scrollWeight: 10.0,
                                centerOnScale: true,
                                // enableScroll: true,
                                doubleTapZoom: true,
                                initZoom: 0.0,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: FadeInImage(
                                      image: NetworkImage(Urls.imageLocation +
                                          productImages[i]["pi_image"]),
                                      placeholder:
                                          AssetImage(Urls.DummyImageBanner),
                                      fit: BoxFit.contain,
                                    ))),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: sy(20),
                  right: sy(10),
                  child: Material(
                    color: Colors.black12.withOpacity(0.8),
                    child: Container(
                      width: 50,
                      height: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 30,
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => expandedHeight!;

  @override
  double get minExtent => expandedHeight! * 0.5;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
